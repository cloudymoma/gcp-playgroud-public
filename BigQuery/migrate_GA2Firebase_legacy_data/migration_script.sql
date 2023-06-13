SELECT
  @date AS event_date,
  event.timestamp_micros AS event_timestamp,
  event.previous_timestamp_micros AS event_previous_timestamp,
  event.name AS event_name,
  event.value_in_usd  AS event_value_in_usd,
   user_dim.bundle_info.bundle_sequence_id AS event_bundle_sequence_id,
  user_dim.bundle_info.server_timestamp_offset_micros as event_server_timestamp_offset,
  (
  SELECT
    ARRAY_AGG(STRUCT(event_param.key AS key,
        STRUCT(event_param.value.string_value AS string_value,
          event_param.value.int_value AS int_value,
          event_param.value.double_value AS double_value, 
          event_param.value.float_value AS float_value) AS value))
  FROM
    UNNEST(event.params) AS event_param) AS event_params,
  user_dim.first_open_timestamp_micros AS user_first_touch_timestamp,
  user_dim.user_id AS user_id,
  user_dim.app_info.app_instance_id AS user_pseudo_id,
  "" AS stream_id,
  user_dim.app_info.app_platform AS platform,
  STRUCT( user_dim.ltv_info.revenue AS revenue,
    user_dim.ltv_info.currency AS currency ) AS user_ltv,
  STRUCT( user_dim.traffic_source.user_acquired_campaign AS name,
      user_dim.traffic_source.user_acquired_medium AS medium,
      user_dim.traffic_source.user_acquired_source AS source ) AS traffic_source,
  STRUCT( user_dim.geo_info.continent AS continent,
    user_dim.geo_info.country AS country,
    user_dim.geo_info.region AS region,
    user_dim.geo_info.city AS city ) AS geo,
  STRUCT( user_dim.device_info.device_category AS category,
    user_dim.device_info.mobile_brand_name,
    user_dim.device_info.mobile_model_name,
    user_dim.device_info.mobile_marketing_name,
    user_dim.device_info.device_model AS mobile_os_hardware_model,
    @platform AS operating_system,
    user_dim.device_info.platform_version AS operating_system_version,
    user_dim.device_info.device_id AS vendor_id,
    user_dim.device_info.resettable_device_id AS advertising_id,
    user_dim.device_info.user_default_language AS language,
    user_dim.device_info.device_time_zone_offset_seconds AS time_zone_offset_seconds,
    IF(user_dim.device_info.limited_ad_tracking, "Yes", "No") AS is_limited_ad_tracking ) AS device,
  STRUCT( user_dim.app_info.app_id AS id,
    @firebase_app_id  AS firebase_app_id,
    user_dim.app_info.app_version AS version,
    user_dim.app_info.app_store AS install_source ) AS app_info,
  (
  SELECT
    ARRAY_AGG(STRUCT(user_property.key AS key,
        STRUCT(user_property.value.value.string_value AS string_value,
          user_property.value.value.int_value AS int_value,
          user_property.value.value.double_value AS double_value,
          user_property.value.value.float_value AS float_value,
          user_property.value.set_timestamp_usec AS set_timestamp_micros ) AS value))
  FROM
    UNNEST(user_dim.user_properties) AS user_property) AS user_properties
FROM
  `SCRIPT_GENERATED_TABLE_NAME`,
  UNNEST(event_dim) AS event