## Import data from BigQuery by using Dataflow template

[Dataflow templates code repo](https://github.com/GoogleCloudPlatform/DataflowTemplates), templates can be either fired from commandline by using `mvn` task or in the [GCP console](https://console.cloud.google.com/dataflow/jobs)

### Step 1 Transform the BigQuery table accordingly

According to the [code](https://github.com/GoogleCloudPlatform/DataflowTemplates/blob/master/src/main/java/com/google/cloud/teleport/bigtable/AvroToBigtable.java#L163)

```java
// ---- snippets
Pipeline pipeline = Pipeline.create(PipelineUtils.tweakPipelineOptions(options));

    BigtableIO.Write write =
        BigtableIO.write()
            .withProjectId(options.getBigtableProjectId())
            .withInstanceId(options.getBigtableInstanceId())
            .withTableId(options.getBigtableTableId());

    pipeline
        .apply("Read from Avro", AvroIO.read(BigtableRow.class).from(options.getInputFilePattern()))
        .apply(
            "Transform to Bigtable",
            ParDo.of(
                AvroToBigtableFn.createWithSplitLargeRows(
                    options.getSplitLargeRows(), MAX_MUTATIONS_PER_ROW)))
        .apply("Write to Bigtable", write);

    return pipeline.run();
// ---- end snippets

// ---- ............... ----

// ---- snippets
@ProcessElement
    public void processElement(
        @Element BigtableRow row, OutputReceiver<KV<ByteString, Iterable<Mutation>>> out) {
      ByteString key = toByteString(row.getKey());
      // BulkMutation doesn't split rows. Currently, if a single row contains more than 100,000
      // mutations, the service will fail the request.
      ImmutableList.Builder<Mutation> mutations = ImmutableList.builder();
// ---- end snippets
```

`mvn compile` should have `./target/generated-sources/avro/com/google/cloud/teleport/bigtable/BigtableRow.java` generated if you interested in the detailed code implementation.

and the dedicated avro [schema](https://github.com/GoogleCloudPlatform/DataflowTemplates/blob/master/src/main/resources/schema/avro/bigtable.avsc) file for Bigtable

```json
{
    "name" : "BigtableRow",
    "type" : "record",
    "namespace" : "com.google.cloud.teleport.bigtable",
    "fields" : [
      { "name" : "key", "type" : "bytes"},
      { "name" : "cells",
        "type" : {
          "type" : "array",
          "items": {
            "name": "BigtableCell",
            "type": "record",
            "fields": [
              { "name" : "family", "type" : "string"},
              { "name" : "qualifier", "type" : "bytes"},
              { "name" : "timestamp", "type" : "long", "logicalType" : "timestamp-micros"},
              { "name" : "value", "type" : "bytes"}
            ]
          }
        }
      }
   ]
}
```

We have created a middle table in BigQuery, which you may need to transform your data in the same way so that fits the Bigtable schema hence can be smoothly imported.

```sql
-- Common SQL, but replace the project, dataset & table according to your environment
drop table if exists `google.com:bin-wus-learning-center.demo.events4bt`;

create table if not exists `google.com:bin-wus-learning-center.demo.events4bt`
(
    key BYTES,
    cells ARRAY<STRUCT<family STRING, qualifier BYTES, `timestamp` TIMESTAMP, value BYTES>> 
);

-- dummy data just for test

insert into `google.com:bin-wus-learning-center.demo.events4bt` (`key`, `cells`) 
values 
(CAST("abc" AS BYTES), 
    [STRUCT("fa" as family, cast("cola" as BYTES) as qualifier, TIMESTAMP_SECONDS(1632739777) as `timestamp`, cast("vala" as BYTES) as value), 
    STRUCT("fa" as family, cast("colc" as BYTES) as qualifier, TIMESTAMP_SECONDS(1632739777) as `timestamp`, cast("valc" as BYTES) as value),
    STRUCT("fb" as family, cast("colb" as BYTES) as qualifier, TIMESTAMP_SECONDS(1632739777) as `timestamp`, cast("valb" as BYTES) as value)]),
(CAST("xyz" AS BYTES), 
    [STRUCT("fa" as family, cast("cola" as BYTES) as qualifier, TIMESTAMP_SECONDS(1632739777) as `timestamp`, cast("valx" as BYTES) as value), 
    STRUCT("fb" as family, cast("colb" as BYTES) as qualifier, TIMESTAMP_SECONDS(1632739777) as `timestamp`, cast("valy" as BYTES) as value),
    STRUCT("fb" as family, cast("colc" as BYTES) as qualifier, TIMESTAMP_SECONDS(1632739777) as `timestamp`, cast("valz" as BYTES) as value)])
```

### Step 2 Export BigQuery data to GCS as avro format

This can be simply done in [BigQuery UI](https://console.cloud.google.com/bigquery). On the top right corner when you selected the table, simply configure the output path. e.g. `gs://bindiego/bq2avro/out.avro`

### Step 3 Prepare Bigtable table and column families using `cbt` command line tool provided by [Cloud Client SDK](https://cloud.google.com/sdk/docs/quickstart)

Remember to replace the parameters, like region or name of the instance & tables etc. accordingly

1. Create Bigtable instance

`cbt createinstance bigbase "Bigbase" bigbaby asia-east1-a 1 SSD`

2. Create the targeting table & column families

`cbt createtable fromavro && cbt createfamily fromavro fa && cbt createfamily fromavro fb`

### Step 4 Launch the dataflow template job

Simply launch the job from the [Dataflow UI](https://console.cloud.google.com/dataflow/jobs) by choosing the `Avro Files on Cloud Storage to Cloud Bigtable` template and configure the pipeline options accordingly then hit `RUN JOB` button. 

After the job's done, simply check the data in Bigtable, as the sample data in this example we should see

```
cbt read fromavro
```
Output:
```
----------------------------------------
abc
  fa:cola                                  @ 2021/09/27-10:49:37.000000
    "vala"
  fa:colc                                  @ 2021/09/27-10:49:37.000000
    "valc"
  fb:colb                                  @ 2021/09/27-10:49:37.000000
    "valb"
----------------------------------------
xyz
  fa:cola                                  @ 2021/09/27-10:49:37.000000
    "valx"
  fb:colb                                  @ 2021/09/27-10:49:37.000000
    "valy"
  fb:colc                                  @ 2021/09/27-10:49:37.000000
```
