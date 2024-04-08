# Google Trends data in BigQuery public dataset 

谷歌搜索热词和飙升榜，使用BigQuery公共数据集查询

US, 美国

```sql
WITH rising AS (
  SELECT
    week,
    refresh_date,
    ARRAY_AGG(DISTINCT term) AS terms
  FROM `bigquery-public-data.google_trends.top_rising_terms`
  WHERE refresh_date = DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)
  GROUP BY
    week,
    refresh_date)
 
SELECT
  top.refresh_date,
  top.week,
  top.dma_name,
  top.dma_id,
  top.term AS top_term,
  top.score AS top_score,
  top.rank AS top_rank,
  rising.terms AS rising_terms,
FROM `bigquery-public-data.google_trends.top_terms` top
JOIN rising
ON
  top.refresh_date = rising.refresh_date
  AND top.week = rising.week
ORDER BY
  week desc, refresh_date desc;
```

Worldwide, e.g. Japan, Tokyo

世界范围，例如：日本，东京

```sql
WITH int_rising AS (
  SELECT
    week,
    refresh_date,
    ARRAY_AGG(DISTINCT term) AS terms
  FROM `bigquery-public-data.google_trends.international_top_rising_terms`
  WHERE refresh_date = DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)
    AND country_name = "Japan" AND region_name = "Tokyo"
  GROUP BY
    week,
    refresh_date)
 
SELECT
  top.refresh_date,
  top.week,
  top.country_name,
  top.country_code,
  top.region_name,
  top.region_code,
  top.term AS top_term,
  top.score AS top_score,
  top.rank AS top_rank,
  int_rising.terms AS rising_terms,
FROM `bigquery-public-data.google_trends.international_top_terms` top
JOIN int_rising
ON
  top.refresh_date = int_rising.refresh_date
  AND top.week = int_rising.week
WHERE top.country_name = "Japan" AND top.region_name = "Tokyo"
ORDER BY
  week desc, refresh_date desc;
```