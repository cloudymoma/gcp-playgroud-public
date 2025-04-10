#!/bin/bash

# --- Configuration ---
# GCP Project and Networking
export PROJECT_NAME=du-hast-mich
export REGION=us-central1
export ZONE=$REGION-b

# GCS Bucket for staging, temp files, and Flink history
export GCS_BUCKET=dingoproc # Make sure this bucket exists
export STAGING_BUCKET=$GCS_BUCKET
export TEMP_BUCKET=$GCS_BUCKET
export FLINK_GCS_ROOT=gs://$GCS_BUCKET/flink # Directory for Flink

# Cluster Names
export FLINK_HIST_CLUSTER_NAME=dingoflinkhist
export FLINK_JOB_CLUSTER_NAME=dingoflinkjob

# Job Cluster Configuration
export MAX_IDLE=1h # Auto-delete after 1 hour of inactivity

export OS_IMG=2.2-debian12 # Flink image version

# Flink Job Configuration (MODIFY THESE)
export FLINK_JOB_JAR="gs://dingoproc/flink_jobs/pubsub-flink-1.0-SNAPSHOT.jar" # REQUIRED: Path to your Flink job JAR (can be local or GCS)
export FLINK_MAIN_CLASS="" # OPTIONAL: Main class if not specified in JAR manifest (e.g., com.example.MyFlinkJob)

# --- Internal ---
pwd=$(pwd) # Get current directory for potential local file paths

# --- Functions ---

__usage() {
    echo "Usage: ./flink.sh {flinkhistserver|policy|flinkjobserver|flinkjob [job_args...]}"
    echo "  flinkhistserver: Creates the Flink Persistent History Server."
    echo "  policy:          Imports the autoscaling policy (requires autoscaling-policy.yml)."
    echo "  flinkjobserver:  Creates the Flink Job Execution Cluster."
    echo "  flinkjob:        Submits a Flink job using FLINK_JOB_JAR."
    echo "                   Any arguments after 'flinkjob' are passed to the Flink job."
    echo ""
    echo "Ensure FLINK_JOB_JAR is set before running 'flinkjob'."
    echo "Ensure gcloud is configured and the GCS bucket '$GCS_BUCKET' exists."
}

# Creates the Flink Persistent History Server (PHS)
__flink_hist_server() {
    echo "Creating Flink History Server Cluster: $FLINK_HIST_CLUSTER_NAME..."
    gcloud dataproc clusters create $FLINK_HIST_CLUSTER_NAME \
        --optional-components=FLINK \
        --enable-component-gateway \
        --region=${REGION} --zone=$ZONE \
        --single-node \
        --master-machine-type=n4-standard-2 \
        --master-boot-disk-size=100GB \
        --master-boot-disk-type=hyperdisk-balanced \
        --image-version=${OS_IMG} \
        --bucket=$STAGING_BUCKET \
        --properties=yarn:yarn.nodemanager.remote-app-log-dir=$FLINK_GCS_ROOT/yarn-logs \
        --properties=spark:spark.eventLog.enabled=true \
        --properties=spark:spark.eventLog.dir=$FLINK_GCS_ROOT/events/spark-job-history \
        --properties=spark:spark.eventLog.rolling.enabled=true \
        --properties=spark:spark.eventLog.rolling.maxFileSize=128m \
        --properties=spark:spark.history.fs.logDirectory=$FLINK_GCS_ROOT/events/spark-job-history \
        --properties=flink:historyserver.archive.fs.dir=$FLINK_GCS_ROOT/history \
        --properties=flink:historyserver.archive.fs.refresh-interval=3000 \
        --properties=flink:historyserver.web.refresh-interval=3000 \
        --properties=flink:jobmanager.archive.fs.dir=$FLINK_GCS_ROOT/jobs \
        --project=$PROJECT_NAME
    echo "Flink History Server UI may be accessible via Component Gateway once ready."
}

# Imports or updates the autoscaling policy
__define_auto_scale_policy() {
    local policy_file="$pwd/autoscaling-policy.yml"
    if [[ ! -f "$policy_file" ]]; then
        echo "Error: Autoscaling policy file not found at $policy_file"
        echo "Create 'autoscaling-policy.yml' in the script directory."
        # Example autoscaling-policy.yml content:
        # workerConfig:
        #   minInstances: 2
        #   maxInstances: 4
        #   weight: 1
        # secondaryWorkerConfig:
        #   minInstances: 0
        #   maxInstances: 20
        #   weight: 1
        # basicAlgorithm:
        #   yarnConfig:
        #     scaleUpFactor: 0.5
        #     scaleDownFactor: 0.5
        #     scaleUpMinWorkerFraction: 0.1
        #     scaleDownMinWorkerFraction: 0.1
        #     gracefulDecommissionTimeout: 1h
        #   cooldownPeriod: 5m
        return 1
    fi
    echo "Importing autoscaling policy from $policy_file..."
    gcloud dataproc autoscaling-policies import balanced-scaling-policy \
        --source="$policy_file" \
        --region=$REGION \
        --project=$PROJECT_NAME
}

# Creates the Flink Job Execution Cluster
__flink_job_server() {
    echo "Creating Flink Job Cluster: $FLINK_JOB_CLUSTER_NAME..."
    # Calculate default task slots - typically match vCPUs per worker
    local worker_type="n2d-standard-2" # Keep consistent with --worker-machine-type
    local task_slots=2 # Default for n2d-standard-2 (2 vCPUs)

    gcloud dataproc clusters create $FLINK_JOB_CLUSTER_NAME \
        --optional-components=FLINK \
        --enable-component-gateway \
        --region=$REGION --zone=$ZONE \
        --max-idle=$MAX_IDLE \
        --bucket=$STAGING_BUCKET \
        --temp-bucket=$TEMP_BUCKET \
        --image-version=${OS_IMG} \
        --master-machine-type=n2d-standard-2 \
        --num-masters=1 \
        --master-boot-disk-size=128GB \
        --master-boot-disk-type=pd-balanced \
        --num-master-local-ssds=1 `# Flink typically doesn't require master SSDs like Spark might for shuffle` \
        --master-local-ssd-interface=NVME \
        --autoscaling-policy=balanced-scaling-policy `# Ensure this policy exists via 'policy' command` \
        --worker-machine-type=$worker_type \
        --num-workers=2 `# Initial workers, autoscaler will adjust` \
        --worker-boot-disk-size=100GB `# Adjust based on Flink state/checkpoint needs` \
        --worker-boot-disk-type=pd-balanced `# pd-ssd might be better if checkpointing is heavy` \
        --num-worker-local-ssds=1 `# Flink checkpoints usually go to GCS/persistent storage` \
        --worker-local-ssd-interface=NVME \
        --secondary-worker-type=spot \
        --num-secondary-workers=2 `# Initial secondary workers` \
        --secondary-worker-boot-disk-size=100GB \
        --secondary-worker-boot-disk-type=pd-balanced \
        --num-secondary-worker-local-ssds=1 \
        --secondary-worker-local-ssd-interface=NVME \
        --properties=yarn:yarn.nodemanager.remote-app-log-dir=$FLINK_GCS_ROOT/yarn-logs \
        --properties=spark:spark.eventLog.enabled=true \
        --properties=spark:spark.eventLog.dir=$FLINK_GCS_ROOT/events/spark-job-history \
        --properties=spark:spark.eventLog.rolling.enabled=true \
        --properties=spark:spark.eventLog.rolling.maxFileSize=128m \
        --properties=spark:spark.history.fs.logDirectory=$FLINK_GCS_ROOT/events/spark-job-history \
        --properties=spark:spark.history.fs.gs.outputstream.type=FLUSHABLE_COMPOSITE \
        --properties=spark:spark.history.fs.gs.outputstream.sync.min.interval.ms=1000ms \
        --properties=spark:spark.dataproc.enhanced.optimizer.enabled=true \
        --properties=spark:spark.dataproc.enhanced.execution.enabled=true \
        --properties=dataproc:dataproc.cluster.caching.enabled=true \
        --properties=flink:historyserver.archive.fs.dir=$FLINK_GCS_ROOT/history \
        --properties=flink:historyserver.archive.fs.refresh-interval=3000 \
        --properties=flink:historyserver.web.refresh-interval=3000 \
        --properties=flink:jobmanager.archive.fs.dir=$FLINK_GCS_ROOT/jobs \
        --properties=flink:taskmanager.numberOfTaskSlots=$task_slots \
        --project=$PROJECT_NAME
    echo "Flink Job Cluster UI may be accessible via Component Gateway once ready."
}

# Submits a Flink Job
__flink_job() {
    if [[ -z "$FLINK_JOB_JAR" ]]; then
       echo "Error: FLINK_JOB_JAR environment variable is not set."
       __usage
       return 1
    fi
    echo "Submitting Flink job from JAR: $FLINK_JOB_JAR to cluster $FLINK_JOB_CLUSTER_NAME..."

    local job_args=()
    if [[ -n "$FLINK_MAIN_CLASS" ]]; then
        job_args+=(--class "$FLINK_MAIN_CLASS")
    fi

    # Add remaining arguments passed to the script
    if [[ $# -gt 0 ]]; then
      job_args+=(--)
      job_args+=("$@")
    fi

    gcloud dataproc jobs submit flink \
        --region=$REGION \
        --cluster=$FLINK_JOB_CLUSTER_NAME \
        --project=$PROJECT_NAME \
        --jar="$FLINK_JOB_JAR" \
        "${job_args[@]}" # Pass class and job arguments
}

# --- Main Execution Logic ---
__main() {
    if [ $# -eq 0 ]; then
        __usage
        exit 1
    fi

    local command=$1
    shift # Remove the command name from arguments

    case $command in
        flinkhistserver)
            __flink_hist_server
            ;;
        policy|p)
            __define_auto_scale_policy
            ;;
        flinkjobserver)
            # Optionally ensure policy exists first
            # __define_auto_scale_policy
            __flink_job_server
            ;;
        flinkjob)
            __flink_job "$@" # Pass remaining arguments to the job function
            ;;
        *)
            echo "Error: Unknown command '$command'"
            __usage
            exit 1
            ;;
    esac
}

# Execute the main function passing all script arguments
__main "$@"