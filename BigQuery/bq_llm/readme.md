# [LLM in BQML](https://cloud.google.com/bigquery/docs/generate-text)

## Create an external service connection

```
bq mk --connection --display_name='bq_llm_con' --connection_type=CLOUD_RESOURCE --location=US bq_llm_con
```

## Check connection details for use in next step

```
bq show --location=US --connection bq_llm_con
```

## Create the remote LLM Model in BigQuery

```
bq --project_id=du-hast-mich query --nouse_cache --nouse_legacy_sql  'CREATE OR REPLACE MODEL `du-hast-mich.bq_llm.llm_model` REMOTE WITH CONNECTION `490779752600.us.bq_llm_con` OPTIONS (remote_service_type = "CLOUD_AI_LARGE_LANGUAGE_MODEL_V1")
```

## Inference

### CMD

```
bq --project_id=du-hast-mich query --nouse_cache --nouse_legacy_sql 'SELECT * from ML.GENERATE_TEXT(MODEL bq_llm.llm_model, (SELECT "Give a short description of a machine learning model" as prompt), STRUCT(0.2 AS temperature, 128 AS max_output_tokens, 0.8 AS top_p, 40 AS top_k, 1 AS candidate_count))'
```

### SQL

```
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
