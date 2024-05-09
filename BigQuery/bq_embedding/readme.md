# Vector Search in BigQuery ML (BQML)

使用BigQuery对非结构化数据(例如：图片，长文本)进行向量搜索。

With external TensorFlow models, please refer to [here](https://cloud.google.com/bigquery/docs/generate-embedding-with-tensorflow-models)

## Create an external service connection

```shell
bq mk --connection --display_name='bq_vec_con' --connection_type=CLOUD_RESOURCE --location=US bq_vec_con
```

## Check connection details for use in next step

```shell
bq show --location=US --connection bq_vec_con
```

## Create the remote Model in BigQuery 建立模型，用来推理生成embeddings

- `textembedding-gecko@*`
- `multimodalembedding@*`

`bq` command in shell 使用命令行

```shell
bq --project_id=du-hast-mich query --nouse_cache --nouse_legacy_sql \
  'CREATE OR REPLACE MODEL `du-hast-mich.bq_vec.vec_model` REMOTE WITH CONNECTION `490779752600.us.bq_vec_con` OPTIONS (ENDPOINT = "multimodalembedding@latest")'
```

or `SQL` in BigQuery console 在BigQuery Studio UI里使用`SQL`

```sql
CREATE OR REPLACE MODEL
  `du-hast-mich.bq_vec.vec_model` REMOTE
WITH CONNECTION `490779752600.us.bq_vec_con` OPTIONS (ENDPOINT = "multimodalembedding@latest")
```

**HINT** change the version `@latest` to `@001` or other specific version instead of alias in case it doesn't work.

## Create the BigQuery Object table for images 建立对象表

**[Optional]** In case you do not have any image data. I use the ones from [kaggle](https://www.kaggle.com/datasets/iamsouravbanerjee/animal-image-dataset-90-different-animals). Simply download the package then extract the package and put to GCS straight away. e.g. I put the entire `animals` folder under `gs://vecsearch` bucket in the following example.

```shell
bq mk --connection --display_name='bq_img_con' --connection_type=CLOUD_RESOURCE --location=US bq_img_con
```

```sql
CREATE OR REPLACE EXTERNAL TABLE `du-hast-mich.bq_vec.obj_images`
WITH CONNECTION `du-hast-mich.us.bq_img_con`
OPTIONS(
  object_metadata = 'SIMPLE',
  uris = ['gs://vecsearch/*']
);
```

Checkout the content of the object table 查看对象表

```sql
SELECT * FROM `du-hast-mich.bq_vec.obj_images` LIMIT 100
```

## Generate embeddings from the ML model 使用模型生成embedding

This step may take a while depends on how many images you have. 

```sql
CREATE OR REPLACE TABLE `du-hast-mich.bq_vec.embeddings_table` AS 
SELECT * FROM  ML.GENERATE_EMBEDDING(
   MODEL `du-hast-mich.bq_vec.vec_model`,
   TABLE `du-hast-mich.bq_vec.obj_images`
);
```

Inspect the embedding table once done 查看embedding表

```sql
SELECT * FROM `du-hast-mich.bq_vec.embeddings_table` LIMIT 100
```

## Create an Index from the BigQuery Table 建立索引

- Specifiying `IVF` builds the vector index as inverted file index (IVF)
- Supported distances are `EUCLIDEAN` and `COSINE`. `EUCLIDEAN` is the default.

```sql
CREATE VECTOR INDEX vec_index 
  ON `du-hast-mich.bq_vec.embeddings_table`(ml_generate_embedding_result)
OPTIONS(index_type = 'IVF', distance_type = 'COSINE',
  ivf_options = '{"num_lists": 2500}');
```

### [Check the indices status 查看索引状态](https://cloud.google.com/bigquery/docs/vector-index)

1. all active vector indexes on tables in the dataset `bq_vec`, located in the project `du-hast-mich`. 

```sql
SELECT table_name, index_name, ddl, coverage_percentage
FROM `du-hast-mich.bq_vec.INFORMATION_SCHEMA.VECTOR_INDEXES`
WHERE index_status = 'ACTIVE';
```

2. columns that have vector indexes

```sql
SELECT table_name, index_name, index_column_name, index_field_path
FROM `du-hast-mich.bq_vec.INFORMATION_SCHEMA.VECTOR_INDEX_COLUMNS`;
```

3. vector index options

```sql
SELECT table_name, index_name, option_name, option_type, option_value
FROM `du-hast-mich.bq_vec.INFORMATION_SCHEMA.VECTOR_INDEX_OPTIONS`;
```

## Perform a Vector Search in BigQuery 在BigQuery中执行向量搜索

### (Optional) Create a table as query table

```sql
create or replace table `du-hast-mich.bq_vec.embeddings_table2` as
select * from `du-hast-mich.bq_vec.embeddings_table` limit 10;
```

### Vector Search of ANN 查询最近邻

```sql
SELECT query.uri as search_uri, 
  base.uri as data_uri, 
  distance
FROM
 VECTOR_SEARCH(
   TABLE `du-hast-mich.bq_vec.embeddings_table`,'ml_generate_embedding_result',
   TABLE `du-hast-mich.bq_vec.embeddings_table2`,
   top_k => 5,
   distance_type => 'COSINE',
   options => '{"fraction_lists_to_search": 0.005}');
```

### Vector Search brute force

```sql
-- Vector Search brute force
SELECT query.uri as search_uri, 
  base.uri as data_uri, 
  distance
FROM
 VECTOR_SEARCH(
   TABLE `du-hast-mich.bq_vec.embeddings_table`,'ml_generate_embedding_result',
   TABLE `du-hast-mich.bq_vec.embeddings_table2`,
   top_k => 5,
   distance_type => 'COSINE',
   options => '{use_brute_force : true}');
```

## Evaluate recall 评估召回

```sql
with 
approx_results as (
SELECT query.uri as search_uri, 
  base.uri as data_uri, 
  distance
FROM
 VECTOR_SEARCH(
   TABLE `du-hast-mich.bq_vec.embeddings_table`,'ml_generate_embedding_result',
   TABLE `du-hast-mich.bq_vec.embeddings_table2`,
   top_k => 5,
   distance_type => 'COSINE',
   options => '{"fraction_lists_to_search": 0.005}')
), 
exact_results as (
SELECT query.uri as search_uri, 
  base.uri as data_uri, 
  distance
FROM
 VECTOR_SEARCH(
   TABLE `du-hast-mich.bq_vec.embeddings_table`,'ml_generate_embedding_result',
   TABLE `du-hast-mich.bq_vec.embeddings_table2`,
   top_k => 5,
   distance_type => 'COSINE',
   options => '{use_brute_force : true}')
)

SELECT
  a.search_uri,
  SUM(CASE WHEN a.data_uri = e.data_uri THEN 1 ELSE 0 END) / 5 AS recall
FROM exact_results e LEFT JOIN approx_results a
  ON e.search_uri = a.search_uri
GROUP BY a.search_uri
```

If the recall is lower than you would like, you can increase the `fraction_lists_to_search` value, with the downside of potentially higher latency and resource usage. To tune your vector search, you can try multiple runs of `VECTOR_SEARCH` with different argument values, save the results to tables, and then compare the results.

## GCP Permission issues

Please consult [this](https://cloud.google.com/bigquery/docs/generate-text-tutorial#grant-permissions) official doc for permissions setup.

Basically, simply grant your *Bigquery Serverice Account* access to your **VertexAI** should do the trick.

1. You should be able to find out he **Service Account** from the Bigquery error information
2. Navigate to [IAM & Admin](https://pantheon.corp.google.com/iam-admin/iam)
3. Add the service account and grant *Vertex AI User* role
4. You may need to grant the BQ service account with *Cloud Sotrage Object Viewer* role for accessing the images stored in Cloud Storage.
