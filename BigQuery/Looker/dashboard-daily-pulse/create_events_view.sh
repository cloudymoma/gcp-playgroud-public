#!/bin/bash -ex

bq query --use_legacy_sql=false \
    --parameter=ga_ad_revenue::ad_revenue \
    --parameter=ga_install_cost::install_cost \
    --parameter=ga_gems_earned::gems_earned \
    --parameter=ga_campaign_name::campaign_name \
    --parameter=ga_campaign_id::campaign_id \
    --parameter=ga_ad_network::link_url \
    --parameter=ga_game_name::game_name \
    --parameter=ga_game_version::game_version \
    --parameter=ga_player_level::player_level \
    --parameter=ga_session_id::ga_session_id \
    --parameter=ga_session_number::ga_session_number < create_events_view.sql 
