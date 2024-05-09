# [LLM (Gemini Pro Vision) in BQML](https://cloud.google.com/bigquery/docs/image-analysis)

## Create an external service connection 创建外部服务连接

```shell
bq mk --connection --display_name='bq_llm_multi_con' --connection_type=CLOUD_RESOURCE --location=US bq_llm_multi_con
```

## Check connection details for use in next step

```shell
bq show --location=US --connection bq_llm_multi_con
```

## Create the remote LLM Model in BigQuery 创建远程LLM模型

```shell
bq --project_id=du-hast-mich query --nouse_cache --nouse_legacy_sql \
  'CREATE OR REPLACE MODEL `du-hast-mich.bq_llm.llm_multi_model` REMOTE WITH CONNECTION `490779752600.us.bq_llm_multi_con` OPTIONS (ENDPOINT = "gemini-pro-vision")'
```

### Do it in BigQuery console (SQL)

使用BigQuery的SQL接口创建或替换一个远程模型，这里使用的是`CREATE OR REPLACE MODEL`语句。`REMOTE WITH CONNECTION`子句指定了模型的远程连接，`OPTIONS`子句中的`ENDPOINT`指定了模型的端点。

```sql
CREATE OR REPLACE MODEL
  `du-hast-mich.bq_llm.llm_multi_model` REMOTE
WITH CONNECTION `490779752600.us.bq_llm_multi_con` OPTIONS (ENDPOINT = "gemini-pro-vision")
```

### Parameters Explained

`490779752600` is the `Project ID`, you will need to find out your own one. `490779752600`是项目ID，您需要找到自己的项目ID。

#### [`ENDPOINT`](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-remote-model#gemini-api-multimodal-models)

`gemini-pro-vision` is a `vertex_ai_llm_endpoint` model, also it is an alias fro Vertex AI `gemimi-1.0-pro-vision` versioned endpoint. The `@version` syntax isn't supported by Gemini models.

`ENDPOINT`是模型的端点，`gemini-pro-vision`是一个特定的端点，它是一个别名，代表 Vertex AI 的特定版本。

## Inference

By now, we are ready to make use of the LLM multimodal for inference. Let's re-use the `Object Table` created in our [`vector search` sample](https://github.com/cloudymoma/gcp-playgroud-public/blob/master/BigQuery/bq_embedding/readme.md#create-the-bigquery-object-table-for-images-%E5%BB%BA%E7%AB%8B%E5%AF%B9%E8%B1%A1%E8%A1%A8). We will use the table `du-hast-mich.bq_vec.obj_images` for inference. 

Now, let's ask the LLM multimodal to identify the animals in the image. 

让大语言模型的multimodal, Gemini Pro Vision, 来帮我们识别一下图片中的动物。

```sql
CREATE OR REPLACE TABLE `du-hast-mich.bq_llm.img_results` AS
(
  SELECT uri, ml_generate_text_llm_result FROM
  ML.GENERATE_TEXT (
    MODEL `du-hast-mich.bq_llm.llm_multi_model`,
    TABLE `du-hast-mich.bq_vec.obj_images`,  STRUCT(
      'Identify the animal from the image' AS PROMPT,
      TRUE AS flatten_json_output
    )
  )
)
```

Check the results 

```sql
SELECT * FROM `du-hast-mich.bq_llm.img_results` AS r
WHERE r.ml_generate_text_llm_result IS NOT NULL
```

## GCP Permission issues

Please consult [this](https://cloud.google.com/bigquery/docs/generate-text-tutorial#grant-permissions) official doc for permissions setup.

Basically, simply grant your *Bigquery Serverice Account* access to your **VertexAI** should do the trick.

1. You should be able to find out he **Service Account** from the Bigquery error information
2. Navigate to [IAM & Admin](https://pantheon.corp.google.com/iam-admin/iam)
3. Add the service account and grant *Vertex AI User* role
