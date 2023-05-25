#### User Fact Table ####
view: lifetime_user_facts {
  drill_fields: [user_id]
  derived_table: {
    datagroup_trigger: events_raw
    sql:
           SELECT
             user_id as user_id
                -- First and Latest Seen
                ,MIN(event) AS first_seen
              ,MAX(event) AS latest_seen

      -- Match_Started
      ,MIN(CASE WHEN event_name = 'Match_Started'  THEN event ELSE NULL END) AS first_matchstarted
      ,MAX(CASE WHEN event_name = 'Match_Started' THEN event ELSE NULL END) AS latest_matchstarted
      ,COUNT(CASE WHEN event_name = 'Match_Started' THEN 1 ELSE NULL END) AS lifetime_matchstarted

      -- Match_Ended
      ,MIN(CASE WHEN event_name = 'Match_Ended'  THEN event ELSE NULL END) AS first_matchended
      ,MAX(CASE WHEN event_name = 'Match_Ended' THEN event ELSE NULL END) AS latest_matchended
      ,COUNT(CASE WHEN event_name = 'Match_Ended' THEN 1 ELSE NULL END) AS lifetime_matchended

      -- Ad_Watched
      ,MIN(CASE WHEN event_name = 'Ad_Watched'  THEN event ELSE NULL END) AS first_adwatched
      ,MAX(CASE WHEN event_name = 'Ad_Watched' THEN event ELSE NULL END) AS latest_adwatched
      ,COUNT(CASE WHEN event_name = 'Ad_Watched' THEN 1 ELSE NULL END) AS lifetime_adwatched

      -- Level_Up
      ,MIN(CASE WHEN event_name = 'Level_Up'  THEN event ELSE NULL END) AS first_levelup
      ,MAX(CASE WHEN event_name = 'Level_Up' THEN event ELSE NULL END) AS latest_levelup
      ,COUNT(CASE WHEN event_name = 'Level_Up' THEN 1 ELSE NULL END) AS lifetime_levelup

      -- Session_Started
      ,MIN(CASE WHEN event_name = 'Session_Started'  THEN event ELSE NULL END) AS first_sessionstarted
      ,MAX(CASE WHEN event_name = 'Session_Started' THEN event ELSE NULL END) AS latest_sessionstarted
      ,COUNT(CASE WHEN event_name = 'Session_Started' THEN 1 ELSE NULL END) AS lifetime_sessionstarted

      -- FTUE_Stage_Complete
      ,MIN(CASE WHEN event_name = 'FTUE_Stage_Complete'  THEN event ELSE NULL END) AS first_ftuestagecomplete
      ,MAX(CASE WHEN event_name = 'FTUE_Stage_Complete' THEN event ELSE NULL END) AS latest_ftuestagecomplete
      ,COUNT(CASE WHEN event_name = 'FTUE_Stage_Complete' THEN 1 ELSE NULL END) AS lifetime_ftuestagecomplete

      -- Gem_Spend
      ,MIN(CASE WHEN event_name = 'Gem_Spend'  THEN event ELSE NULL END) AS first_gemspend
      ,MAX(CASE WHEN event_name = 'Gem_Spend' THEN event ELSE NULL END) AS latest_gemspend
      ,COUNT(CASE WHEN event_name = 'Gem_Spend' THEN 1 ELSE NULL END) AS lifetime_gemspend

      -- FTUE_Stage_Started
      ,MIN(CASE WHEN event_name = 'FTUE_Stage_Started'  THEN event ELSE NULL END) AS first_ftuestagestarted
      ,MAX(CASE WHEN event_name = 'FTUE_Stage_Started' THEN event ELSE NULL END) AS latest_ftuestagestarted
      ,COUNT(CASE WHEN event_name = 'FTUE_Stage_Started' THEN 1 ELSE NULL END) AS lifetime_ftuestagestarted

      -- IAP_Started
      ,MIN(CASE WHEN event_name = 'IAP_Started'  THEN event ELSE NULL END) AS first_iapstarted
      ,MAX(CASE WHEN event_name = 'IAP_Started' THEN event ELSE NULL END) AS latest_iapstarted
      ,COUNT(CASE WHEN event_name = 'IAP_Started' THEN 1 ELSE NULL END) AS lifetime_iapstarted

      -- Skin_Unlocked
      ,MIN(CASE WHEN event_name = 'Skin_Unlocked'  THEN event ELSE NULL END) AS first_skinunlocked
      ,MAX(CASE WHEN event_name = 'Skin_Unlocked' THEN event ELSE NULL END) AS latest_skinunlocked
      ,COUNT(CASE WHEN event_name = 'Skin_Unlocked' THEN 1 ELSE NULL END) AS lifetime_skinunlocked

      -- Harvest_Done
      ,MIN(CASE WHEN event_name = 'Harvest_Done'  THEN event ELSE NULL END) AS first_harvestdone
      ,MAX(CASE WHEN event_name = 'Harvest_Done' THEN event ELSE NULL END) AS latest_harvestdone
      ,COUNT(CASE WHEN event_name = 'Harvest_Done' THEN 1 ELSE NULL END) AS lifetime_harvestdone

      -- in_app_purchase
      ,MIN(CASE WHEN event_name = 'in_app_purchase'  THEN event ELSE NULL END) AS first_inapppurchase
      ,MAX(CASE WHEN event_name = 'in_app_purchase' THEN event ELSE NULL END) AS latest_inapppurchase
      ,COUNT(CASE WHEN event_name = 'in_app_purchase' THEN 1 ELSE NULL END) AS lifetime_inapppurchase

      FROM `gaming_demo_dev.events_sessionized`
      GROUP BY user_id;;
  }
#### Date Comparitor ####

  dimension_group: comparitor {
    view_label: "Date Comparisons"
    type: duration
    sql_start:
      {% if first_date._parameter_value == 'CURRENT_TIMESTAMP' %}
      CURRENT_TIMESTAMP
      {% else %}
      ${TABLE}.{% parameter first_date %}
      {% endif %};;
    sql_end:
       {% if second_date._parameter_value == 'CURRENT_TIMESTAMP' %}
        CURRENT_TIMESTAMP
      {% else %}
        ${TABLE}.{% parameter second_date %}
      {% endif %};;
  }

  parameter: first_date {
    type: unquoted
    view_label: "Date Comparisons"
    allowed_value: { label: "Today" value: "CURRENT_TIMESTAMP" }
    allowed_value: { label: "First Match_Started" value: "first_matchstarted"}
    allowed_value: { label: "First Match_Ended" value: "first_matchended"}
    allowed_value: { label: "First Ad_Watched" value: "first_adwatched"}
    allowed_value: { label: "First Level_Up" value: "first_levelup"}
    allowed_value: { label: "First Session_Started" value: "first_sessionstarted"}
    allowed_value: { label: "First FTUE_Stage_Complete" value: "first_ftuestagecomplete"}
    allowed_value: { label: "First Gem_Spend" value: "first_gemspend"}
    allowed_value: { label: "First FTUE_Stage_Started" value: "first_ftuestagestarted"}
    allowed_value: { label: "First IAP_Started" value: "first_iapstarted"}
    allowed_value: { label: "First Skin_Unlocked" value: "first_skinunlocked"}
    allowed_value: { label: "First Harvest_Done" value: "first_harvestdone"}
    allowed_value: { label: "First in_app_purchase" value: "first_inapppurchase"}
    allowed_value: { label: "Latest Match_Started" value: "latest_matchstarted"}
    allowed_value: { label: "Latest Match_Ended" value: "latest_matchended"}
    allowed_value: { label: "Latest Ad_Watched" value: "latest_adwatched"}
    allowed_value: { label: "Latest Level_Up" value: "latest_levelup"}
    allowed_value: { label: "Latest Session_Started" value: "latest_sessionstarted"}
    allowed_value: { label: "Latest FTUE_Stage_Complete" value: "latest_ftuestagecomplete"}
    allowed_value: { label: "Latest Gem_Spend" value: "latest_gemspend"}
    allowed_value: { label: "Latest FTUE_Stage_Started" value: "latest_ftuestagestarted"}
    allowed_value: { label: "Latest IAP_Started" value: "latest_iapstarted"}
    allowed_value: { label: "Latest Skin_Unlocked" value: "latest_skinunlocked"}
    allowed_value: { label: "Latest Harvest_Done" value: "latest_harvestdone"}
    allowed_value: { label: "Latest in_app_purchase" value: "latest_inapppurchase"}
  }
  parameter: second_date {
    type: unquoted
    view_label: "Date Comparisons"
    allowed_value: { label: "Today" value: "CURRENT_TIMESTAMP" }
    allowed_value: { label: "First Match_Started" value: "first_matchstarted"}
    allowed_value: { label: "First Match_Ended" value: "first_matchended"}
    allowed_value: { label: "First Ad_Watched" value: "first_adwatched"}
    allowed_value: { label: "First Level_Up" value: "first_levelup"}
    allowed_value: { label: "First Session_Started" value: "first_sessionstarted"}
    allowed_value: { label: "First FTUE_Stage_Complete" value: "first_ftuestagecomplete"}
    allowed_value: { label: "First Gem_Spend" value: "first_gemspend"}
    allowed_value: { label: "First FTUE_Stage_Started" value: "first_ftuestagestarted"}
    allowed_value: { label: "First IAP_Started" value: "first_iapstarted"}
    allowed_value: { label: "First Skin_Unlocked" value: "first_skinunlocked"}
    allowed_value: { label: "First Harvest_Done" value: "first_harvestdone"}
    allowed_value: { label: "First in_app_purchase" value: "first_inapppurchase"}
    allowed_value: { label: "Latest Match_Started" value: "latest_matchstarted"}
    allowed_value: { label: "Latest Match_Ended" value: "latest_matchended"}
    allowed_value: { label: "Latest Ad_Watched" value: "latest_adwatched"}
    allowed_value: { label: "Latest Level_Up" value: "latest_levelup"}
    allowed_value: { label: "Latest Session_Started" value: "latest_sessionstarted"}
    allowed_value: { label: "Latest FTUE_Stage_Complete" value: "latest_ftuestagecomplete"}
    allowed_value: { label: "Latest Gem_Spend" value: "latest_gemspend"}
    allowed_value: { label: "Latest FTUE_Stage_Started" value: "latest_ftuestagestarted"}
    allowed_value: { label: "Latest IAP_Started" value: "latest_iapstarted"}
    allowed_value: { label: "Latest Skin_Unlocked" value: "latest_skinunlocked"}
    allowed_value: { label: "Latest Harvest_Done" value: "latest_harvestdone"}
    allowed_value: { label: "Latest in_app_purchase" value: "latest_inapppurchase"}
  }
#### LookML Definitions ####

  dimension:user_id  {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: first_seen {
    type: time
  }
  dimension_group: last_seen {
    type: time
  }


## Match_Started
  dimension_group: first_matchstarted {
    label: "First Match_Started"
    group_label: "Match_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_matchstarted;;
  }

  dimension_group: latest_matchstarted {
    label: "Latest Match_Started"
    group_label: "Match_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_matchstarted;;
  }

  dimension: lifetime_matchstarted {
    label: "Lifetime Match_Started"
    group_label: "Match_Started"
    type: number
    sql: ${TABLE}.lifetime_matchstarted;;
    value_format_name: decimal_0
  }

  dimension: used_matchstarted {
    label: "Ever Used Match_Started?"
    group_label: "Match_Started"
    type: yesno
    sql: ${TABLE}.lifetime_matchstarted > 0;;
  }

  dimension: tier_matchstarted {
    label: "Tier Match_Started"
    group_label: "Match_Started"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_matchstarted;;
    style: integer
  }

  measure: number_of_users_matchstarted {
    label: "Number of Users Match_Started"
    group_label: "Match_Started"
    type: count
    filters: { field: used_matchstarted value: "yes" }
  }

  measure: percent_of_users_matchstarted {
    label: "Percent of Users that ever Match_Started"
    group_label: "Match_Started"
    type: number
    sql: 1.0 * ${number_of_users_matchstarted} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## Match_Ended
  dimension_group: first_matchended {
    label: "First Match_Ended"
    group_label: "Match_Ended"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_matchended;;
  }

  dimension_group: latest_matchended {
    label: "Latest Match_Ended"
    group_label: "Match_Ended"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_matchended;;
  }

  dimension: lifetime_matchended {
    label: "Lifetime Match_Ended"
    group_label: "Match_Ended"
    type: number
    sql: ${TABLE}.lifetime_matchended;;
    value_format_name: decimal_0
  }

  dimension: used_matchended {
    label: "Ever Used Match_Ended?"
    group_label: "Match_Ended"
    type: yesno
    sql: ${TABLE}.lifetime_matchended > 0;;
  }

  dimension: tier_matchended {
    label: "Tier Match_Ended"
    group_label: "Match_Ended"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_matchended;;
    style: integer
  }

  measure: number_of_users_matchended {
    label: "Number of Users Match_Ended"
    group_label: "Match_Ended"
    type: count
    filters: { field: used_matchended value: "yes" }
  }

  measure: percent_of_users_matchended {
    label: "Percent of Users that ever Match_Ended"
    group_label: "Match_Ended"
    type: number
    sql: 1.0 * ${number_of_users_matchended} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## Ad_Watched
  dimension_group: first_adwatched {
    label: "First Ad_Watched"
    group_label: "Ad_Watched"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_adwatched;;
  }

  dimension_group: latest_adwatched {
    label: "Latest Ad_Watched"
    group_label: "Ad_Watched"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_adwatched;;
  }

  dimension: lifetime_adwatched {
    label: "Lifetime Ad_Watched"
    group_label: "Ad_Watched"
    type: number
    sql: ${TABLE}.lifetime_adwatched;;
    value_format_name: decimal_0
  }

  dimension: used_adwatched {
    label: "Ever Used Ad_Watched?"
    group_label: "Ad_Watched"
    type: yesno
    sql: ${TABLE}.lifetime_adwatched > 0;;
  }

  dimension: tier_adwatched {
    label: "Tier Ad_Watched"
    group_label: "Ad_Watched"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_adwatched;;
    style: integer
  }

  measure: number_of_users_adwatched {
    label: "Number of Users Ad_Watched"
    group_label: "Ad_Watched"
    type: count
    filters: { field: used_adwatched value: "yes" }
  }

  measure: percent_of_users_adwatched {
    label: "Percent of Users that ever Ad_Watched"
    group_label: "Ad_Watched"
    type: number
    sql: 1.0 * ${number_of_users_adwatched} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## Level_Up
  dimension_group: first_levelup {
    label: "First Level_Up"
    group_label: "Level_Up"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_levelup;;
  }

  dimension_group: latest_levelup {
    label: "Latest Level_Up"
    group_label: "Level_Up"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_levelup;;
  }

  dimension: lifetime_levelup {
    label: "Lifetime Level_Up"
    group_label: "Level_Up"
    type: number
    sql: ${TABLE}.lifetime_levelup;;
    value_format_name: decimal_0
  }

  dimension: used_levelup {
    label: "Ever Used Level_Up?"
    group_label: "Level_Up"
    type: yesno
    sql: ${TABLE}.lifetime_levelup > 0;;
  }

  dimension: tier_levelup {
    label: "Tier Level_Up"
    group_label: "Level_Up"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_levelup;;
    style: integer
  }

  measure: number_of_users_levelup {
    label: "Number of Users Level_Up"
    group_label: "Level_Up"
    type: count
    filters: { field: used_levelup value: "yes" }
  }

  measure: percent_of_users_levelup {
    label: "Percent of Users that ever Level_Up"
    group_label: "Level_Up"
    type: number
    sql: 1.0 * ${number_of_users_levelup} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## Session_Started
  dimension_group: first_sessionstarted {
    label: "First Session_Started"
    group_label: "Session_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_sessionstarted;;
  }

  dimension_group: latest_sessionstarted {
    label: "Latest Session_Started"
    group_label: "Session_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_sessionstarted;;
  }

  dimension: lifetime_sessionstarted {
    label: "Lifetime Session_Started"
    group_label: "Session_Started"
    type: number
    sql: ${TABLE}.lifetime_sessionstarted;;
    value_format_name: decimal_0
  }

  dimension: used_sessionstarted {
    label: "Ever Used Session_Started?"
    group_label: "Session_Started"
    type: yesno
    sql: ${TABLE}.lifetime_sessionstarted > 0;;
  }

  dimension: tier_sessionstarted {
    label: "Tier Session_Started"
    group_label: "Session_Started"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_sessionstarted;;
    style: integer
  }

  measure: number_of_users_sessionstarted {
    label: "Number of Users Session_Started"
    group_label: "Session_Started"
    type: count
    filters: { field: used_sessionstarted value: "yes" }
  }

  measure: percent_of_users_sessionstarted {
    label: "Percent of Users that ever Session_Started"
    group_label: "Session_Started"
    type: number
    sql: 1.0 * ${number_of_users_sessionstarted} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## FTUE_Stage_Complete
  dimension_group: first_ftuestagecomplete {
    label: "First FTUE_Stage_Complete"
    group_label: "FTUE_Stage_Complete"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_ftuestagecomplete;;
  }

  dimension_group: latest_ftuestagecomplete {
    label: "Latest FTUE_Stage_Complete"
    group_label: "FTUE_Stage_Complete"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_ftuestagecomplete;;
  }

  dimension: lifetime_ftuestagecomplete {
    label: "Lifetime FTUE_Stage_Complete"
    group_label: "FTUE_Stage_Complete"
    type: number
    sql: ${TABLE}.lifetime_ftuestagecomplete;;
    value_format_name: decimal_0
  }

  dimension: used_ftuestagecomplete {
    label: "Ever Used FTUE_Stage_Complete?"
    group_label: "FTUE_Stage_Complete"
    type: yesno
    sql: ${TABLE}.lifetime_ftuestagecomplete > 0;;
  }

  dimension: tier_ftuestagecomplete {
    label: "Tier FTUE_Stage_Complete"
    group_label: "FTUE_Stage_Complete"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_ftuestagecomplete;;
    style: integer
  }

  measure: number_of_users_ftuestagecomplete {
    label: "Number of Users FTUE_Stage_Complete"
    group_label: "FTUE_Stage_Complete"
    type: count
    filters: { field: used_ftuestagecomplete value: "yes" }
  }

  measure: percent_of_users_ftuestagecomplete {
    label: "Percent of Users that ever FTUE_Stage_Complete"
    group_label: "FTUE_Stage_Complete"
    type: number
    sql: 1.0 * ${number_of_users_ftuestagecomplete} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## Gem_Spend
  dimension_group: first_gemspend {
    label: "First Gem_Spend"
    group_label: "Gem_Spend"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_gemspend;;
  }

  dimension_group: latest_gemspend {
    label: "Latest Gem_Spend"
    group_label: "Gem_Spend"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_gemspend;;
  }

  dimension: lifetime_gemspend {
    label: "Lifetime Gem_Spend"
    group_label: "Gem_Spend"
    type: number
    sql: ${TABLE}.lifetime_gemspend;;
    value_format_name: decimal_0
  }

  dimension: used_gemspend {
    label: "Ever Used Gem_Spend?"
    group_label: "Gem_Spend"
    type: yesno
    sql: ${TABLE}.lifetime_gemspend > 0;;
  }

  dimension: tier_gemspend {
    label: "Tier Gem_Spend"
    group_label: "Gem_Spend"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_gemspend;;
    style: integer
  }

  measure: number_of_users_gemspend {
    label: "Number of Users Gem_Spend"
    group_label: "Gem_Spend"
    type: count
    filters: { field: used_gemspend value: "yes" }
  }

  measure: percent_of_users_gemspend {
    label: "Percent of Users that ever Gem_Spend"
    group_label: "Gem_Spend"
    type: number
    sql: 1.0 * ${number_of_users_gemspend} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## FTUE_Stage_Started
  dimension_group: first_ftuestagestarted {
    label: "First FTUE_Stage_Started"
    group_label: "FTUE_Stage_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_ftuestagestarted;;
  }

  dimension_group: latest_ftuestagestarted {
    label: "Latest FTUE_Stage_Started"
    group_label: "FTUE_Stage_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_ftuestagestarted;;
  }

  dimension: lifetime_ftuestagestarted {
    label: "Lifetime FTUE_Stage_Started"
    group_label: "FTUE_Stage_Started"
    type: number
    sql: ${TABLE}.lifetime_ftuestagestarted;;
    value_format_name: decimal_0
  }

  dimension: used_ftuestagestarted {
    label: "Ever Used FTUE_Stage_Started?"
    group_label: "FTUE_Stage_Started"
    type: yesno
    sql: ${TABLE}.lifetime_ftuestagestarted > 0;;
  }

  dimension: tier_ftuestagestarted {
    label: "Tier FTUE_Stage_Started"
    group_label: "FTUE_Stage_Started"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_ftuestagestarted;;
    style: integer
  }

  measure: number_of_users_ftuestagestarted {
    label: "Number of Users FTUE_Stage_Started"
    group_label: "FTUE_Stage_Started"
    type: count
    filters: { field: used_ftuestagestarted value: "yes" }
  }

  measure: percent_of_users_ftuestagestarted {
    label: "Percent of Users that ever FTUE_Stage_Started"
    group_label: "FTUE_Stage_Started"
    type: number
    sql: 1.0 * ${number_of_users_ftuestagestarted} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## IAP_Started
  dimension_group: first_iapstarted {
    label: "First IAP_Started"
    group_label: "IAP_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_iapstarted;;
  }

  dimension_group: latest_iapstarted {
    label: "Latest IAP_Started"
    group_label: "IAP_Started"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_iapstarted;;
  }

  dimension: lifetime_iapstarted {
    label: "Lifetime IAP_Started"
    group_label: "IAP_Started"
    type: number
    sql: ${TABLE}.lifetime_iapstarted;;
    value_format_name: decimal_0
  }

  dimension: used_iapstarted {
    label: "Ever Used IAP_Started?"
    group_label: "IAP_Started"
    type: yesno
    sql: ${TABLE}.lifetime_iapstarted > 0;;
  }

  dimension: tier_iapstarted {
    label: "Tier IAP_Started"
    group_label: "IAP_Started"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_iapstarted;;
    style: integer
  }

  measure: number_of_users_iapstarted {
    label: "Number of Users IAP_Started"
    group_label: "IAP_Started"
    type: count
    filters: { field: used_iapstarted value: "yes" }
  }

  measure: percent_of_users_iapstarted {
    label: "Percent of Users that ever IAP_Started"
    group_label: "IAP_Started"
    type: number
    sql: 1.0 * ${number_of_users_iapstarted} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## Skin_Unlocked
  dimension_group: first_skinunlocked {
    label: "First Skin_Unlocked"
    group_label: "Skin_Unlocked"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_skinunlocked;;
  }

  dimension_group: latest_skinunlocked {
    label: "Latest Skin_Unlocked"
    group_label: "Skin_Unlocked"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_skinunlocked;;
  }

  dimension: lifetime_skinunlocked {
    label: "Lifetime Skin_Unlocked"
    group_label: "Skin_Unlocked"
    type: number
    sql: ${TABLE}.lifetime_skinunlocked;;
    value_format_name: decimal_0
  }

  dimension: used_skinunlocked {
    label: "Ever Used Skin_Unlocked?"
    group_label: "Skin_Unlocked"
    type: yesno
    sql: ${TABLE}.lifetime_skinunlocked > 0;;
  }

  dimension: tier_skinunlocked {
    label: "Tier Skin_Unlocked"
    group_label: "Skin_Unlocked"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_skinunlocked;;
    style: integer
  }

  measure: number_of_users_skinunlocked {
    label: "Number of Users Skin_Unlocked"
    group_label: "Skin_Unlocked"
    type: count
    filters: { field: used_skinunlocked value: "yes" }
  }

  measure: percent_of_users_skinunlocked {
    label: "Percent of Users that ever Skin_Unlocked"
    group_label: "Skin_Unlocked"
    type: number
    sql: 1.0 * ${number_of_users_skinunlocked} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## Harvest_Done
  dimension_group: first_harvestdone {
    label: "First Harvest_Done"
    group_label: "Harvest_Done"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_harvestdone;;
  }

  dimension_group: latest_harvestdone {
    label: "Latest Harvest_Done"
    group_label: "Harvest_Done"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_harvestdone;;
  }

  dimension: lifetime_harvestdone {
    label: "Lifetime Harvest_Done"
    group_label: "Harvest_Done"
    type: number
    sql: ${TABLE}.lifetime_harvestdone;;
    value_format_name: decimal_0
  }

  dimension: used_harvestdone {
    label: "Ever Used Harvest_Done?"
    group_label: "Harvest_Done"
    type: yesno
    sql: ${TABLE}.lifetime_harvestdone > 0;;
  }

  dimension: tier_harvestdone {
    label: "Tier Harvest_Done"
    group_label: "Harvest_Done"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_harvestdone;;
    style: integer
  }

  measure: number_of_users_harvestdone {
    label: "Number of Users Harvest_Done"
    group_label: "Harvest_Done"
    type: count
    filters: { field: used_harvestdone value: "yes" }
  }

  measure: percent_of_users_harvestdone {
    label: "Percent of Users that ever Harvest_Done"
    group_label: "Harvest_Done"
    type: number
    sql: 1.0 * ${number_of_users_harvestdone} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

## in_app_purchase
  dimension_group: first_inapppurchase {
    label: "First in_app_purchase"
    group_label: "in_app_purchase"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.first_inapppurchase;;
  }

  dimension_group: latest_inapppurchase {
    label: "Latest in_app_purchase"
    group_label: "in_app_purchase"
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.latest_inapppurchase;;
  }

  dimension: lifetime_inapppurchase {
    label: "Lifetime in_app_purchase"
    group_label: "in_app_purchase"
    type: number
    sql: ${TABLE}.lifetime_inapppurchase;;
    value_format_name: decimal_0
  }

  dimension: used_inapppurchase {
    label: "Ever Used in_app_purchase?"
    group_label: "in_app_purchase"
    type: yesno
    sql: ${TABLE}.lifetime_inapppurchase > 0;;
  }

  dimension: tier_inapppurchase {
    label: "Tier in_app_purchase"
    group_label: "in_app_purchase"
    type: tier
    tiers: [0,5,10,25,50,100]
    sql: ${TABLE}.lifetime_inapppurchase;;
    style: integer
  }

  measure: number_of_users_inapppurchase {
    label: "Number of Users in_app_purchase"
    group_label: "in_app_purchase"
    type: count
    filters: { field: used_inapppurchase value: "yes" }
  }

  measure: percent_of_users_inapppurchase {
    label: "Percent of Users that ever in_app_purchase"
    group_label: "in_app_purchase"
    type: number
    sql: 1.0 * ${number_of_users_inapppurchase} / NULLIF(${number_of_users},0);;
    value_format_name: percent_2
  }

  measure: number_of_users {
    type: count
  }
}
