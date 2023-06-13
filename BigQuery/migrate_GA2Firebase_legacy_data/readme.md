# Migrate Legacy GA data to latest Firebase/GA4 schema

## Targeting Schema Explained

| Field name                                 | Data type | Description                                                                                                                               |
|--------------------------------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------|
| App                                        | &nbsp;    | &nbsp;                                                                                                                                    |
| app_info                                   | RECORD    | A record of information on the app.                                                                                                       |
| app_info.id                                | STRING    | The package name or bundle ID of the app.                                                                                                 |
| app_info.firebase_app_id                   | STRING    | The Firebase App ID associated with the app                                                                                               |
| app_info.install_source                    | STRING    | The store that installed the app.                                                                                                         |
| app_info.version                           | STRING    | The app's versionName (Android) or short bundle version.                                                                                  |
| Device                                     | &nbsp;    | &nbsp;                                                                                                                                    |
| device                                     | RECORD    | A record of device information.                                                                                                           |
| device.category                            | STRING    | The device category (mobile, tablet, desktop).                                                                                            |
| device.mobile_brand_name                   | STRING    | The device brand name.                                                                                                                    |
| device.mobile_model_name                   | STRING    | The device model name.                                                                                                                    |
| device.mobile_marketing_name               | STRING    | The device marketing name.                                                                                                                |
| device.mobile_os_hardware_model            | STRING    | The device model information retrieved directly from the operating system.                                                                |
| device.operating_system                    | STRING    | The operating system of the device.                                                                                                       |
| device.operating_system_version            | STRING    | The OS version.                                                                                                                           |
| device.vendor_id                           | STRING    | IDFV (present only if IDFA is not collected).                                                                                             |
| device.advertising_id                      | STRING    | Advertising ID/IDFA.                                                                                                                      |
| device.language                            | STRING    | The OS language.                                                                                                                          |
| device.time_zone_offset_seconds            | INTEGER   | The offset from GMT in seconds.                                                                                                           |
| device.is_limited_ad_tracking              | BOOLEAN   | The device's Limit Ad Tracking setting.                                                                                                   |
| Stream and platform                        | &nbsp;    | &nbsp;                                                                                                                                    |
| stream_id                                  | STRING    | The numeric ID of the stream.                                                                                                             |
| platform                                   | STRING    | The platform on which the app was built.                                                                                                  |
| User                                       | &nbsp;    | &nbsp;                                                                                                                                    |
| user_first_touch_timestamp                 | INTEGER   | The time (in microseconds) at which the user first opened the app.                                                                        |
| user_id                                    | STRING    | The user ID set via the setUserId API.                                                                                                    |
| user_pseudo_id                             | STRING    | The pseudonymous id (e.g., app instance ID) for the user.                                                                                 |
| user_properties                            | RECORD    | A repeated record of user properties set with the setUserProperty API.                                                                    |
| user_properties.key                        | STRING    | The name of the user property.                                                                                                            |
| user_properties.value                      | RECORD    | A record for the user property value.                                                                                                     |
| user_properties.value.string_value         | STRING    | The string value of the user property.                                                                                                    |
| user_properties.value.int_value            | INTEGER   | The integer value of the user property.                                                                                                   |
| user_properties.value.double_value         | FLOAT     | The double value of the user property.                                                                                                    |
| user_properties.value.float_value          | FLOAT     | This field is currently unused.                                                                                                           |
| user_properties.value.set_timestamp_micros | INTEGER   | The time (in microseconds) at which the user property was last set.                                                                       |
| user_ltv                                   | RECORD    | A record of Lifetime Value information about the user. This field is not populated in intraday tables.                                    |
| user_ltv.revenue                           | FLOAT     | The Lifetime Value (revenue) of the user. This field is not populated in intraday tables.                                                 |
| user_ltv.currency                          | STRING    | The Lifetime Value (currency) of the user. This field is not populated in intraday tables.                                                |
| Campaign                                   | &nbsp;    | Note: traffic_source attribution is based on cross-channel last click.                                                                    |
| traffic_source                             | RECORD    | Name of the traffic source used to acquire the user. This field is not populated in intraday tables.                                      |
| traffic_source.name                        | STRING    | The name of the marketing campaign that acquired the user. This field is not populated in intraday tables.                                |
| traffic_source.medium                      | STRING    | The name of the medium (paid search, organic search, email, etc.) that acquired the user. This field is not populated in intraday tables. |
| traffic_source.source                      | STRING    | The name of the network that acquired the user. This field is not populated in intraday tables.                                           |
| Geo                                        | &nbsp;    | &nbsp;                                                                                                                                    |
| geo                                        | RECORD    | A record of the user's geographic information.                                                                                            |
| geo.continent                              | STRING    | The continent from which events were reported, based on IP address.                                                                       |
| geo.sub_continent                          | STRING    | The subcontinent from which events were reported, based on IP address.                                                                    |
| geo.country                                | STRING    | The country from which events were reported, based on IP address.                                                                         |
| geo.region                                 | STRING    | The region from which events were reported, based on IP address.                                                                          |
| geo.metro                                  | STRING    | The metro from which events were reported, based on IP address.                                                                           |
| geo.city                                   | STRING    | The city from which events were reported, based on IP address.                                                                            |
| Event                                      | &nbsp;    | &nbsp;                                                                                                                                    |
| event_date                                 | STRING    | The date on which the event was logged (YYYYMMDD format in the registered timezone of your app).                                          |
| event_timestamp                            | INTEGER   | The time (in microseconds, UTC) at which the event was logged on the client.                                                              |
| event_previous_timestamp                   | INTEGER   | The time (in microseconds, UTC) at which the event was previously logged on the client.                                                   |
| event_name                                 | STRING    | The name of the event.                                                                                                                    |
| event_params                               | RECORD    | A repeated record of the parameters associated with this event.                                                                           |
| event_params.key                           | STRING    | The event parameter's key.                                                                                                                |
| event_params.value                         | RECORD    | A record of the event parameter's value.                                                                                                  |
| event_params.value.string_value            | STRING    | The string value of the event parameter.                                                                                                  |
| event_params.value.int_value               | INTEGER   | The integer value of the event parameter.                                                                                                 |
| event_params.value.double_value            | FLOAT     | The double value of the event parameter.                                                                                                  |
| event_params.value.float_value             | FLOAT     | The float value of the event parameter.&nbsp; This field is currently unused.                                                             |
| event_value_in_usd                         | FLOAT     | The currency-converted value (in USD) of the event's "value" parameter.                                                                   |
| event_bundle_sequence_id                   | INTEGER   | The sequential ID of the bundle in which these events were uploaded.                                                                      |
| event_server_timestamp_offset              | INTEGER   | Timestamp offset between collection time and upload time in micros.                                                                       |
| Web                                        | &nbsp;    | &nbsp;                                                                                                                                    |
| web_info                                   | RECORD    | A record of information for web data.                                                                                                     |
| web_info.hostname                          | STRING    | The hostname associated with the logged event.                                                                                            |
| web_info.browser                           | STRING    | The browser in which the user viewed content.                                                                                             |
| web_info.browser_version                   | STRING    | The version of the browser in which the user viewed content.                                                                              |

## Do the migration

Update the [script](https://github.com/cloudymoma/gcp-playgroud-public/blob/master/BigQuery/migrate_GA2Firebase_legacy_data/migration.sh) to include your Analytics property ID, BigQuery project ID, Firebase app ID, BigQuery dataset name, and the start and end dates of the data you want, then run `./migration.sh`

## Old schema

| Field Name                                           | Data Type | Description                                                                                                                                |
|------------------------------------------------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------|
| user_dim                                             | RECORD    | A record of user dimensions.                                                                                                               |
| user_dim.user_id                                     | STRING    | The user ID set via the setUserId API.                                                                                                     |
| user_dim.first_open_timestamp_micros                 | INTEGER   | The time (in microseconds) at which the user first opened the app.                                                                         |
| user_dim.user_properties                             | RECORD    | A repeated record of user properties set with the setUserProperty API.                                                                     |
| user_dim.user_properties.key                         | STRING    | The name of the user property                                                                                                              |
| user_dim.user_properties.value                       | RECORD    | A record for information about the user property.                                                                                          |
| user_dim.user_properties.value.value                 | RECORD    | A record for the user property value.                                                                                                      |
| user_dim.user_properties.value.value.string_value    | STRING    | The string value of the user property.                                                                                                     |
| user_dim.user_properties.value.value.int_value       | INTEGER   | The integer value of the user property.                                                                                                    |
| user_dim.user_properties.value.value.double_value    | FLOAT     | The double value of the user property.                                                                                                     |
| user_dim.user_properties.value.set_timestamp_usec    | INTEGER   | The time (in microseconds) at which the user property was last set.                                                                        |
| user_dim.user_properties.value.index                 | INTEGER   | The index (0-24) of the user property.                                                                                                     |
| user_dim.device_info                                 | RECORD    | A record of device information.                                                                                                            |
| user_dim.device_info.device_category                 | STRING    | The device category (mobile, tablet, desktop).                                                                                             |
| user_dim.device_info.mobile_brand_name               | STRING    | The device brand name.                                                                                                                     |
| user_dim.device_info.mobile_model_name               | STRING    | The device model name.                                                                                                                     |
| user_dim.device_info.mobile_marketing_name           | STRING    | The device marketing name.                                                                                                                 |
| user_dim.device_info.device_model                    | STRING    | The device model.                                                                                                                          |
| user_dim.device_info.platform_version                | STRING    | The OS version.                                                                                                                            |
| user_dim.device_info.device_id                       | STRING    | IDFV (present only if IDFA is not available).                                                                                              |
| user_dim.device_info.resettable_device_id            | STRING    | Advertising ID/IDFA.                                                                                                                       |
| user_dim.device_info.user_default_language           | STRING    | The OS language.                                                                                                                           |
| user_dim.device_info.device_time_zone_offset_seconds | INTEGER   | The offset from GMT in seconds.                                                                                                            |
| user_dim.device_info.limited_ad_tracking             | BOOLEAN   | The device's Limit Ad Tracking setting.                                                                                                    |
| user_dim.geo_info                                    | RECORD    | A record of the user's geographic information.                                                                                             |
| user_dim.geo_info.continent                          | STRING    | The continent from which events were reported, based on IP address.                                                                        |
| user_dim.geo_info.country                            | STRING    | The country from which events were reported, based on IP address.                                                                          |
| user_dim.geo_info.region                             | STRING    | The region from which events were reported, based on IP address.                                                                           |
| user_dim.geo_info.city                               | STRING    | The city from which events were reported, based on IP address.                                                                             |
| user_dim.app_info                                    | RECORD    | A record of information on the app.                                                                                                        |
| user_dim.app_info.app_version                        | STRING    | The app's versionName (Android) or short bundle version.                                                                                   |
| user_dim.app_info.app_instance_id                    | STRING    | The unique id for this instance of the app.                                                                                                |
| user_dim.app_info.app_store                          | STRING    | The store which installed this app.                                                                                                        |
| user_dim.app_info.app_platform                       | STRING    | The platform on which this app is running.                                                                                                 |
| user_dim.traffic_source                              | RECORD    | Name of the traffic source used to acquired the user.&nbsp;This field is not populated in intraday tables.                                 |
| user_dim.traffic_source.user_acquired_campaign       | STRING    | The name of the marketing campaign which acquired the user.&nbsp;This field is not populated in intraday tables.                           |
| user_dim.traffic_source.user_acquired_medium         | STRING    | The name of the medium (paid search, organic search, email, etc.) which acquired the user. This field is not populated in intraday tables. |
| user_dim.traffic_source.user_acquired_source         | STRING    | The name of the network which acquired the user.&nbsp;This field is not populated in intraday tables.                                      |
| user_dim.bundle_info                                 | RECORD    | A record of information regarding the bundle in which these events were uploaded.                                                          |
| user_dim.bundle_info.bundle_sequence_id              | INTEGER   | The sequential id of the bundle in which these events were uploaded.                                                                       |
| user_dim.ltv_info                                    | RECORD    | A record of Lifetime Value information about this user.&nbsp;This field is not populated in intraday tables.                               |
| user_dim.ltv_info.revenue                            | FLOAT     | The Lifetime Value (revenue) of this user.&nbsp;This field is not populated in intraday tables.                                            |
| user_dim.ltv_info.currency                           | STRING    | The Lifetime Value (currency) of this user.&nbsp;This field is not populated in intraday tables.                                           |
