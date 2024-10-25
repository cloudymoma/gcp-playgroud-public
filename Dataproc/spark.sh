#!/bin/bash -ex

export PHS_CLUSTER_NAME=dingohist
export REGION=us-central1
export ZONE=$REGION-b
export GCS_BUCKET=dingoproc
export PROJECT_NAME=du-hast-mich
export STAGING_BUCKET=$GCS_BUCKET
export TEMP_BUCKET=$GCS_BUCKET

export JOB_CLUSTER_NAME=dingojob
export MAX_IDLE=1h

pwd=$(pwd)

__usage() {
    echo "Usage: ./spark.sh {histserver,jobserver,job}"
}

__hist_server() {
    gcloud dataproc clusters create $PHS_CLUSTER_NAME \
        --enable-component-gateway \
        --region=${REGION} --zone=$ZONE \
        --single-node \
        --master-machine-type=n4-standard-4 \
        --master-boot-disk-size=128GB \
        --bucket=$STAGING_BUCKET \
        --temp-bucket=$TEMP_BUCKET \
        --properties=yarn:yarn.nodemanager.remote-app-log-dir=gs://$GCS_BUCKET/yarn-logs \
        --properties=spark:spark.eventLog.enabled=true \
        --properties=spark:spark.eventLog.dir=gs://$GCS_BUCKET/events/spark-job-history \
        --properties=spark:spark.eventLog.rolling.enabled=true \
        --properties=spark:spark.eventLog.rolling.maxFileSize=128m \
        --properties=spark:spark.history.fs.logDirectory=gs://$GCS_BUCKET/events/spark-job-history \
        --project=$PROJECT_NAME
}

__define_auto_scale_policy() {
    gcloud dataproc autoscaling-policies import balanced-scaling-policy \
        --source=$pwd/autoscaling-policy.yml \
        --region=$REGION
}

__job_server() {
        # --secondary-worker-machine-types=t2d-standard-2 \
        # --properties=dataproc:efm.spark.shuffle=primary-worker \
    gcloud dataproc clusters create $JOB_CLUSTER_NAME \
        --enable-component-gateway \
        --region=$REGION --zone=$ZONE \
        --max-idle=$MAX_IDLE \
        --bucket=$STAGING_BUCKET \
        --temp-bucket=$TEMP_BUCKET \
        --master-machine-type=n2d-standard-2 \
        --num-masters=1 \
        --master-boot-disk-size=128GB \
        --master-boot-disk-type=pd-balanced \
        --num-master-local-ssds=1 \
        --master-local-ssd-interface=NVME \
        --autoscaling-policy=balanced-scaling-policy \
        --worker-machine-type=n2d-standard-2 \
        --num-workers=2 \
        --worker-boot-disk-size=500GB \
        --worker-boot-disk-type=pd-ssd \
        --num-worker-local-ssds=1 \
        --worker-local-ssd-interface=NVME \
        --secondary-worker-type=spot \
        --num-secondary-workers=2 \
        --secondary-worker-boot-disk-size=256GB \
        --secondary-worker-boot-disk-type=pd-balanced \
        --num-secondary-worker-local-ssds=1 \
        --secondary-worker-local-ssd-interface=NVME \
        --properties=yarn:yarn.nodemanager.remote-app-log-dir=gs://$GCS_BUCKET/yarn-logs \
        --properties=spark:spark.eventLog.enabled=true \
        --properties=spark:spark.eventLog.dir=gs://$GCS_BUCKET/events/spark-job-history \
        --properties=spark:spark.eventLog.rolling.enabled=true \
        --properties=spark:spark.eventLog.rolling.maxFileSize=128m \
        --properties=spark:spark.history.fs.logDirectory=gs://$GCS_BUCKET/events/spark-job-history \
        --properties=spark:spark.history.fs.gs.outputstream.type=FLUSHABLE_COMPOSITE \
        --properties=spark:spark.history.fs.gs.outputstream.sync.min.interval.ms=1000ms \
        --properties=spark:spark.dataproc.enhanced.optimizer.enabled=true \
        --properties=spark:spark.dataproc.enhanced.execution.enabled=true \
        --properties=dataproc:dataproc.cluster.caching.enabled=true \
        --project=$PROJECT_NAME
}

__job() {
    gcloud dataproc jobs submit spark-sql \
        --region=$REGION \
        --cluster=$JOB_CLUSTER_NAME \
        --file=$pwd/spark.sql
}

__main() {
    if [ $# -eq 0 ]
    then
        __usage
    else
        case $1 in
            histserver)
                __hist_server
                __define_auto_scale_policy
                ;;
            policy|p)
                __define_auto_scale_policy
                ;;
            jobserver)
                __job_server
                ;;
            job)
                __job
                ;;
            *)
                __usage
                ;;
        esac
    fi
}

__main $@
