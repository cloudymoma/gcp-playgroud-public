# [LLM (Gemini Pro) in BQML](https://cloud.google.com/bigquery/docs/generate-text)

## Create an external service connection 创建外部服务连接

```shell
bq mk --connection --display_name='bq_llm_con' --connection_type=CLOUD_RESOURCE --location=US bq_llm_con
```

## Check connection details for use in next step

```shell
bq show --location=US --connection bq_llm_con
```

## Create the remote LLM Model in BigQuery 创建远程LLM模型

```shell
bq --project_id=du-hast-mich query --nouse_cache --nouse_legacy_sql  'CREATE OR REPLACE MODEL `du-hast-mich.bq_llm.llm_model` REMOTE WITH CONNECTION `490779752600.us.bq_llm_con` OPTIONS (ENDPOINT = "gemini-pro")
```

### Do it in BigQuery console (SQL)

使用BigQuery的SQL接口创建或替换一个远程模型，这里使用的是`CREATE OR REPLACE MODEL`语句。`REMOTE WITH CONNECTION`子句指定了模型的远程连接，`OPTIONS`子句中的`ENDPOINT`指定了模型的端点。

```sql
CREATE OR REPLACE MODEL
  `du-hast-mich.bq_llm.llm_model` REMOTE
WITH CONNECTION `490779752600.us.bq_llm_con` OPTIONS (ENDPOINT = "gemini-pro")
```

### Parameters Explained

`490779752600` is the `Project ID`, you will need to find out your own one. `490779752600`是项目ID，您需要找到自己的项目ID。

#### [`ENDPOINT`](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-remote-model#gemini-api-text-models)

`gemini-pro` is a `vertex_ai_llm_endpoint` model, also it is an alias fro Vertex AI `gemimi-1.0-pro` versioned endpoint. The `@version` syntax isn't supported by Gemini models.

`ENDPOINT`是模型的端点，`gemini-pro`是一个特定的端点，它是一个别名，代表 Vertex AI 的特定版本。

## Inference

### CMD

```shell
bq --project_id=du-hast-mich query --nouse_cache --nouse_legacy_sql 'SELECT * from ML.GENERATE_TEXT(MODEL bq_llm.llm_model, (SELECT "Give a short description of a machine learning model" as prompt), STRUCT(0.2 AS temperature, 128 AS max_output_tokens, 0.8 AS top_p, 40 AS top_k, 1 AS candidate_count))'
```

### SQL

#### A Simple Example

```sql
SELECT * from ML.GENERATE_TEXT(MODEL bq_llm.llm_model, 
(SELECT "Give a short description of a machine learning model" as prompt), 
STRUCT(0.2 AS temperature, 
  128 AS max_output_tokens, 
  0.8 AS top_p, 
  40 AS top_k, 
  1 AS candidate_count))
```

#### Data Enrichment

```sql
SELECT * FROM
ML.GENERATE_TEXT (
MODEL `bq_llm.llm_model`,
(SELECT CONCAT (“Give the country name for city: ”, city) AS prompt
FROM t_city),
STRUCT ( 0.2 AS temperature,
  1024 AS max_output_tokens,
  0.8 AS top_p,
  40 AS top_k))
```

suppose `city` is a column in the `t_city` table

## GCP Permission issues

Please consult [this](https://cloud.google.com/bigquery/docs/generate-text-tutorial#grant-permissions) official doc for permissions setup.

Basically, simply grant your *Bigquery Serverice Account* access to your **VertexAI** should do the trick.

1. You should be able to find out he **Service Account** from the Bigquery error information
2. Navigate to [IAM & Admin](https://pantheon.corp.google.com/iam-admin/iam)
3. Add the service account and grant *Vertex AI User* role
