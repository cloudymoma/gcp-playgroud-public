# Query BigQuery Tables

Simple version

```sql
DECLARE dataset_names ARRAY<STRING>;

SET dataset_names = (
    SELECT ARRAY_AGG(SCHEMA_NAME) FROM `region-us.INFORMATION_SCHEMA.SCHEMATA`
);

EXECUTE IMMEDIATE (
    SELECT STRING_AGG(
        (SELECT """
            SELECT project_id, dataset_id, table_id, row_count, size_bytes 
            FROM `""" || s || 
            """.__TABLES__`"""), 
            " UNION ALL ")
    FROM UNNEST(dataset_names) AS s);
```

If you have many tables

```sql
DECLARE dataset_names ARRAY<STRING>;
DECLARE batch ARRAY<STRING>;
DECLARE batch_size INT64 DEFAULT 25;

CREATE TEMP TABLE results (
    project_id STRING,
    dataset_id STRING,
    table_id STRING,
    row_count INT64,
    size_bytes INT64
);

SET dataset_names = (
        SELECT ARRAY_AGG(SCHEMA_NAME) 
        FROM `region-us.INFORMATION_SCHEMA.SCHEMATA`
    );

LOOP
    IF ARRAY_LENGTH(dataset_names) < 1 THEN 
        LEAVE;
    END IF;

    SET batch = (
        SELECT ARRAY_AGG(d) 
        FROM UNNEST(dataset_names) AS d WITH OFFSET i 
        WHERE i < batch_size);

    EXECUTE IMMEDIATE (
        SELECT """INSERT INTO results """ 
            || STRING_AGG(
                    (SELECT """
                        SELECT project_id, dataset_id, table_id, row_count, size_bytes 
                        FROM `""" || s || """.__TABLES__`"""), 
                " UNION ALL ")
        FROM UNNEST(batch) AS s);

    SET dataset_names = (
        SELECT ARRAY_AGG(d) 
        FROM UNNEST(dataset_names) AS d
        WHERE d NOT IN (SELECT * FROM UNNEST(batch)));
        
END LOOP; 

SELECT * FROM results;
```

query [`table_storage`](https://cloud.google.com/bigquery/docs/information-schema-table-storage#schema) meta for detailed storage information

[Forecast storage billing](https://cloud.google.com/bigquery/docs/information-schema-table-storage#forecast_storage_billing)
