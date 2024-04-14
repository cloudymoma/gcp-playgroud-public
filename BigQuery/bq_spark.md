# Run Spark in BigQuery Studio

## [Pricing](https://cloud.google.com/bigquery/docs/spark-procedures#pricing)

## Create a Dataproc Metastore in `us-central1` with endpoint protocol `grpc` and service ID `grpc-metastore`

[documentation](https://cloud.google.com/sdk/gcloud/reference/metastore/services/create)

```shell
gcloud metastore services create grpc-metastore \
    --location=us-central1 \
    --endpoint-protocol=grpc
```

## Create a Dataproc Persistent History Server (PHS) cluster

[documentation](https://cloud.google.com/dataproc/docs/concepts/jobs/history-server#create_a_phs_cluster)

suppose you have a bucket named `dingoproc` is ready or you need to create one.

we defined the properties delimiter in the parameter by using `^delimiter^` notation, this could be helpfule if you have `,` commas in your property values.

```shell
gcloud dataproc clusters create dingohist \
    --project=du-hast-mich \
    --region=us-central1 \
    --single-node \
    --enable-component-gateway \
    --properties '^#^spark:spark.history.fs.logDirectory=gs://dingoproc/*/spark-job-history#spark:spark.history.custom.executor.log.url.applyIncompleteApplication=false'
```

## Create a BigQuery connection to the Dataproc Cluster and Dataproc Metastore

[documentation](https://cloud.google.com/bigquery/docs/connect-to-spark#create-spark-connection)

```shell
bq mk --connection --display_name='bq_spark' --connection_type='SPARK' \
    --properties='{
        "metastoreServiceConfig": {"metastoreService": "projects/du-hast-mich/locations/us-central1/services/grpc-metastore"},
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

## Create the spark stored procedure

[documentation](https://cloud.google.com/bigquery/docs/spark-procedures#create-spark-procedure)

```sql
CREATE OR REPLACE PROCEDURE `du-hast-mich.bq_spark`.spark_proc()
WITH CONNECTION `du-hast-mich.us.bq_spark`
OPTIONS(engine="SPARK", runtime_version="2.2")
LANGUAGE PYTHON AS R"""
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("spark-bigquery-demo").getOrCreate()

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
"""
```

## Call the Spark Stored Procedure

```sql
CALL `du-hast-mich.bq_spark`.spark_proc();
```

For more advanced use cases, e.g. passing input parameters, please see [here](https://cloud.google.com/bigquery/docs/spark-procedures#pass-input-parameter)