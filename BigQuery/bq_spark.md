# Run Spark in BigQuery Studio

## [Pricing](https://cloud.google.com/bigquery/docs/spark-procedures#pricing)

For comprehensive spark on Dataproc use cases, please consult [here](https://github.com/cloudymoma/dataproc-scala)

## (Optional) Create a Dataproc Metastore in `us-central1` with endpoint protocol `grpc` and service ID `dingometa`

[documentation](https://cloud.google.com/sdk/gcloud/reference/metastore/services/create)

```shell
gcloud metastore services create dingometa \
    --project=du-hast-mich \
    --location=us-central1 \
    --tier=DEVELOPER \
    --endpoint-protocol=GRPC \
    --hive-metastore-version=3.1.2 \
    --network=default 
```

## (Optional) Create a Dataproc Persistent History Server (PHS) cluster

[documentation](https://cloud.google.com/dataproc/docs/concepts/jobs/history-server#create_a_phs_cluster)

suppose you have a bucket named `dingoproc` is ready or you need to create one.

we defined the properties delimiter in the parameter by using `^delimiter^` notation, this could be helpfule if you have `,` commas in your property values.

```shell
gcloud dataproc clusters create dingohist \
    --project=du-hast-mich \
    --region=us-central1 \
    --single-node \
    --enable-component-gateway \
    --properties '^#^spark:spark.history.fs.logDirectory=gs://dingoproc/events/spark-job-history#spark:spark.history.custom.executor.log.url.applyIncompleteApplication=false' \
    --properties=yarn:yarn.nodemanager.remote-app-log-dir=gs://dingoproc/yarn-logs \
    --properties=spark:spark.eventLog.enabled=true \
    --properties=spark:spark.eventLog.dir=gs://dingoproc/events/spark-job-history \
    --properties=spark:spark.eventLog.rolling.enabled=true \
    --properties=spark:spark.eventLog.rolling.maxFileSize=128m 
```

## Create a BigQuery connection to the Dataproc Cluster and Dataproc Metastore

[documentation](https://cloud.google.com/bigquery/docs/connect-to-spark#create-spark-connection)

```shell
bq mk --connection --display_name='bq_spark' --connection_type='SPARK' \
    --properties='{
        "metastoreServiceConfig": {"metastoreService": "projects/du-hast-mich/locations/us-central1/services/dingometa"},
        "sparkHistoryServerConfig": {"dataprocCluster": "projects/du-hast-mich/regions/us-central1/clusters/dingohist"}
    }' \
    --project_id=du-hast-mich \
    --location=US \
    bq_spark
```

check the connection status

```shell
bq show --location=US --connection du-hast-mich.US.bq_spark
```

## [Grant access to the service account](https://cloud.google.com/bigquery/docs/connect-to-spark#grant-access)

```shell
export SERVICE_ACCOUNT=`bq show --connection --project_id=du-hast-mich --format=json us.bq_spark | jq -r '.spark.serviceAccountId'`
export PROJECT_ID="du-hast-mich"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/metastore.metadataViewer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/dataproc.viewer"
```

## Create the spark stored procedure

[documentation](https://cloud.google.com/bigquery/docs/spark-procedures#create-spark-procedure)

```sql
-- Create the SPARK stored procedure
CREATE OR REPLACE PROCEDURE `du-hast-mich.bq_spark`.spark_proc()
WITH CONNECTION `du-hast-mich.us.bq_spark`
OPTIONS(
  engine="SPARK", 
  runtime_version="1.2",
  properties=[
    ("spark.executor.cores", "4"),
    ("spark.executor.memory", "25g"),
    ("spark.executor.memoryOverhead", "4g"),
    ("spark.driver.cores", "4"),
    ("spark.driver.memory", "25g"),
    ("spark.driver.memoryOverhead", "4g"),
    ("spark.dynamicAllocation.enabled", "true"),
    ("spark.dynamicAllocation.initialExecutors", "2"),
    ("spark.dynamicAllocation.minExecutors", "2"),
    ("spark.dynamicAllocation.maxExecutors", "100"),
    ("spark.dynamicAllocation.executorAllocationRatio", "1.0"),
    ("spark.decommission.maxRatio", "0.3"),
    ("spark.reducer.fetchMigratedShuffle.enabled", "true"),
    ("spark.dataproc.scaling.version", "2"),
    ("spark.dataproc.driver.compute.tier", "premium"),
    ("spark.dataproc.executor.compute.tier", "premium"),
    ("spark.dataproc.driver.disk.tier", "premium"),
    ("spark.dataproc.driver.disk.size", "375g"),
    ("spark.dataproc.executor.disk.tier", "premium"),
    ("spark.dataproc.executor.disk.size", "375g"),
    ("spark.sql.adaptive.enabled", "true"),
    ("spark.sql.adaptive.coalescePartitions.enabled", "true"),
    ("spark.sql.adaptive.skewJoin.enabled", "true"),
    ("spark.dataproc.enhanced.optimizer.enabled", "true"),
    ("spark.dataproc.enhanced.execution.enabled", "true"),
    ("spark.network.timeout", "300s"),
    ("spark.executor.heartbeatInterval", "60s"),
    ("spark.speculation", "true")
  ]
)
LANGUAGE PYTHON AS R"""
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("spark-bigquery-demo-sql").getOrCreate()

# Load data from BigQuery.
words = spark.read.format("bigquery") \
  .option("table", "bigquery-public-data:samples.shakespeare") \
  .load()
words.createOrReplaceTempView("words")

# Perform word count.
word_count = words.select('word', 'word_count').groupBy('word').sum('word_count').withColumnRenamed("sum(word_count)", "sum_word_count")
word_count.show()
word_count.printSchema()

# Saving the data to BigQuery
word_count.write.format("bigquery") \
  .option("writeMethod", "direct") \
  .save("bq_spark.wordcount_output")
""";

-- delete the output table if exists
DROP TABLE IF EXISTS `du-hast-mich.bq_spark.wordcount_output`;

-- run the stored procedure
CALL `du-hast-mich.bq_spark`.spark_proc();

-- inspect the output
SELECT * FROM `du-hast-mich.bq_spark.wordcount_output`
ORDER BY sum_word_count DESC
LIMIT 100;
```

## Call the Spark Stored Procedure

```sql
CALL `du-hast-mich.bq_spark`.spark_proc();
```

For more advanced use cases, e.g. passing input parameters, please see [here](https://cloud.google.com/bigquery/docs/spark-procedures#pass-input-parameter)
