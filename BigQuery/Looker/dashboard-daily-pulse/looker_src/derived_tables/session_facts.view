################################################################
# Session Facts View
################################################################

view: session_facts {
  derived_table: {
    sql: WITH session_facts AS
        (SELECT
             unique_session_id
            , next_session_start
            , event
            , user_id
            , event_name
            , COALESCE(SUM((IFNULL(iap_revenue,0) + IFNULL(ad_revenue,0)) ), 0) as session_revenue
            , SUM(iap_revenue) as session_iap_revenue
            , SUM(ad_revenue) as session_ad_revenue
            , COUNT(CASE WHEN (event_name = 'Ad_Watched') THEN 1 ELSE NULL END) AS number_of_ads_shown
            , COUNT(CASE WHEN (event_name = 'Level_Up') THEN 1 ELSE NULL END) AS number_level_ups
            , MAX(player_level) as highest_level_reached
            , FIRST_VALUE (event) OVER (PARTITION BY unique_session_id ORDER BY event ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_start
            , LAST_VALUE (event) OVER (PARTITION BY unique_session_id ORDER BY event ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_end
            , FIRST_VALUE (event_name) OVER (PARTITION BY unique_session_id ORDER BY event ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_first_event
            , LAST_VALUE  (event_name) OVER (PARTITION BY unique_session_id ORDER BY event ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_last_event
          FROM
              ${events.SQL_TABLE_NAME} AS events_sessionized
          GROUP BY 1,2,3,4,5
          ORDER BY unique_session_id asc
        )
      SELECT
          session_facts.unique_session_id
        , session_facts.next_session_start
        , session_facts.user_id
        , session_facts.session_start
        , session_facts.session_end
        , session_first_event
        , session_last_event
        , events_sessionized.device_platform
        , events_sessionized.game_name
        , MAX(events_sessionized.game_version) as game_version
        , MAX(events_sessionized.country) as country
        , MAX(session_facts.highest_level_reached) as highest_level_reached
        , MAX(session_facts.session_revenue) as session_revenue
        , MAX(session_facts.session_iap_revenue) as session_iap_revenue
        , MAX(session_facts.session_ad_revenue) as session_ad_revenue
        , SUM(session_facts.number_of_ads_shown) as number_of_ads_shown
        , SUM(session_facts.number_level_ups) as number_of_level_ups
        , ROW_NUMBER () OVER (PARTITION BY session_facts.user_id ORDER BY MIN(session_start)) AS session_sequence_for_user
        , ROW_NUMBER () OVER (PARTITION BY session_facts.user_id ORDER BY MIN(session_start) desc) AS inverse_session_sequence_for_user
        , count(1) as events_in_session
      FROM session_facts
      INNER JOIN
        ${events.SQL_TABLE_NAME} AS events_sessionized
      ON  events_sessionized.event = session_facts.session_start
      AND events_sessionized.unique_session_id = session_facts.unique_session_id
      GROUP BY 1,2,3,4,5,6,7,8,9
       ;;
    datagroup_trigger: events_raw
    partition_keys: ["session_start"]
    cluster_keys: ["game_name"]
  }

  dimension: unique_session_id {
    primary_key: yes
    type: string
    value_format_name: id
    sql: ${TABLE}.unique_session_id ;;
    link: {
      label: "See session detail"
      url: "/dashboards/Xb2IL2W022TXYLgHiOkAYV?Session%20ID={{value}}"
    }
  }

  dimension: user_id {}
  dimension: game_version {}
  dimension: device_platform {}
  dimension: country {}
  dimension: game_name {}

  dimension_group: session_start_at {
    type: time
    convert_tz: no
    timeframes: [raw,time, date, week, month]
    sql: ${TABLE}.session_start ;;
  }

  dimension_group: session_end_at {
    type: time
    convert_tz: no
    timeframes: [raw,time, date, week, month]
    sql: ${TABLE}.session_end ;;
  }

  dimension_group: next_session_start_at {
    type: time
    convert_tz: no
    timeframes: [raw,time, date, week, month]
    sql: ${TABLE}.next_session_start ;;
  }

  dimension_group: until_next_session {
    type: duration
    intervals: [day,week,month]
    sql_start: ${session_start_at_raw} ;;
    sql_end: CASE WHEN ${next_session_start_at_raw} = TIMESTAMP('6000-01-01 00:00:00') then NULL else ${next_session_start_at_raw} END ;;
  }

  dimension: retention_day {
    group_label: "Retention"
    description: "Days since first seen (from event date)"
    type:  number
    sql:  DATE_DIFF(${session_start_at_date}, ${user_facts.player_first_seen_date}, DAY);;
  }


  dimension: session_sequence_for_user {
    type: number
    sql: ${TABLE}.session_sequence_for_user ;;
  }

  dimension: inverse_session_sequence_for_user {
    hidden: yes
    type: number
    sql: ${TABLE}.inverse_session_sequence_for_user ;;
  }

  dimension: is_first_session {
    description: "Is this the first session for this user?"
    type: yesno
    sql: ${session_sequence_for_user} = 1 ;;
  }

  dimension: is_last_session {
    description: "Is this the last session for this user?"
    type: yesno
    sql: ${session_sequence_for_user} = ${inverse_session_sequence_for_user} ;;
  }

  dimension: number_of_events_in_session {
    type: number
    sql: ${TABLE}.events_in_session ;;
  }

  dimension: number_of_level_ups {
    description: "number of times the user has increased level within this session"
    type: number
    sql: ${TABLE}.number_of_level_ups ;;
  }

  dimension: highest_level_reached {
    description: "highest level within this session"
    type: number
    sql: ${TABLE}.highest_level_reached ;;
  }

  dimension: session_first_event {
    type: string
    sql: ${TABLE}.session_first_event ;;
  }

  dimension: session_last_event {
    type: string
    sql: ${TABLE}.session_last_event ;;
  }

  dimension_group: session_length {
    type: duration
    intervals: [second,minute,hour]
    sql_start: ${session_start_at_raw} ;;
    sql_end: ${session_end_at_raw} ;;
  }

  dimension: session_length_tier {
    alias: [session_length_minutes_tier]
    type: string
    sql:
        case
        when ${minutes_session_length} between 0 and 1 then '1. Bounce (<2 min)'
        when ${minutes_session_length} between 2 and 5 then '2. Quick Sesh (2-5 min)'
        when ${minutes_session_length} between 6 and 15 then '3. Average Sesh (6-15 min)'
        when ${minutes_session_length} between 16 and 30 then '4. Deep Sesh (16-30 min)'
        when ${minutes_session_length} > 30              then '5. Binge (>30 min)'
        else 'other'
        end

      ;;
  }

  dimension: session_revenue {
    type: number
    description: "IAP and Ad Revenue in Session"
    sql: ${TABLE}.session_revenue ;;
    value_format_name: usd
  }

  dimension: session_iap_revenue {
    type: number
    description: "IAP Revenue in Session"
    sql: ${TABLE}.session_iap_revenue ;;
    value_format_name: usd
  }

  dimension: session_ad_revenue {
    type: number
    description: "Ad Revenue in Session"
    sql: ${TABLE}.session_ad_revenue ;;
    value_format_name: usd
  }

  dimension: number_of_ads_shown {
    type: number
    sql: ${TABLE}.number_of_ads_shown ;;
  }

  measure: average_session_length_minutes {
    type: average
    sql: ${minutes_session_length} ;;
    value_format_name: decimal_2
  }

  measure: total_ads_shown {
    group_label: "Monetization"
    type: sum
    sql: ${number_of_ads_shown} ;;
  }

  measure: ads_shown_per_session {
    group_label: "Monetization"
    type: number
    sql: ${total_ads_shown} / ${number_of_sessions};;
    value_format_name: decimal_2
  }

  measure: number_of_sessions {
    type: count
    drill_fields: [detail*]
  }

  measure: total_level_ups {
    group_label: "Level Ups"
    type: sum
    sql: ${number_of_level_ups} ;;
  }

  measure: average_level_ups {
    group_label: "Level Ups"
    type: average
    sql: ${number_of_level_ups} ;;
    value_format_name: decimal_2
  }

  measure: total_session_length {
    hidden: yes
    type: sum
    sql: ${minutes_session_length} ;;
  }

  measure: total_revenue {
    label: "Total Revenue"
    group_label: "Monetization"
    description: "Total Revenue from Ads + In-App Purchases"
    type: sum
    sql: ${session_revenue} ;;
    value_format_name: large_usd
  }

  measure: total_iap_revenue {
    label: "Total IAP Revenue"
    group_label: "Monetization"
    description: "Total Revenue from In-App Purchases"
    type: sum
    sql: ${session_iap_revenue} ;;
    value_format_name: large_usd
  }

  measure: total_ad_revenue {
    label: "Total Ad Revenue"
    group_label: "Monetization"
    description: "Total Revenue from Ad"
    type: sum
    sql: ${session_ad_revenue} ;;
    value_format_name: large_usd
  }

  measure: average_revenue_per_user {
    group_label: "Monetization"
    label: "ARPU"
    description: "(Average revenue per user) = Total Revenue (IAP + Ad) / Total Number of Users"
    type: number
    sql: 1.0 * ${total_revenue} / NULLIF(count(distinct ${user_id}),0) ;;
    value_format_name: large_usd
  }


  set: detail {
    fields: [
      unique_session_id,
      session_start_at_time,
      session_end_at_time,
      session_sequence_for_user,
      inverse_session_sequence_for_user,
      number_of_events_in_session,
      session_first_event,
      session_last_event,
      session_revenue
    ]
  }
}
