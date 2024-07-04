# Start using dataproc

## PHS (Persistent History Server) server

```shell
export PHS_CLUSTER_NAME=<CLUSTER NAME>
export REGION=<REGION>
export ZONE=<ZONE>
export GCS_BUCKET=<GCS BUCKET>
export PROJECT_NAME=<PROJECT NAME>

gcloud dataproc clusters create $PHS_CLUSTER_NAME \
  --enable-component-gateway \
  --region ${REGION} --zone $ZONE \
  --single-node \
  --master-machine-type n2-highmem-4 \
  --master-boot-disk-size 500 \
  --image-version 2.0-debian10 \
  --properties \
  yarn:yarn.nodemanager.remote-app-log-dir=gs://$GCS_BUCKET/yarn-logs,\
  mapred:mapreduce.jobhistory.done-dir=gs://$GCS_BUCKET/events/mapreduce-job-history/done,\
  mapred:mapreduce.jobhistory.intermediate-done-dir=gs://$GCS_BUCKET/events/mapreduce-job-history/intermediate-done,\
  spark:spark.eventLog.dir=gs://$GCS_BUCKET/events/spark-job-history,\
  spark:spark.history.fs.logDirectory=gs://$GCS_BUCKET/events/spark-job-history,\
  spark:SPARK_DAEMON_MEMORY=16000m,\
  spark:spark.history.custom.executor.log.url.applyIncompleteApplication=false,\
  spark:spark.history.custom.executor.log.url={{YARN_LOG_SERVER_URL}}/{{NM_HOST}}:{{NM_PORT}}/{{CONTAINER_ID}}/{{CONTAINER_ID}}/{{USER}}/{{FILE_NAME}} \
  --project $PROJECT_NAME
```

## Ephemeral job server

```shell
export JOB_CLUSTER_NAME=<CLUSTER NAME>

gcloud dataproc clusters create $JOB_CLUSTER_NAME \
  --enable-component-gateway \
  --region $REGION --zone $ZONE \
  --master-machine-type n1-standard-4 \
  --master-boot-disk-size 500 --num-workers 2 \
  --worker-machine-type n1-standard-4 \
  --worker-boot-disk-size 500 \
  --image-version 2.0-debian10 \
  --properties yarn:yarn.nodemanager.remote-app-log-dir=gs://$GCS_BUCKET/yarn-logs,\
  mapred:mapreduce.jobhistory.done-dir=gs://$GCS_BUCKET/events/mapreduce-job-history/done,\
  mapred:mapreduce.jobhistory.intermediate-done-dir=gs://$GCS_BUCKET/events/mapreduce-job-history/intermediate-done,\
  spark:spark.eventLog.dir=gs://$GCS_BUCKET/events/spark-job-history,\
  spark:spark.history.fs.logDirectory=gs://$GCS_BUCKET/events/spark-job-history,\
  spark:spark.history.fs.gs.outputstream.type=FLUSHABLE_COMPOSITE,\
  spark:spark.history.fs.gs.outputstream.sync.min.interval.ms=1000ms \
  --project $PROJECT_NAME
```
