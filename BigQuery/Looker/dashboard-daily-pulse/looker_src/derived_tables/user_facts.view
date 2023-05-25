#This is a native derived table created using this query:
#https://demoexpo.looker.com/explore/gaming/events?fields=user_facts.d1_retained_users,events.number_of_users,events.d1_retention_rate&fill_fields=user_facts.d1_retained_users&f[events.event_date]=&sorts=user_facts.d1_retained_users&limit=500&column_limit=50&vis=%7B%7D&filter_config=%7B%22events.event_date%22%3A%5B%7B%22type%22%3A%22anytime%22%2C%22values%22%3A%5B%7B%22constant%22%3A%227%22%2C%22unit%22%3A%22day%22%7D%2C%7B%7D%5D%2C%22id%22%3A0%2C%22error%22%3Afalse%7D%5D%7D&dynamic_fields=%5B%7B%22table_calculation%22%3A%22calculation_1%22%2C%22label%22%3A%22Calculation+1%22%2C%22expression%22%3A%22%24%7Bevents.number_of_users%7D%2Fsum%28%24%7Bevents.number_of_users%7D%29%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3A%22percent_2%22%2C%22_kind_hint%22%3A%22measure%22%2C%22_type_hint%22%3A%22number%22%7D%5D&origin=share-expanded
view: user_facts {
  derived_table: {
    explore_source: events {
      column: user_id {}
      column: days_played {}
      column: number_of_level_ups {}
      column: highest_level_reached {}
      column: install_source {}
      column: campaign_name {}
      column: number_of_countries_played_in {}
      column: most_commonly_played_country {}
      column: number_of_devices_used {}
      column: most_commonly_used_device {}
      column: total_d1_revenue {}
      column: total_d7_revenue {}
      column: total_d14_revenue {}
      column: total_d30_revenue {}
      column: total_revenue {}
      column: total_iap_revenue {}
      column: total_ad_revenue {}
      column: total_revenue_after_UA {}
      column: number_of_sessions { field: session_facts.number_of_sessions }
      column: total_session_length { field: session_facts.total_session_length }
      column: cost_per_install {}
      column: d1_retained_users {}
      column: d7_retained_users {}
      column: d14_retained_users {}
      column: d30_retained_users {}
      column: player_first_seen {}
      column: player_last_seen {}
      derived_column: is_roas_positive {
        sql: case when total_revenue_after_UA > 0 then true else false end ;;
      }
      filters: {
        field: events.event_date
        value: ""
      }
    }
    datagroup_trigger: events_raw
    partition_keys: ["player_first_seen"]
  }
  dimension: user_id {
    primary_key: yes
  }
  dimension: total_d1_revenue {
    group_label: "LTV"
    label: "D1 LTV"
    description: "Revenue (ads + IAP) on day 1"
    value_format_name: usd
    type: number
  }
  dimension: total_d7_revenue {
    group_label: "LTV"
    label: "D7 LTV"
    description: "Revenue (ads + IAP) on day 7"
    value_format_name: usd
    type: number
  }
  dimension: total_d14_revenue {
    group_label: "LTV"
    label: "D14 LTV"
    description: "Revenue (ads + IAP) on day 14"
    value_format_name: usd
    type: number
  }
  dimension: total_d30_revenue {
    group_label: "LTV"
    label: "D30 LTV"
    description: "Revenue (ads + IAP) on day 30"
    value_format_name: usd
    type: number
  }
  dimension: lifetime_revenue {
    group_label: "LTV"
    label: "Total Current LTV"
    description: "IAP + Ad Revenue"
    value_format_name: usd
    type: number
    sql: ${TABLE}.total_revenue ;;
  }
  dimension: lifetime_iap_revenue {
    group_label: "LTV"
    label: "Total IAP Revenue"
    description: "Total Revenue from In-App Purchases"
    value_format_name: usd
    type: number
    sql: ${TABLE}.total_iap_revenue ;;
  }

  dimension: is_spender {
    type: yesno
    sql: ${lifetime_iap_revenue} > 0 ;;
  }

  dimension: number_of_devices_used {
    type: number
  }

  dimension: most_commonly_used_device {
    label: "Device Model"
    description: "(most common for user)"
    type: string
  }

  dimension: number_of_countries_played_in {
    type: number
  }

  dimension: most_commonly_played_country {
    type: string
  }

  dimension: lifetime_spend_tier {
    description: "Based on Lifetime LTV spend, are they Minnow/Dolphin/Whale"
    type: string
    sql: case
           when not ${is_spender} then 'Non-Spender ($0)'
           when ${lifetime_iap_revenue} BETWEEN 0 and 6 THEN 'Minnow ($0 to $6)'
           when ${lifetime_iap_revenue} BETWEEN 6 and 50 THEN 'Dolphin ($6 to $50)'
           when ${lifetime_iap_revenue} > 50 THEN 'Whale (>$50)'
          else 'other'
          end;;
    drill_fields: [total_iap_revenue,user_facts.number_of_users]
  }

  dimension: lifetime_ad_revenue {
    group_label: "LTV"
    label: "Total Ad Revenue"
    description: "Total Revenue from Ads"
    value_format_name: usd
    type: number
    sql: ${TABLE}.total_ad_revenue ;;
  }

  dimension: total_revenue_after_UA {
    group_label: "LTV"
    label: "LTV Revenue After UA"
    description: "Revenue - Marketing Spend"
    value_format_name: usd
    type: number
  }

  dimension: is_roas_positive {
    description: "revenue > than acquisition cost"
    type: yesno
    sql: ${TABLE}.is_roas_positive;;
  }

  measure: number_of_users_roas_positive {
    hidden: yes
    type: count
    filters: {
      field: is_roas_positive
      value: "yes"
    }
    filters: {
      field: install_source
      value: "-Organic"
    }
  }

  measure: number_of_inorganic_users {
    hidden: yes
    type: count
    filters: {
      field: install_source
      value: "-Organic"
    }
  }

  measure: percent_roas_positive {
    description: "What % of inorganic users are roas positive?"
    type: number
    sql: 1.0 * ${number_of_users_roas_positive} / NULLIF(${number_of_inorganic_users},0) ;;
    value_format_name: percent_2
  }

  dimension: number_of_sessions {
    label: "Lifetime Sessions"
    type: number
    drill_fields: [session_facts.unique_session_id,session_facts.minutes_session_length]
  }

  dimension: total_session_length {
    label: "Lifetime Play Minutes"
    type: number
  }

  dimension: cost_per_install {
    label: "Acquisition Cost"
    value_format_name: usd
    type: number
  }

  dimension: days_played {
    type: number
    description: "Number of distinct days played"
  }

  measure: median_days_played {
    type: median
    sql: ${days_played} ;;
  }

  dimension: lifetime_level_ups {
    type: number
    sql: ${TABLE}.number_of_level_ups ;;
  }
  dimension: highest_level_reached {
    type: number
    sql: ${TABLE}.highest_level_reached;;
  }

  dimension: is_churned {
    description: "Player hasn't been seen for 7 days"
    type: yesno
    sql: ${days_since_last_seen} > 7 ;;
  }

  dimension: d1_retained {
    group_label: "Retention"
    label: "D1 Retained"
    type: yesno
    description: "Number of players that came back to play on day 1"
    sql: CAST(${TABLE}.d1_retained_users as bool) ;;
  }
  dimension: d7_retained {
    group_label: "Retention"
    label: "D7 Retained"
    description: "Number of players that came back to play on day 7"
    type: yesno
    sql: CAST(${TABLE}.d7_retained_users as bool) ;;
  }
  dimension: d14_retained {
    group_label: "Retention"
    label: "D14 Retained"
    description: "Number of players that came back to play on day 14"
    type: yesno
    sql: CAST(${TABLE}.d14_retained_users as bool) ;;
  }
  dimension: d30_retained {
    group_label: "Retention"
    label: "D30 Retained"
    description: "Number of players that came back to play on day 30"
    type: yesno
    sql: CAST(${TABLE}.d30_retained_users as bool) ;;
  }
  dimension_group: player_first_seen {
    description: "Not for direct use, use for NDT"
    type: time
  }
  dimension_group: player_last_seen {
    description: "Not for direct use, use for NDT"
    type: time
  }

  dimension_group: since_last_seen {
    intervals: [day,hour,week,month]
    type: duration
    sql_start: ${player_last_seen_raw} ;;
    sql_end: CURRENT_TIMESTAMP ;;
  }
  dimension_group: since_first_seen {
    type: duration
    intervals: [day,hour,week,month]
    sql_start: ${player_first_seen_raw} ;;
    sql_end: CURRENT_TIMESTAMP ;;
  }

  dimension: install_source {}
  dimension: campaign_name {}


  measure: number_of_users {
    type: count
    drill_fields: [user_fact_drills*]
  }

  measure: total_revenue {
    label: "Total Revenue"
    group_label: "Monetization"
    description: "Total Revenue from Ads + In-App Purchases"
    type: sum
    sql: ${lifetime_revenue} ;;
    value_format_name: large_usd
  }

  measure: total_iap_revenue {
    label: "Total IAP Revenue"
    group_label: "Monetization"
    description: "Total Revenue from In-App Purchases"
    type: sum
    sql: ${lifetime_iap_revenue} ;;
    value_format_name: large_usd
  }

  measure: total_ad_revenue {
    label: "Total Ad Revenue"
    group_label: "Monetization"
    description: "Total Revenue from Ad"
    type: sum
    sql: ${lifetime_ad_revenue} ;;
    value_format_name: large_usd
  }

# D1

  measure: d1_retained_users {
    group_label: "Retention"
    description: "Number of players that came back to play on day 1"
    type: count_distinct sql: ${user_id} ;;
    filters: {
      field: d1_retained
      value: "yes"
    }
    drill_fields: [d1_retained_users]
  }

  measure: d1_eligible_users {
    hidden: yes
    group_label: "Retention"
    description: "Number of players older than 0 days"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: days_since_first_seen
      value: ">0"
    }
  }

  measure: d1_retention_rate {
    group_label: "Retention"
    description: "% of players (that are older than 0 days) that came back to play on day 1"
    value_format_name: percent_2
    type: number
    sql: 1.0 * ${d1_retained_users}/ NULLIF(${d1_eligible_users},0);;
    drill_fields: [d1_retention_rate]
  }

  # D7

  measure: d7_retained_users {
    group_label: "Retention"
    description: "Number of players that came back to play on day 7"
    type: count_distinct sql: ${user_id} ;;
    filters: {
      field: d7_retained
      value: "yes"
    }
    drill_fields: [d7_retained_users]
  }

  measure: d7_eligible_users {
    hidden: yes
    group_label: "Retention"
    description: "Number of players older than 7 days"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: days_since_first_seen
      value: ">7"
    }
    drill_fields: [d7_eligible_users]
  }

  measure: d7_retention_rate {
    group_label: "Retention"
    description: "% of players (that are older than 7 days) that came back to play on day 7"
    value_format_name: percent_2
    type: number
    sql: 1.0 * ${d7_retained_users}/ NULLIF(${d7_eligible_users},0);;
    drill_fields: [d7_retention_rate]
  }

  # D14

  measure: d14_retained_users {
    group_label: "Retention"
    description: "Number of players that came back to play on day 14"
    type: count_distinct sql: ${user_id} ;;
    filters: {
      field: d14_retained
      value: "yes"
    }
    drill_fields: [d14_retained_users]
  }

  measure: d14_eligible_users {
    hidden: yes
    group_label: "Retention"
    description: "Number of players older than 14 days"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: days_since_first_seen
      value: ">14"
    }
    drill_fields: [d14_eligible_users]
  }

  measure: d14_retention_rate {
    group_label: "Retention"
    description: "% of players (that are older than 14 days) that came back to play on day 14"
    value_format_name: percent_2
    type: number
    sql: 1.0 * ${d14_retained_users}/ NULLIF(${d14_eligible_users},0);;
    drill_fields: [d14_retention_rate]
  }

  # D30

  measure: d30_retained_users {
    group_label: "Retention"
    description: "Number of players that came back to play on day 30"
    type: count_distinct sql: ${user_id} ;;
    filters: {
      field: d30_retained
      value: "yes"
    }
    drill_fields: [d30_retained_users]
  }

  measure: d30_eligible_users {
    hidden: yes
    group_label: "Retention"
    description: "Number of players older than 30 days"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: days_since_first_seen
      value: ">30"
    }
    drill_fields: [d30_eligible_users]
  }

  measure: d30_retention_rate {
    group_label: "Retention"
    description: "% of players (that are older than 30 days) that came back to play on day 30"
    value_format_name: percent_2
    type: number
    sql: 1.0 * ${d30_retained_users}/ NULLIF(${d30_eligible_users},0);;
    drill_fields: [d30_retention_rate]
  }

  ### Level Ups

  measure: min_highest_level_reached{
    group_label: "Level Ups"
    type: min
    sql: ${highest_level_reached} ;;
    value_format_name: decimal_2
  }

  measure: max_highest_level_reached{
    group_label: "Level Ups"
    type: max
    sql: ${highest_level_reached} ;;
    value_format_name: decimal_2
  }

  measure: median_highest_level_reached {
    group_label: "Level Ups"
    type: median
    sql: ${highest_level_reached} ;;
    value_format_name: decimal_2
  }

  measure: 75_percentile_highest_level_reached {
    group_label: "Level Ups"
    type: percentile
    percentile: 75
    sql: ${highest_level_reached} ;;
    value_format_name: decimal_2
  }

  measure: 25_percentile_highest_level_reached {
    group_label: "Level Ups"
    type: percentile
    percentile: 25
    sql: ${highest_level_reached} ;;
    value_format_name: decimal_2
  }

  set: user_fact_drills {
    fields: [user_id,player_first_seen_date,player_last_seen_date,days_played,lifetime_revenue]
  }

}
