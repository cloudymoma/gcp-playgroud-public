# BigQuery, number of slots usage

### 计算Job平均槽（slots）使用情况

US

```sql
SELECT
  TIMESTAMP_TRUNC(jbo.creation_time, DAY) AS usage_date,
  jbo.project_id,
  jbo.job_type,
  jbo.user_email,
  jbo.job_id,
  SAFE_DIVIDE(jbo.total_slot_ms, TIMESTAMP_DIFF(jbo.end_time ,jbo.start_time, MILLISECOND)) AS num_slots
FROM
  `region-us`.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION jbo
```

another example

```sql
SELECT
  TIMESTAMP_TRUNC(job.creation_time, DAY) AS usage_date,
  job.project_id,
  job.job_type,
  job.user_email,
  job.job_id,
  job.query,
  TIMESTAMP_DIFF(job.end_time,job.start_time, MILLISECOND) AS elapsed_ms,
  SAFE_DIVIDE(job.total_slot_ms, TIMESTAMP_DIFF(job.end_time,job.start_time, MILLISECOND)) AS num_slots
FROM
  `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT job
```

another example, filter the query of INFORMATION_SCHEMA and sort by query time desc
```sql
SELECT
  job.creation_time,
  job.project_id,
  job.job_type,
  job.user_email,
  job.job_id,
  job.query,
  TIMESTAMP_DIFF(job.end_time,job.start_time, MILLISECOND) AS elapsed_ms,
  SAFE_DIVIDE(job.total_slot_ms, TIMESTAMP_DIFF(job.end_time,job.start_time, MILLISECOND)) AS num_slots
FROM
  `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT job
WHERE
  job.query NOT LIKE '%INFORMATION_SCHEMA%'
ORDER BY
  job.creation_time DESC;
```
