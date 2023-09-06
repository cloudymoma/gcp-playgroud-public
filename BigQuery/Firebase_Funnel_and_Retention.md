# Firebase data in Bigquery

Funnel & Retention

[Sample](https://gist.github.com/bindiego/cb03ce54377fee06f54a43a108bdd4f2)

## Firebase data in BigQuery

### Closed Funnel 封闭漏斗

user_pseudo_id is not a session id. It´s a unique ID "by app install". So as long as a user uses the same App-Instance ("Installation") without reinstalling it, the user_pseudo_id stays the same. It also don´t change on App update. But it will change if you uninstall and reinstall the app.

```sql
-- query all event where event_name is session_start or add_to_cart. 
-- also fetch user_pseduo_id and event_timestamp columns 
SELECT event_name, user_pseudo_id , event_timestamp 
FROM `firebase-public-project.analytics_153293282.events_20200308` 
WHERE (event_name = "session_start" OR event_name = "level_start") 
ORDER BY 2,3;
```

next step for the funnel events
```sql
SELECT event_name, user_pseudo_id , event_timestamp, 
-- add “next_event” -  
LEAD(event_name, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_event 
FROM `firebase-public-project.analytics_153293282.events_20200308` 
WHERE (event_name = "session_start" OR event_name = "level_start") 
ORDER BY 2,3;
```

```sql
-- define funnel_1 funnel_2. 1 if counted as funnel step, 0 otherwise  
SELECT 
IF (event_name = "session_start", 1, 0) AS funnel_1, 
IF (event_name = "session_start" AND next_event = "level_start", 1, 0) AS funnel_2 
FROM ( 
	SELECT event_name, user_pseudo_id , event_timestamp, 
	LEAD(event_name, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_event
	FROM `firebase-public-project.analytics_153293282.events_20200308` 
	WHERE (event_name = "session_start" OR event_name = "level_start") 
	ORDER BY 2,3 
)
```

```sql
--sum funnel_1, funnel_2  
SELECT 
   SUM (IF (event_name = "session_start", 1, 0)) AS funnel_1_total, 
   SUM (IF (event_name = "session_start" AND next_event = "level_start", 1, 0)) AS funnel_2_total
   FROM ( 
      SELECT event_name, user_pseudo_id , event_timestamp, 
      LEAD(event_name, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_event 
      FROM `firebase-public-project.analytics_153293282.events_20200308` 
      WHERE (event_name = "session_start" OR event_name = "level_start") 
      ORDER BY 2,3 
   )
```

```sql
-- sum -> count distinct  
SELECT 
  count(distinct funnel_1) as funnel_1_total, 
  count(distinct funnel_2) as funnel_2_total from
( 
  SELECT 
    -- If true: 1, false: 0 -> If true: user_pseudo_id, false: NULL 
    IF (event_name = "session_start", user_pseudo_id, NULL) AS funnel_1,
    IF (event_name = "session_start" AND next_event = "level_start", user_pseudo_id, NULL) AS funnel_2
    FROM 
    ( 
      SELECT event_name, user_pseudo_id , event_timestamp, 
      LEAD(event_name, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_event 
      FROM `firebase-public-project.analytics_153293282.events_20200308` 
      WHERE (event_name = "session_start" OR event_name = "level_start") 
      ORDER BY 2,3 
    )
)
```

```sql
SELECT count(distinct funnel_1) as funnel_1_total, count(distinct funnel_2) as funnel_2_total from (
  SELECT
  IF (event_name = "session_start", user_pseudo_id, NULL) AS funnel_1, 
  -- 5 minutes between 2 events. time_stemp is in microseconds  
  IF (event_name = "session_start" AND next_event = "level_start" 
     AND next_timestamp - event_timestamp < 5 * 60 * 1000 * 1000, user_pseudo_id, NULL) AS funnel_2
  FROM ( 
    SELECT event_name, user_pseudo_id , event_timestamp, 
    LEAD(event_name, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_event, 
    -- add next_timestemp  
    LEAD(event_timestamp, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_timestamp
    FROM `firebase-public-project.analytics_153293282.events_20200308` 
    WHERE (event_name = "session_start" OR event_name = "level_start") 
    ORDER BY 2,3 
  ) 
)
```

```sql
SELECT count(distinct funnel_1) as funnel_1_total, count(distinct funnel_2) as funnel_2_total from (
  SELECT 
    IF (event_name = "session_start", user_pseudo_id, NULL) AS funnel_1,  
    IF (event_name = "session_start" AND next_event = "level_start" AND next_timestamp - event_timestamp < 5 * 60 * 1000 * 1000, user_pseudo_id, NULL) AS funnel_2
  FROM ( 
    SELECT event_name, user_pseudo_id , event_timestamp, 
    LEAD(event_name, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_event, 
    LEAD(event_timestamp, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS next_timestamp
    FROM `firebase-public-project.analytics_153293282.events_*` 
    WHERE ((event_name = "session_start" OR event_name = "level_start") AND 
    -- add interval  
       _TABLE_SUFFIX BETWEEN FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 360 DAY)) 
    AND FORMAT_DATE("%Y%m%d", CURRENT_DATE())) 
    ORDER BY 2,3 
  ) 
)
```

### Retention 留存

This might be better, say daylight time saving? I am not sure actually.
```sql
TIMESTAMP("2019-12-28 00:00:00", "Asia/Shanghai") 
```

以周留存为例，调整时间即可变成日留存或者月留存

```sql
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    UNIX_MICROS(TIMESTAMP("2019-12-01 00:00:00", "+8:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20191130' AND '20191229'
)

SELECT week_0_cohort / week_0_cohort AS week_0_pct,
 week_1_cohort / week_0_cohort AS week_1_pct,
 week_2_cohort / week_0_cohort AS week_2_pct,
 week_3_cohort / week_0_cohort AS week_3_pct
FROM (
  WITH week_3_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(3*one_week_micros) AND start_day+(4*one_week_micros)
  ),
  week_2_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(2*one_week_micros) AND start_day+(3*one_week_micros)
  ),
  week_1_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(1*one_week_micros) AND start_day+(2*one_week_micros)
  ), 
  week_0_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_name = 'first_open'
      AND event_timestamp BETWEEN start_day AND start_day+(1*one_week_micros)
  )
  SELECT 
    (SELECT count(*) 
     FROM week_0_users) AS week_0_cohort,
    (SELECT count(*) 
     FROM week_1_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_1_cohort,
    (SELECT count(*) 
     FROM week_2_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_2_cohort,
    (SELECT count(*) 
     FROM week_3_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_3_cohort
)
```

Something Firebase cannot do

#### Retention on a specific version 根据app版本细分

This is a bit tricky since we only limited the user for week_0 to deal with upgrades. Adjust according to your business, let's only get the idea :)

```sql
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    app_info.version AS app_version,   -- This is new!
    UNIX_MICROS(TIMESTAMP("2019-12-01 00:00:00", "+8:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20191130' AND '20191229'
)

SELECT week_0_cohort / week_0_cohort AS week_0_pct,
 week_1_cohort / week_0_cohort AS week_1_pct,
 week_2_cohort / week_0_cohort AS week_2_pct,
 week_3_cohort / week_0_cohort AS week_3_pct
FROM (
  WITH week_3_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(3*one_week_micros) AND start_day+(4*one_week_micros)
  ),
  week_2_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(2*one_week_micros) AND start_day+(3*one_week_micros)
  ),
  week_1_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(1*one_week_micros) AND start_day+(2*one_week_micros)
  ), 
  week_0_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_name = 'first_open'
      AND app_version = "2.62"   -- This bit is new, too!
      AND event_timestamp BETWEEN start_day AND start_day+(1*one_week_micros)
  )
  SELECT 
    (SELECT count(*) 
     FROM week_0_users) AS week_0_cohort,
    (SELECT count(*) 
     FROM week_1_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_1_cohort,
    (SELECT count(*) 
     FROM week_2_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_2_cohort,
    (SELECT count(*) 
     FROM week_3_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_3_cohort
)
```

#### Retention with specific device type 根据设备细分

```sql
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    device.mobile_model_name, -- This parameter is new
    UNIX_MICROS(TIMESTAMP("2019-12-01 00:00:00", "+8:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20191130' AND '20191229'
    AND device.mobile_model_name LIKE "iPad Pro%"  -- This is also new
)
-- Rest of the query goes here
```

#### Daily retention 日留存

```sql
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, device.mobile_model_name,
    UNIX_MICROS(TIMESTAMP("2019-12-01 00:00:00", "+8:00")) AS start_day,
    3600*1000*1000*24 AS one_day_micros   -- new time period
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20191130' AND '20191229'
)
-- rest of the query goes here
```

#### Break out retention by user properties 根据用户属性细分

```sql
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    UNIX_MICROS(TIMESTAMP("2019-12-01 00:00:00", "+8:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20191131' AND '20191229'
  AND user_pseudo_id IN ( 
    -- Anybody who received 20 initial extra steps
    SELECT DISTINCT(user_pseudo_id) FROM 
      (SELECT user_pseudo_id,
             (SELECT value.string_value FROM UNNEST(user_properties) WHERE key = "initial_extra_steps") AS initial_steps
       FROM `firebase-public-project.analytics_153293282.events_*`
       WHERE _table_suffix BETWEEN '20191131' AND '20191229'
      )
    WHERE initial_steps = "20"
  )
)
```

Full version

```sql
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name, 
    UNIX_MICROS(TIMESTAMP("2019-12-01 00:00:00", "+8:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20191131' AND '20191229'
  AND user_pseudo_id IN (  
    SELECT DISTINCT(user_pseudo_id) FROM 
      (SELECT user_pseudo_id,
             (SELECT value.string_value FROM UNNEST(user_properties) WHERE key = "initial_extra_steps") AS initial_steps
       FROM `firebase-public-project.analytics_153293282.events_*`
       WHERE _table_suffix BETWEEN '20191131' AND '20191229'
      )
    WHERE initial_steps = "20"
  )
)

SELECT week_0_cohort / week_0_cohort AS week_0_pct,
 week_1_cohort / week_0_cohort AS week_1_pct,
 week_2_cohort / week_0_cohort AS week_2_pct,
 week_3_cohort / week_0_cohort AS week_3_pct
FROM (
  WITH week_3_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(3*one_week_micros) AND start_day+(4*one_week_micros)
  ),
  week_2_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(2*one_week_micros) AND start_day+(3*one_week_micros)
  ),
  week_1_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_timestamp BETWEEN start_day+(1*one_week_micros) AND start_day+(2*one_week_micros)
  ), 
  week_0_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM analytics_data
    WHERE event_name = 'first_open'
    AND event_timestamp BETWEEN start_day AND start_day+(1*one_week_micros)
  )
  SELECT 
    (SELECT count(*) 
     FROM week_0_users) AS week_0_cohort,
    (SELECT count(*) 
     FROM week_1_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_1_cohort,
    (SELECT count(*) 
     FROM week_2_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_2_cohort,
    (SELECT count(*) 
     FROM week_3_users 
     JOIN week_0_users USING (user_pseudo_id)) AS week_3_cohort
)
```

#### Break out retention by events 根据事件细分

```sql
WITH analytics_data AS (
  SELECT user_pseudo_id, event_timestamp, event_name,
    UNIX_MICROS(TIMESTAMP("2019-12-01 00:00:00", "+8:00")) AS start_day,
    3600*1000*1000*24*7 AS one_week_micros
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE _table_suffix BETWEEN '20191131' AND '20191229'
  AND user_pseudo_id IN ( 
    -- Anybody who's ever encountered a level_retry_quickplay event!
    SELECT DISTINCT(user_pseudo_id) FROM 
      (SELECT user_pseudo_id, event_name             
       FROM `firebase-public-project.analytics_153293282.events_*`
       WHERE _table_suffix BETWEEN '20191131' AND '20191229'
      )
    WHERE event_name = "level_retry_quickplay"
  )
)
-- rest of the query goes here
```

And more ...

还可以有更多的，比如事件属性，结合各种属性和指标的分析。这里就不一一列举了。

### SQLs

#### events

```sql
-- get number of events for each
SELECT 
  event_dim.name,
  COUNT(event_dim.name) as event_count 
FROM
  [firebase-analytics-sample-data:android_dataset.app_events_20200101]
GROUP BY 
  event_dim.name
ORDER BY 
  event_count DESC
  
-- value associated to events
SELECT 
  event_dim.params.value.int_value as virtual_currency_amt,
  COUNT(*) as num_times_spent
FROM
  [firebase-analytics-sample-data:android_dataset.app_events_20200101]
WHERE
  event_dim.name = "spend_virtual_currency"
AND
  event_dim.params.key = "value"
GROUP BY
  1
ORDER BY 
  num_times_spent DESC
```

#### users

```sql
-- Users by country

SELECT
  user_dim.geo_info.country as country,
  EXACT_COUNT_DISTINCT( user_dim.app_info.app_instance_id ) as users
FROM
  [firebase-analytics-sample-data:android_dataset.app_events_20200101],
  [firebase-analytics-sample-data:ios_dataset.app_events_20200101]
GROUP BY
  country
ORDER BY
  users DESC
  
-- Users segmentations

SELECT
  user_dim.user_properties.value.value.string_value as language_code, 
  EXACT_COUNT_DISTINCT(user_dim.app_info.app_instance_id) as users,
FROM
  [firebase-analytics-sample-data:android_dataset.app_events_20200101],
  [firebase-analytics-sample-data:ios_dataset.app_events_20200101]
WHERE
  user_dim.user_properties.key = "language"
GROUP BY
  language_code
ORDER BY 
  users DESC
  
-- Last 7-day users for each city
SELECT
  user_dim.geo_info.city,
  COUNT(user_dim.geo_info.city) as city_count 
FROM
TABLE_DATE_RANGE([firebase-analytics-sample-data:android_dataset.app_events_], DATE_ADD('2020-01-07', -7, 'DAY'), CURRENT_TIMESTAMP()),
TABLE_DATE_RANGE([firebase-analytics-sample-data:ios_dataset.app_events_], DATE_ADD('2020-01-07', -7, 'DAY'), CURRENT_TIMESTAMP())
GROUP BY
  user_dim.geo_info.city
ORDER BY
  city_count DESC
  
-- mobile vs. tablet in last 7 days
SELECT
  user_dim.app_info.app_platform as appPlatform,
  user_dim.device_info.device_category as deviceType,
  COUNT(user_dim.device_info.device_category) AS device_type_count FROM
TABLE_DATE_RANGE([firebase-analytics-sample-data:android_dataset.app_events_], DATE_ADD('2020-01-07', -7, 'DAY'), CURRENT_TIMESTAMP()),
TABLE_DATE_RANGE([firebase-analytics-sample-data:ios_dataset.app_events_], DATE_ADD('2020-01-07', -7, 'DAY'), CURRENT_TIMESTAMP())
GROUP BY
  1,2
ORDER BY
  device_type_count DESC
  
-- unique user events across platforms over the past week. Here we use PARTITION BY and EXACT_COUNT_DISTINCT to de-dupe our event report by users, making use of user properties and the user_dim.user_id field
SELECT 
  STRFTIME_UTC_USEC(eventTime,"%Y%m%d") as date,
  appPlatform,
  eventName,
  COUNT(*) totalEvents,
  EXACT_COUNT_DISTINCT(IF(userId IS NOT NULL, userId, fullVisitorid)) as users
FROM (
  SELECT
    fullVisitorid,
    openTimestamp,
    FORMAT_UTC_USEC(openTimestamp) firstOpenedTime,
    userIdSet,
    MAX(userIdSet) OVER(PARTITION BY fullVisitorid) userId,
    appPlatform,
    eventTimestamp,
    FORMAT_UTC_USEC(eventTimestamp) as eventTime,
    eventName
    FROM FLATTEN(
      (
        SELECT 
          user_dim.app_info.app_instance_id as fullVisitorid,
          user_dim.first_open_timestamp_micros as openTimestamp,
          user_dim.user_properties.value.value.string_value,
          IF(user_dim.user_properties.key = 'user_id',user_dim.user_properties.value.value.string_value, null) as userIdSet,
          user_dim.app_info.app_platform as appPlatform,
          event_dim.timestamp_micros as eventTimestamp,
          event_dim.name AS eventName,
          event_dim.params.key,
          event_dim.params.value.string_value
        FROM
         TABLE_DATE_RANGE([firebase-analytics-sample-data:android_dataset.app_events_], DATE_ADD('2020-01-07', -7, 'DAY'), CURRENT_TIMESTAMP()),
TABLE_DATE_RANGE([firebase-analytics-sample-data:ios_dataset.app_events_], DATE_ADD('2020-01-07', -7, 'DAY'), CURRENT_TIMESTAMP())
), user_dim.user_properties)
)
GROUP BY
  date, appPlatform, eventName
```
