CREATE VIEW {project_id}.{dataset}.v_gaming_events AS
SELECT
GENERATE_UUID() as unique_event_id,
TIMESTAMP_MICROS(event_timestamp) as event,
event_name,
event_bundle_sequence_id,
safe_cast(user_pseudo_id as STRING) as user_id,
TIMESTAMP_MICROS(user_first_touch_timestamp) as user_first_seen,
platform as device_platform,
device.mobile_brand_name as device_brand,
device.mobile_model_name as device_model,
device.operating_system_version as device_os_version,
device.language as device_language,
geo.continent as continent,
geo.region as region,
geo.country as country,
app_info.install_source as install_source,
(event_timestamp=user_first_touch_timestamp) as is_first_seen,
ecommerce.purchase_revenue as iap_revenue,
user_ltv,
( select
   x
 from UNNEST(ARRAY<STRUCT<x INT64, y STRING>>[(event_timestamp, event_name)])
 where y='session_start') as session_start,
(CASE
  WHEN event_name!='session_start' THEN null
  ELSE TIMESTAMP_MICROS(LEAD(event_timestamp, 1) OVER (
          PARTITION BY (select z
                        from UNNEST(ARRAY<STRUCT<x INT64, y STRING, z STRING>>[(event_timestamp, event_name, user_pseudo_id)])
                        where y='session_start')  ORDER BY event_timestamp)
        )
  END
) as next_session_start,
( select value.float_value
 from unnest(event_params)
 where key='@ga_ad_revenue' limit 1) as ad_revenue,
( select value.float_value
 from unnest(event_params)
 where key='@ga_install_cost' limit 1) as install_cost,
( select value.int_value
 from unnest(event_params)
 where key='@ga_gems_earned' limit 1) as gems_earned,
( select value.string_value
 from unnest(event_params)
 where key='@ga_campaign_name' limit 1) as campaign_name,
( select value.string_value
 from unnest(event_params)
 where key='@ga_ad_network' limit 1) as ad_network,
( select value.string_value
 from unnest(event_params)
 where key='@ga_campaign_id' limit 1) as campaign_id,
( select value.string_value
 from unnest(event_params)
 where key='@ga_game_name' limit 1) as game_name,
( select value.string_value
 from unnest(event_params)
 where key='@ga_game_version' limit 1) as game_version,
( select value.int_value
 from unnest(event_params)
 where key='@ga_player_level' limit 1) as player_level,
( select value.int_value
 from unnest(event_params)
 where key='@ga_session_number' limit 1) as player_session_sequence,
( select safe_cast(value.int_value as STRING)
 from unnest(event_params)
 where key='@ga_session_id' limit 1) as unique_session_id
FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as e