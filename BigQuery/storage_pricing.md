# BigQuery Storage Pricing Comparisons

比较BigQuery在每个Dataset（数据集）的物理存储和逻辑存储的价格

```sql
DECLARE active_logical_gib_price FLOAT64 DEFAULT 0.02;
DECLARE long_term_logical_gib_price FLOAT64 DEFAULT 0.01;
DECLARE active_physical_gib_price FLOAT64 DEFAULT 0.04;
DECLARE long_term_physical_gib_price FLOAT64 DEFAULT 0.02;

WITH
 storage_sizes AS (
   SELECT
     table_schema AS dataset_name,
     -- Logical
     SUM(active_logical_bytes) / power(1024, 3) AS active_logical_gib,
     SUM(long_term_logical_bytes) / power(1024, 3) AS long_term_logical_gib,
     -- Physical
     SUM(active_physical_bytes) / power(1024, 3) AS active_physical_gib,
     SUM(active_physical_bytes - time_travel_physical_bytes - fail_safe_physical_bytes) / power(1024, 3) AS active_no_tt_no_fs_physical_gib,
     SUM(long_term_physical_bytes) / power(1024, 3) AS long_term_physical_gib,
     -- Restorable previously deleted physical
     SUM(time_travel_physical_bytes) / power(1024, 3) AS time_travel_physical_gib,
     SUM(fail_safe_physical_bytes) / power(1024, 3) AS fail_safe_physical_gib,
   FROM
     `region-us`.INFORMATION_SCHEMA.TABLE_STORAGE_BY_PROJECT
   WHERE total_logical_bytes > 0
     AND total_physical_bytes > 0
     -- Base the forecast on base tables only for highest precision results
     AND table_type  = 'BASE TABLE'
     GROUP BY 1
 )
SELECT
  dataset_name,
  -- Logical
  ROUND(
    ROUND(active_logical_gib * active_logical_gib_price, 2) + 
    ROUND(long_term_logical_gib * long_term_logical_gib_price, 2)
  , 2) as total_logical_cost,
  -- Physical
  ROUND(
    ROUND(active_physical_gib * active_physical_gib_price, 2) +
    ROUND(long_term_physical_gib * long_term_physical_gib_price, 2)
  , 2) as total_physical_cost
FROM
  storage_sizes
```

[TABLE_STORAGE view](https://cloud.google.com/bigquery/docs/information-schema-table-storage)

API [Method: tables.get](https://cloud.google.com/bigquery/docs/reference/rest/v2/tables/get)
