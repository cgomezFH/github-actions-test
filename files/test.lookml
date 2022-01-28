connection: "lake"
connection: "snowflake"

# include all the views
include: "*.view"

# Include common explores
include: "common/explores/*.lkml"

# Include explores from Product Analytics
include: "product_analytics_ota/explores/booking_experience/*.lkml"
include: "product_analytics_engagement/explores/*.lkml"
include: "product_analytics_marketplace/explores/price_accuracy/*.lkml"
include: "product_analytics_marketplace/explores/offer_served/*.lkml"


# Include explores from Marketing Analytics
include: "marketing_analytics/explores/*.lkml"

# Include explores from User Behaviour Analytics
include: "user_behaviour_analytics/explores/*.lkml"
include: "user_behaviour_analytics/views/**/*.view"

# Include explores from Search Analytics
include: "product_analytics_search/explores/*.lkml"
include: "product_analytics_search/views/search_flattened_events.view"
include: "product_analytics_search/views/price_save_metric.view"
include: "product_analytics_search/views/events_sessions_mapping.view"
include: "product_analytics_search/views/search_fact.view"

# Include explores from Data Quality
include: "data_quality/explores/*.lkml"

# Include explores from Data Squad Analytics
include: "data_squad_analytics/explores/*.lkml"

# Include explores from Impression Analytics
include: "impression_analytics/explores/*.lkml"

# Include explores from Customer Analytics
include: "customer_analytics/explores/*.lkml"

# include all the dashboards
# include: "data_health.dashboard"
# include: "experiment_details.dashboard"
# include: "experiment_summary.dashboard"
# include: "analytics_session_flat_test_dashboard.dashboard"
include: "provider_commission_health.dashboard"
include: "topology_indy.dashboard"

# datagroup: analytics_default_datagroup {
#   # sql_trigger: SELECT MAX(id) FROM etl_log;;
#   max_cache_age: "1 hour"
# }


# cache data for 6 hours
persist_for: "6 hours"

# makes filters case-insensitive
case_sensitive: no

explore: session_flat {
  group_label: "Product Performance"
  label: "Session Flat"
  view_label: " Session Flat"
  always_filter: {
    filters: [
      session_flat.date_filter: "7 days"
    ]
  }
  join: experiment {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.anonymous_id} = ${experiment.anonymous_id} ;;
    fields: [experiment.compound_unique_id,experiment.experiment_id,experiment.experiment_name, experiment.variation_id]
  }
  join: experiment_overview {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${experiment.experiment_id} = ${experiment_overview.experiment_id} ;;
    fields: [start_date, days_running, is_experiment_live]
  }
  join: hotel {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${session_flat.landing_hotel_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
            hotel.name, hotel.nb_of_rooms_buckets,hotel.nb_of_rooms,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
            hotel.wk_place_id,hotel.wk_place_name,hotel.state_place_name,hotel.state_place_id,hotel.hotel_count]
  }

  join: hotel_mapping {
    relationship: many_to_one
    view_label: "Hotel Mapping Info"
    sql_on: ${hotel_mapping.hotel_id}=${hotel.hotel_id} ;;
  }
  join: gha_hotel_group {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${session_flat.landing_hotel_id} = ${gha_hotel_group.hotel_id} ;;
    fields: [gha_hotel_group.hotel_group]
  }
  join: place_redirection {
    view_label: "Marketing"
    relationship: many_to_one
    sql_on: ${hotel.place_id}=${place_redirection.from_place_id} ;;
    fields: [place_redirection.from_place_id,place_redirection.granular_to_place_id,
            place_redirection.granular_to_place_name,place_redirection.to_place_id,place_redirection.to_place_name]
  }
  join: place {
    view_label: "Place Info (for place landing traffic)"
    relationship: many_to_one
    sql_on: ${session_flat.landing_place_id} = ${place.place_id} ;;
    fields: [place.display_name,place.name,place.place_id,place.place_type_id,place.place_type_name]
  }
  join: all_provider_chains {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
    fields: [all_provider_chains.AGD_chain_id,all_provider_chains.AGD_chain_name,all_provider_chains.BKS_chain_id,all_provider_chains.BKS_chain_name,
            all_provider_chains.EAN_chain_id,all_provider_chains.EAN_chain_name,all_provider_chains.PPN_chain_id,all_provider_chains.PPN_chain_name
            ,all_provider_chains.GAR_chain_id,all_provider_chains.GAR_chain_name]
  }
  join: hco_chain {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
    fields: [hco_chain.parent_chain_id,hco_chain.parent_chain_name,hco_chain.trademarked,hco_chain.chain_groups]
  }
  join: bd_provider_joins {
    view_label: "BD Provider Joins"
    relationship: many_to_many
    sql_on:  ${session_flat.landing_hotel_id} = ${bd_provider_joins.hotel_id};;
  }
  join: load_times {
    view_label: "Product"
    relationship: one_to_one
    sql_on:  ${session_flat.session_id} = ${load_times.session_id};;
    fields: [load_times.for_session_flat*]
  }
  join: session_length {
    view_label: "Product"
    relationship: one_to_one
    sql_on:  ${session_flat.session_id} = ${session_length.session_id};;
    fields: [session_length.for_session_flat*]
  }
  join: guest_picker {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.anonymous_id} = ${guest_picker.anonymous_id};;
    fields: [guest_picker.interacted_with_guest_picker,guest_picker.share_of_users_interacted_with_guest_picker]
  }
  join: sort_session {
    view_label: "Product"
    relationship: one_to_one
    sql_on: ${session_flat.session_id} = ${sort_session.session_id} ;;
    fields: [sort_session.price_sort,sort_session.share_of_sessions_with_price_sort_used]
  }
  join: filters_session {
    view_label: "Product"
    relationship: one_to_one
    sql_on: ${session_flat.anonymous_id} = ${filters_session.anonymous_id} and ${session_flat.date}=${filters_session.date} ;;
    fields: [filters_session.for_session_flat*]
  }
  join: geo_clustering_kostas {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${session_flat.landing_hotel_id}=${geo_clustering_kostas.hotel_id} ;;
  }
  join: pd_susi_viewers {
    view_label: "PD&SUSI"
    relationship: many_to_one
    sql_on: ${session_flat.anonymous_id}=${pd_susi_viewers.anonymous_id} and ${session_flat.date}=${pd_susi_viewers.date} ;;
    fields: [pd_susi_viewers.for_session_flat*]
  }
  join: pd_susi_clickers {
    view_label: "PD&SUSI"
    relationship: many_to_one
    sql_on: ${session_flat.anonymous_id}=${pd_susi_clickers.anonymous_id} and ${session_flat.date}=${pd_susi_clickers.date} ;;
    fields: [pd_susi_clickers.for_session_flat*]
  }
  join: pd_susi_users {
    view_label: "PD&SUSI"
    relationship: many_to_one
    sql_on: ${session_flat.anonymous_id}=${pd_susi_users.anonymous_id} and ${session_flat.date}=${pd_susi_users.date} ;;
    fields: [pd_susi_users.for_session_flat*]
  }
  join: hotel_search_metrics_for_session_flat {
    view_label: "Unavailability"
    relationship: one_to_one
    sql_on: ${session_flat.session_id}=${hotel_search_metrics_for_session_flat.session_id} ;;
  }
  join: popuponexit {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.anonymous_id}=${popuponexit.anonymous_id} and ${session_flat.date}=${popuponexit.date} ;;
  }
  join: useraction {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.anonymous_id}=${useraction.anonymous_id} and ${session_flat.date}=${useraction.date} ;;
  }
  join: first_visit {
    view_label: "Retention Metrics"
    relationship: one_to_many
    sql_on: ${first_visit.anonymous_id}=${session_flat.anonymous_id} ;;
    #fields: []
  }
  join: experiment_seen {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${filters_session.anonymous_id}=${experiment_seen.anonymous_id};;
  }
  join: hotel_stats {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${session_flat.landing_hotel_id} =  ${hotel_stats.hotel_id};;
  }
  join: place_stats {
    view_label: "Place Info (for place landing traffic)"
    relationship: many_to_one
    sql_on: ${session_flat.landing_place_id} =  ${place_stats.place_id};;
  }
  join: user_mapping {
    view_label: "User Mapping"
    type: left_outer
    relationship: one_to_one
    sql_on: ${session_flat.anonymous_id} = ${user_mapping.anonymous_id} ;;
  }
  join: dim_user {
    view_label: "User"
    type: left_outer
    relationship: many_to_one
    sql_on: COALESCE(${user_mapping.id_hash}, ${session_flat.anonymous_id}) = ${dim_user.id};;
  }
  join: sessions_changing_default_dates {
    view_label: "Product"
    relationship: one_to_one
    sql_on: ${session_flat.session_id} = ${sessions_changing_default_dates.session_id} ;;
  }
  join: sessions_with_multiple_check_in_out_dates {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.session_id} = ${sessions_with_multiple_check_in_out_dates.session_id} ;;
  }
  join: sessions_with_multiple_destinations_searched {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.session_id} = ${sessions_with_multiple_destinations_searched.session_id} ;;
  }
  join: sessions_with_multiple_room_configurations_searched {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.session_id} = ${sessions_with_multiple_room_configurations_searched.session_id} ;;
  }
  join: country_calling_codes {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${session_flat.country_code} = ${country_calling_codes.country_code} ;;
  }
  join: device {
    view_label: "Device"
    relationship: many_to_one
    type: left_outer
    sql_on: ${session_flat.anonymous_id} = ${device.anonymous_id} ;;
  }
  join: sessions_with_product_interaction {
    view_label: "Product"
    relationship: one_to_one
    sql_on: ${sessions_with_product_interaction.session_id} = ${session_flat.session_id} ;;
  }
  join: lead_flat {
    view_label: "Leads"
    relationship: many_to_many
    sql_on: ${session_flat.session_id} = ${lead_flat.session_id};;
  }
  #Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if session_flat.current_date_range._is_filtered %}
  {% condition session_flat.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if session_flat.previous_date_range._is_filtered or session_flat.compare_to._in_query %}
  {% if session_flat.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif session_flat.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif session_flat.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;

}

explore: session_flat_poc {
  group_label: "Product Performance"
  label: "Session Flat POC"
  view_label: "Session Flat POC"
  always_filter: {
    filters: {
      field: session_flat_poc.date_filter
      value: "7 days"
    }
  }
  join: experiment {
    view_label: "Experiment"
    relationship: many_to_one
    sql_on: ${session_flat_poc.anonymous_id} = ${experiment.anonymous_id} ;;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${session_flat_poc.landing_hotel_id} = ${hotel.hotel_id} ;;
  }
  join: place_redirection {
    view_label: "Hotel Info (Extended)"
    relationship: many_to_one
    sql_on: ${hotel.place_id}=${place_redirection.from_place_id} ;;
  }
  join: place {
    view_label: "Place Info (for place landing traffic)"
    relationship: many_to_one
    sql_on: ${session_flat_poc.landing_place_id} = ${place.place_id} ;;
  }
  join: all_provider_chains {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
  }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
  }

  join: load_times_poc {
    view_label: "Load Times POC (speed metrics)"
    relationship: one_to_one
    sql_on:  ${session_flat_poc.session_id} = ${load_times_poc.session_id};;
  }
  join: session_length {
    view_label: "Session Length (Duration)"
    relationship: one_to_one
    sql_on:  ${session_flat_poc.session_id} = ${session_length.session_id};;
  }
  join: guest_picker {
    view_label: "Interaction with Guest Picker"
    relationship: many_to_one
    sql_on: ${session_flat_poc.anonymous_id} = ${guest_picker.anonymous_id};;
  }
  join: sort_session {
    view_label: "Sort"
    relationship: one_to_one
    sql_on: ${session_flat_poc.session_id} = ${sort_session.session_id} ;;
  }
  join: filters_session {
    view_label: "Filters"
    relationship: one_to_one
    sql_on: ${session_flat_poc.anonymous_id} = ${filters_session.anonymous_id} and ${session_flat_poc.date}=${filters_session.date} ;;
  }

  join: pd_susi_viewers {
    view_label: "PD&SUSI: Viewers of Private Deal components"
    relationship: many_to_one
    sql_on: ${session_flat_poc.anonymous_id}=${pd_susi_viewers.anonymous_id} and ${session_flat_poc.date}=${pd_susi_viewers.date} ;;
  }
  join: pd_susi_clickers {
    view_label: "PD&SUSI: Clickers on PD&SUSI components"
    relationship: many_to_one
    sql_on: ${session_flat_poc.anonymous_id}=${pd_susi_clickers.anonymous_id} and ${session_flat_poc.date}=${pd_susi_clickers.date} ;;
  }
  join: pd_susi_users {
    view_label: "PD&SUSI Signed-in Users & Registration"
    relationship: many_to_one
    sql_on: ${session_flat_poc.anonymous_id}=${pd_susi_users.anonymous_id} and ${session_flat_poc.date}=${pd_susi_users.date} ;;
  }
  join: hotel_search_metrics_for_session_flat {
    view_label: "Anchor Hotel Unavailability"
    relationship: one_to_one
    sql_on: ${session_flat_poc.session_id}=${hotel_search_metrics_for_session_flat.session_id} ;;
  }
  join: popuponexit {
    view_label: "Pop-up On Exit"
    relationship: many_to_one
    sql_on: ${session_flat_poc.anonymous_id}=${popuponexit.anonymous_id} and ${session_flat_poc.date}=${popuponexit.date} ;;
  }
  join: useraction {
    view_label: "User Actions"
    relationship: many_to_one
    sql_on: ${session_flat_poc.anonymous_id}=${useraction.anonymous_id} and ${session_flat_poc.date}=${useraction.date} ;;
  }
  #Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if session_flat_poc.current_date_range._is_filtered %}
  {% condition session_flat_poc.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if session_flat_poc.previous_date_range._is_filtered or session_flat_poc.compare_to._in_query %}
  {% if session_flat_poc.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif session_flat_poc.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif session_flat_poc.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;

}

explore: booking_flat {
  group_label: "Product Performance"
  label: "Booking Flat"
  view_label: " Booking Flat"
  always_filter: {
    filters: {
      field: booking_flat.date_filter
      value: "7 days"
    }
  }
  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${booking_flat.hotel_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.nb_of_rooms,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.state_place_name,hotel.state_place_id,hotel.hotel_count,hotel.country]
  }

  join: hotel_mapping {
    relationship: many_to_one
    view_label: "Hotel Mapping Info"
    sql_on: ${hotel_mapping.hotel_id}=${hotel.hotel_id} ;;
  }
  join: place_redirection {
    view_label: "Marketing"
    relationship: many_to_one
    sql_on: ${hotel.place_id}=${place_redirection.from_place_id} ;;
    fields: [place_redirection.from_place_id,place_redirection.granular_to_place_id,
      place_redirection.granular_to_place_name,place_redirection.to_place_id,place_redirection.to_place_name]
  }

  join: all_provider_chains {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
    fields: [all_provider_chains.AGD_chain_id,all_provider_chains.AGD_chain_name,all_provider_chains.BKS_chain_id,all_provider_chains.BKS_chain_name,
      all_provider_chains.EAN_chain_id,all_provider_chains.EAN_chain_name,all_provider_chains.PPN_chain_id,all_provider_chains.PPN_chain_name]
  }
  join: hco_chain {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
    fields: [hco_chain.parent_chain_id,hco_chain.parent_chain_name,hco_chain.trademarked,hco_chain.chain_groups]
  }

  join: place {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.place_id} = ${place.place_id} ;;
    fields: [place.display_name,place.name,place.place_id,place.place_type_id,place.place_type_name]
  }
  # join: net_rate_hotels {
  #   view_label: "Net Rate hotels"
  #   relationship: many_to_one
  #   sql_on: ${booking_flat.hotel_id} = ${net_rate_hotels.hotel_id} AND ${booking_flat.date} = ${net_rate_hotels.date_date} ;;
  # }
  # join: net_rate_tests {
  #   view_label: "Net Rate tests"
  #   relationship: many_to_one
  #   sql_on: (${booking_flat.hotel_id} = ${net_rate_tests.hotel_id} AND
  #            ${booking_flat.date} >= ${net_rate_tests.start_date_date} AND
  #            ${booking_flat.date} <= ${net_rate_tests.end_date_date}) ;;
  # }


  join: bd_provider_joins {
    view_label: "BD Provider Joins"
    relationship: many_to_one
    sql_on: ${booking_flat.hotel_id} = ${bd_provider_joins.hotel_id} ;;
  }


  # join: first_booking {
  #   view_label: "Retention Metrics"
  #   relationship: one_to_many
  #   sql_on: ${first_booking.anonymous_id}=${booking_flat.anonymous_id} ;;
  #   #fields: []
  # }
  join: experiment {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${booking_flat.anonymous_id} = ${experiment.anonymous_id} ;;
    fields: [experiment.compound_unique_id,experiment.experiment_id,experiment.experiment_name, experiment.variation_id]
  }
#Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if booking_flat.current_date_range._is_filtered %}
  {% condition booking_flat.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if booking_flat.previous_date_range._is_filtered or booking_flat.compare_to._in_query %}
  {% if booking_flat.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif booking_flat.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif booking_flat.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;

}


explore: lead_flat {
  group_label: "Product Performance"
  label: "Lead Flat"
  view_label: " Lead Flat"
  always_filter: {
    filters: {
      field: lead_flat.date_filter
      value: "7 days"
    }
  }
  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${lead_flat.hotel_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.nb_of_rooms,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.state_place_name,hotel.state_place_id,hotel.hotel_count,hotel.country,star_rating,rating_overall,number_of_reviews_grouped,probability_of_fht_pd,probability_of_fht_pd_bucket,probability_of_fht_pd_bucket_grouped]
  }
  join: hotel_mapping {
    relationship: many_to_one
    view_label: "Hotel Mapping Info"
    sql_on: ${hotel_mapping.hotel_id}=${hotel.hotel_id} ;;
  }
  join: place_redirection {
    view_label: "Marketing"
    relationship: many_to_one
    sql_on: ${hotel.place_id}=${place_redirection.from_place_id} ;;
    fields: [place_redirection.from_place_id,place_redirection.granular_to_place_id,
      place_redirection.granular_to_place_name,place_redirection.to_place_id,place_redirection.to_place_name]
  }
  join: all_provider_chains {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
    fields: [all_provider_chains.AGD_chain_id,all_provider_chains.AGD_chain_name,all_provider_chains.BKS_chain_id,all_provider_chains.BKS_chain_name,
      all_provider_chains.EAN_chain_id,all_provider_chains.EAN_chain_name,all_provider_chains.PPN_chain_id,all_provider_chains.PPN_chain_name]
  }
  join: place {
    view_label: "Place Info (of place for place searches)"
    relationship: many_to_one
    sql_on: ${lead_flat.search_place_id} = ${place.place_id} ;;
    fields: [place.display_name,place.name,place.place_id,place.place_type_id,place.place_type_name]
  }
  join: experiment {
    view_label: "Product"
    relationship: many_to_one
    sql_on: ${lead_flat.anonymous_id} = ${experiment.anonymous_id} ;;
    fields: [experiment.compound_unique_id,experiment.experiment_id,experiment.experiment_name, experiment.variation_id]
  }
  join: agd_hotels_rank {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${lead_flat.hotel_id} = ${agd_hotels_rank.hotel_id} ;;
  }
  # join: net_rate_hotels {
  #   view_label: "Net Rate hotels"
  #   relationship: many_to_one
  #   sql_on: ${lead_flat.hotel_id} = ${net_rate_hotels.hotel_id} AND ${lead_flat.date} = ${net_rate_hotels.date_date} ;;
  # }
  # join: net_rate_tests {
  #   view_label: "Net Rate tests"
  #   relationship: many_to_one
  #   sql_on: (${lead_flat.hotel_id} = ${net_rate_tests.hotel_id} AND
  #            ${lead_flat.date} >= ${net_rate_tests.start_date_date} AND
  #            ${lead_flat.date} <= ${net_rate_tests.end_date_date}) ;;
  # }
  join: hco_chain {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
    fields: [hco_chain.parent_chain_id,hco_chain.parent_chain_name,hco_chain.trademarked,hco_chain.chain_groups]
  }

  join: bd_provider_joins {
    view_label: "BD Provider Joins"
    relationship: many_to_one
    sql_on: ${lead_flat.hotel_id} = ${bd_provider_joins.hotel_id} ;;
  }
  join: hotel_search_metrics_for_session_flat {
    view_label: "Unavailability"
    relationship: one_to_one
    sql_on: ${lead_flat.session_id}=${hotel_search_metrics_for_session_flat.session_id} ;;
  }

  join: gha_hotel_group {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${lead_flat.hotel_id} = ${gha_hotel_group.hotel_id} ;;
    fields: [gha_hotel_group.hotel_group]
  }
  join: sort_session {
    view_label: "Product"
    relationship: one_to_one
    sql_on: ${lead_flat.session_id} = ${sort_session.session_id} ;;
    fields: [sort_session.price_sort,sort_session.share_of_sessions_with_price_sort_used]
  }
  join: filters_session {
    view_label: "Product"
    relationship: one_to_one
    sql_on: ${lead_flat.anonymous_id} = ${filters_session.anonymous_id} and ${lead_flat.date_date}=${filters_session.date} ;;
    fields: [filters_session.for_session_flat*]
  }

  join: hotel_stats {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${lead_flat.hotel_id} =  ${hotel_stats.hotel_id};;
  }
  join: place_stats {
    view_label: "Place Info (of place for place searches)"
    relationship: many_to_one
    sql_on: ${lead_flat.search_place_id} =  ${place_stats.place_id};;
  }
  #Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if lead_flat.current_date_range._is_filtered %}
  {% condition lead_flat.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if lead_flat.previous_date_range._is_filtered or lead_flat.compare_to._in_query %}
  {% if lead_flat.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif lead_flat.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif lead_flat.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;
}

explore: price_index  {
  label: "Price Index"
  view_label: "Price Index"
}

explore: search_flat {
  group_label: "Product Performance"
  label: "Search Flat"
  view_label: "Search Flat"
  always_filter: {
    filters: {
      field: search_flat.date_filter
      value: "7 days"
    }
  }
  join: experiment {
    view_label: "Experiment"
    relationship: many_to_one
    sql_on: ${search_flat.anonymous_id} = ${experiment.anonymous_id} ;;
  }
  join: filters_search {
    view_label: "Filters"
    relationship: many_to_one
    sql_on: ${search_flat.search_id} = ${filters_search.search_id} ;;
  }
  join: property_types {
    view_label: "Filters"
    relationship: many_to_one
    sql_on: ${filters_search.property_type_items_filtered} = ${property_types.property_type_id} ;;
  }
  join: facilities {
    view_label: "Filters"
    relationship: many_to_one
    sql_on: ${filters_search.feature_items_filtered} = ${facilities.facility_id} ;;
  }
  join: themes {
    view_label: "Filters"
    relationship: many_to_one
    sql_on: ${filters_search.theme_items_filtered} = ${themes.theme_id} ;;
  }
  join: sort_session {
    view_label: "Sort"
    relationship: many_to_one
    sql_on: ${search_flat.session_id} = ${sort_session.session_id} ;;
  }
  join: place {
    view_label: "Place Info"
    relationship: many_to_one
    sql_on: ${search_flat.place_id} = ${place.place_id} ;;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${search_flat.hotel_id} = ${hotel.hotel_id} ;;
  }
  join: cache_hit_ratio {
    view_label: "Cache Hit Ratio"
    relationship: one_to_one
    sql_on: ${search_flat.search_id} = ${cache_hit_ratio.search_id}
    and ${search_flat.date} = ${cache_hit_ratio.date};;
  }
  join: hotel_stats {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${search_flat.hotel_id} =  ${hotel_stats.hotel_id};;
  }
  join: place_stats {
    view_label: "Place Info"
    relationship: many_to_one
    sql_on: ${search_flat.place_id} =  ${place_stats.place_id};;
  }
}



explore: gha_audience {
  label: "GHA Audience"
  view_label: "GHA Audience"
  group_label: "Marketing Performance"

  # join: kostia_audiences {
  #   view_label: "Audiences mapping"
  #   relationship: many_to_one
  #   sql_on: ${gha_audience.audience_list_id} = ${kostia_audiences.audience_list_id} ;;
  # }
}

explore: gha_performance_nonzero_clicks {
  label: "GHA Performance (non-zero clicks) OLD"
  view_label: "GHA Performance (non-zero clicks) OLD"
  group_label: "Marketing Performance"
#   join: gha_hotel_group {
#     view_label: "Hotel Groups"
#     relationship: many_to_one
#     sql_on: ${gha_hotel_group.hotel_id} = ${gha_performance_nonzero_clicks.hotel_id} ;;
#   }
#   join: hotel {
#     view_label: "Hotel"
#     relationship: many_to_one
#     sql_on: ${gha_performance_nonzero_clicks.hotel_id} = ${hotel.hotel_id} ;;
#   }
#
#   join: all_provider_chains {
#     relationship: many_to_one
#     sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
#   }
#   join: place {
#     view_label: "Hotel Place"
#     relationship: many_to_one
#     sql_on: ${hotel.place_id} = ${place.place_id} ;;
#   }
#   join: gha_campaign {
#     view_label: "Campaign"
#     relationship: many_to_one
#     sql_on: ${gha_campaign.campaign_id} = ${gha_performance_nonzero_clicks.subaccount_id} ;;
#
#   }
#
#   join: hco_chain {
#     view_label: "HCO Chain Info"
#     relationship: many_to_one
#     sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
#   }
}

explore: gha_performance {
  label: "GHA Performance (impressions and cost only) OLD"
  view_label: "GHA Performance"
  group_label: "Marketing Performance"
  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${gha_performance.hotel_id} ;;
  }
  # join: gha_campaign {
  #   view_label: "Campaign"
  #   relationship: many_to_one
  #   sql_on: ${gha_campaign.campaign_id} = ${gha_performance.subaccount_id} ;;
  # }

}

explore: google_ads_hotel_ads_performance_nonzero_clicks {
  label: "Google Ads Hotel Ads Performance (non-zero clicks)"
  view_label: "Google Ads Hotel Ads Performance"
  group_label: "Marketing Performance"
  join: google_file_names {
    relationship: many_to_one
    sql_on: ${google_ads_hotel_ads_performance_nonzero_clicks.partner_hotel_id}=${google_file_names.hotel_id} ;;
  }
  join: gha_bidding_abtests {
    relationship: many_to_one
    sql_on: ${google_ads_hotel_ads_performance_nonzero_clicks.ad_group_id}=${gha_bidding_abtests.ad_group_id} and ${gha_bidding_abtests.hotel_id}=${google_ads_hotel_ads_performance_nonzero_clicks.partner_hotel_id}  ;;
  }
  join: gha_hotel_group {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${google_ads_hotel_ads_performance_nonzero_clicks.partner_hotel_id} ;;
    fields: [gha_hotel_group.hotel_group]
  }
  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${google_ads_hotel_ads_performance_nonzero_clicks.partner_hotel_id}=${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.nb_of_rooms_buckets,hotel.is_nmi,hotel.property_type,hotel.property_type_name,hotel.number_of_reviews,hotel.rating,hotel.theme_ids]
  }
  join: hotel_mapping {
    relationship: many_to_one
    view_label: "Hotel Mapping Info"
    sql_on: ${hotel_mapping.hotel_id}=${hotel.hotel_id} ;;
    }

  join: all_provider_chains {
    relationship: many_to_one
    view_label: "Hotel/Chain Info"
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
    fields: [all_provider_chains.AGD_chain_id,all_provider_chains.AGD_chain_name,all_provider_chains.BKS_chain_id,
      all_provider_chains.BKS_chain_name,all_provider_chains.EAN_chain_id,all_provider_chains.EAN_chain_name,
      all_provider_chains.PPN_chain_id,all_provider_chains.PPN_chain_name]
  }


  join: place_redirection {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${google_ads_hotel_ads_performance_nonzero_clicks.hotel_place_id}=${place_redirection.from_place_id};;
  }


  join: place {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${google_ads_hotel_ads_performance_nonzero_clicks.hotel_place_id}=${place.place_id};;
    fields: [place.rank,place.place_type_name,place.place_category_name,place.place_group_name]
  }

  join: hco_chain {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
    fields: [hco_chain.chain_name,hco_chain.chain_groups,hco_chain.chain_groups_grouped,hco_chain.parent_chain_id,hco_chain.parent_chain_name,hco_chain.trademarked]
  }
  join: geo_clustering_kostas {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${google_ads_hotel_ads_performance_nonzero_clicks.partner_hotel_id}=${geo_clustering_kostas.hotel_id} ;;
  }

  join: gha_effective_bids {
    view_label: "Effective Bids"
    relationship: one_to_one
    sql_on: ${gha_effective_bids.date_date}=${google_ads_hotel_ads_performance_nonzero_clicks.date_date}
          and ${gha_effective_bids.click_batch_id}=${google_ads_hotel_ads_performance_nonzero_clicks.click_batch_id};;
    fields: [gha_effective_bids.base_bid,gha_effective_bids.effective_bid,
              gha_effective_bids.base_bid_5_percentile,gha_effective_bids.base_bid_1_percentile,
              gha_effective_bids.effective_bid_5_percentile,gha_effective_bids.effective_bid_1_percentile]
  }


  #Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if google_ads_hotel_ads_performance_nonzero_clicks.current_date_range._is_filtered %}
  {% condition google_ads_hotel_ads_performance_nonzero_clicks.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if google_ads_hotel_ads_performance_nonzero_clicks.previous_date_range._is_filtered or google_ads_hotel_ads_performance_nonzero_clicks.compare_to._in_query %}
  {% if google_ads_hotel_ads_performance_nonzero_clicks.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif google_ads_hotel_ads_performance_nonzero_clicks.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif google_ads_hotel_ads_performance_nonzero_clicks.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;




}

explore: google_ads_hotel_ads_performance {
  label: "Google Ads Hotel Ads Performance (impressions and cost only)"
  view_label: "Google Ads Hotel Ads Performance"
  group_label: "Marketing Performance"

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${google_ads_hotel_ads_performance.hotel_chain_id} ;;
  }
}

explore: google_ads_session_flat {
  label: "Google Ads Session Flat"
  view_label: "Google Ads Session Flat"
  group_label: "Marketing Performance"
  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${google_ads_session_flat.landing_hotel_id} ;;
  }

  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${google_ads_session_flat.landing_hotel_id} = ${hotel.hotel_id} ;;
  }

  join: agd_hotels_rank {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${google_ads_session_flat.landing_hotel_id} = ${agd_hotels_rank.hotel_id} ;;
  }

  join: all_provider_chains {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
  }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }
  join: bd_provider_joins {
    view_label: "BD Provider Joins"
    relationship: many_to_one
    sql_on:  ${google_ads_session_flat.landing_hotel_id} = ${bd_provider_joins.hotel_id};;
  }


  #Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if google_ads_session_flat.current_date_range._is_filtered %}
  {% condition google_ads_session_flat.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if google_ads_session_flat.previous_date_range._is_filtered or google_ads_session_flat.compare_to._in_query %}
  {% if google_ads_session_flat.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif google_ads_session_flat.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif google_ads_session_flat.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;




}

explore: gha_session_flat {
  label: "GHA Session Flat"
  view_label: "GHA Session Flat"
  group_label: "Marketing Performance"
  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${gha_session_flat.landing_hotel_id} ;;
  }
  # join: net_rate_hotels {
  #   view_label: "Net Rate hotels"
  #   relationship: many_to_one
  #   sql_on: ${gha_session_flat.gha_hotel_id} = ${net_rate_hotels.hotel_id} AND ${gha_session_flat.date_utc_date} = ${net_rate_hotels.date_date} ;;
  # }
  # join: net_rate_tests {
  #   view_label: "Net Rate tests"
  #   relationship: many_to_one
  #   sql_on: (${gha_session_flat.gha_hotel_id} = ${net_rate_tests.hotel_id} AND
  #            ${gha_session_flat.date_utc_date} >= ${net_rate_tests.start_date_date} AND
  #            ${gha_session_flat.date_utc_date} <= ${net_rate_tests.end_date_date}) ;;
  # }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${gha_session_flat.landing_hotel_id} = ${hotel.hotel_id} ;;
  }

  join: all_provider_chains {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
  }

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }
}

explore: bing_keyword_performance_nonzero_clicks {
  label: "Bing Keyword Performance (non-zero clicks)"
  view_label: "Bing Keyword Performance (non-zero clicks)"
  group_label: "Marketing Performance"
  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${bing_keyword_performance_nonzero_clicks.hotel_id} ;;
  }

  join: bing_campaign_id_details_chain {
    view_label: "Campaign Details"
    relationship: many_to_one
    sql_on: ${bing_keyword_performance_nonzero_clicks.campaign_name}=${bing_campaign_id_details_chain.campaign_name} ;;
  }
  join: hotel {
    view_label: "Hotel Details"
    relationship: many_to_one
    sql_on: ${bing_keyword_performance_nonzero_clicks.hotel_id}=${hotel.hotel_id} ;;
  }

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }

  join: bing_sa360_bid_strategies {
    view_label: "SA 360 bid strategies"
    relationship: many_to_one
    sql_on:  ${bing_keyword_performance_nonzero_clicks.ad_group_id}=${bing_sa360_bid_strategies.ad_group_id} ;;
  }
  #Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if bing_keyword_performance_nonzero_clicks.current_date_range._is_filtered %}
  {% condition bing_keyword_performance_nonzero_clicks.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if bing_keyword_performance_nonzero_clicks.previous_date_range._is_filtered or bing_keyword_performance_nonzero_clicks.compare_to._in_query %}
  {% if bing_keyword_performance_nonzero_clicks.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif bing_keyword_performance_nonzero_clicks.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif bing_keyword_performance_nonzero_clicks.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;

}

explore: bing_keyword_performance {
  label: "Bing Keyword Performance (impressions and cost only)"
  view_label: "Bing Keyword Performance"
  group_label: "Marketing Performance"
}

explore: bing_keyword_session_flat {
  label: "Bing Keyword Session Flat"
  view_label: "Bing Keyword Session Flat"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${bing_keyword_session_flat.landing_hotel_id} = ${hotel.hotel_id} ;;
  }

  join: all_provider_chains {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
  }

  join: bing_adgroup_mapping {
    view_label: "Account Data"
    relationship: many_to_one
    sql_on: ${bing_keyword_session_flat.bing_keyword_ad_group_id} = ${bing_adgroup_mapping.ad_group_id} ;;
  }
  join: place {
    view_label: "Place Info"
    relationship: many_to_one
    sql_on: ${bing_keyword_session_flat.landing_place_id} = ${place.place_id} ;;
  }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }
}

explore: bha_hotel_performance {
  label: "BHA Hotel Performance (impressions and cost only)"
  view_label: "BHA Hotel Performance"
  group_label: "Marketing Performance"
}

explore: bha_hotel_performance_nonzero_clicks {
  label: "BHA Hotel Performance (non-zero clicks)"
  view_label: "BHA Hotel Performance (non-zero clicks)"
  group_label: "Marketing Performance"
  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${bha_hotel_performance_nonzero_clicks.partner_hotel_id} ;;
  }
  join: hotel {
    view_label: "Hotel"
    relationship: many_to_one
    sql_on: ${bha_hotel_performance_nonzero_clicks.partner_hotel_id} = ${hotel.hotel_id} ;;
  }

  join: all_provider_chains {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
  }
  join: place {
    view_label: "Hotel Place"
    relationship: many_to_one
    sql_on: ${hotel.place_id} = ${place.place_id} ;;
  }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }
}

explore: bha_hotel_session_flat {
  label: "BHA Hotel Session Flat"
  view_label: "BHA Hotel Session Flat"
  group_label: "Marketing Performance"
}


explore: adwords_ad_performance {
  label: "AdWords Ad Performance (impressions and cost only)"
  view_label: "AdWords Ad Performance"
  group_label: "Marketing Performance"
}

explore: adwords_ad_performance_nonzero_clicks {
  label: "AdWords Ad Performance (non-zero clicks)"
  view_label: "AdWords Ad Performance(non-zero clicks)"
  group_label: "Marketing Performance"

  join: gha_hotel_group {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${adwords_ad_performance_nonzero_clicks.hotel_id} ;;
    fields: [gha_hotel_group.hotel_group]
  }
  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${adwords_ad_performance_nonzero_clicks.hotel_id}=${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.nb_of_rooms_buckets,hotel.property_type,hotel.property_type_name,hotel.number_of_reviews,hotel.rating,hotel.theme_ids,hotel.chain_id]
  }

  join: all_provider_chains {
    relationship: many_to_one
    view_label: "Hotel/Chain Info"
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
    fields: [all_provider_chains.AGD_chain_id,all_provider_chains.AGD_chain_name,all_provider_chains.BKS_chain_id,
            all_provider_chains.BKS_chain_name,all_provider_chains.EAN_chain_id,all_provider_chains.EAN_chain_name,
            all_provider_chains.PPN_chain_id,all_provider_chains.PPN_chain_name]
  }

  join: adwords_campaign_id_details {
    view_label: "TCPA Details"
    relationship: many_to_one
    sql_on: ${adwords_ad_performance_nonzero_clicks.campaign_id}=${adwords_campaign_id_details.campaign_id} ;;
    fields: [adwords_campaign_id_details.campaign_type,adwords_campaign_id_details.language_group,adwords_campaign_id_details.match_type,
             adwords_campaign_id_details.traffic_scope]
  }


  join: tcpa_account_details {
    view_label: "TCPA Details"
    relationship: many_to_one
    sql_on: ${adwords_ad_performance_nonzero_clicks.account_name}=${tcpa_account_details.account} ;;
    fields: [tcpa_account_details.account_group,tcpa_account_details.bid_median,tcpa_account_details.current_median,
             tcpa_account_details.recent_update,tcpa_account_details.target_median,tcpa_account_details.campaign_type,
            tcpa_account_details.adgroup_count,tcpa_account_details.hotel_count]
  }

  join: place_redirection {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${adwords_ad_performance_nonzero_clicks.any_place_id}=${place_redirection.from_place_id};;
  }


  join: place {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${adwords_ad_performance_nonzero_clicks.any_place_id}=${place.place_id};;
    fields: [place.rank,place.place_type_name,place.place_category_name,place.place_group_name]
  }

  join: adwords_effective_bids {
    view_label: "TCPA Details"
    relationship: many_to_one
    sql_on: (${adwords_ad_performance_nonzero_clicks.ad_group_id}=${adwords_effective_bids.adgroup_id}
          and ${adwords_ad_performance_nonzero_clicks.device}=${adwords_effective_bids.device}
          and ${adwords_ad_performance_nonzero_clicks.date}=${adwords_effective_bids.date_date}) ;;
  }
  join: hco_chain {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
    fields: [hco_chain.chain_name,hco_chain.chain_groups,hco_chain.chain_groups_grouped,hco_chain.parent_chain_id,hco_chain.parent_chain_name,hco_chain.trademarked]
  }


  #Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if adwords_ad_performance_nonzero_clicks.current_date_range._is_filtered %}
  {% condition adwords_ad_performance_nonzero_clicks.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if adwords_ad_performance_nonzero_clicks.previous_date_range._is_filtered or adwords_ad_performance_nonzero_clicks.compare_to._in_query %}
  {% if adwords_ad_performance_nonzero_clicks.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif adwords_ad_performance_nonzero_clicks.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif adwords_ad_performance_nonzero_clicks.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;


}

explore: adwords_ad_session_flat {
  label: "AdWords Ad Session Flat"
  view_label: "AdWords Ad Session Flat"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${adwords_ad_session_flat.landing_hotel_id} = ${hotel.hotel_id} ;;
  }

  join: all_provider_chains {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
  }
  join: place {
    view_label: "Place Info"
    relationship: many_to_one
    sql_on: ${adwords_ad_session_flat.landing_place_id} = ${place.place_id} ;;
  }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }
  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${hotel.hotel_id} ;;
  }
  join: adwords_click_performance {
    view_label: "Click Performance Data"
    relationship: one_to_one
    sql_on: ${adwords_ad_session_flat.paid_click_id}=${adwords_click_performance.gcl_id} ;;
    fields: [adwords_click_performance.click_type,adwords_click_performance.ad_network_type2,adwords_click_performance.lop_city_criteria_id,
      adwords_click_performance.lop_country_criteria_id,adwords_click_performance.lop_metro_criteria_id,adwords_click_performance.lop_most_specific_target_id,
      adwords_click_performance.lop_region_criteria_id,adwords_click_performance.clicks]
  }
}

explore: adwords_click_performance {
  label: "AdWords Click Performance"
  view_label: "AdWords Click Performance"
  group_label: "Marketing Performance"
  join: session_flat {
    view_label: "Session Flat"
    relationship: one_to_many
    fields: [paid_click_id]
    sql_on: ${adwords_click_performance.gcl_id} = ${session_flat.paid_click_id} ;;
  }
}

explore: booking_history {
#  join: booking_flat {
#    relationship: one_to_one
#    sql_on: ${booking_flat.booking_id}=${booking_history.booking_id} ;;
#  }
}


explore: booking_time_machine {
  join: booking_flat {
    relationship: many_to_one
    sql_on: ${booking_time_machine.booking_id}=${booking_flat.booking_id} ;;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${booking_flat.hotel_id}=${hotel.hotel_id} ;;
  }
}





# explore: net_rate_priced {
#   label: "Net Rate Priced"
#   group_label: "Net Rates"
#   join: hotel {
#     view_label: "Hotel Info"
#     relationship: many_to_one
#     sql_on: ${net_rate_priced.hotel_id} = ${hotel.hotel_id} ;;
#   }
#   join: net_rate_tests {
#     view_label: "Net Rate Tests"
#     relationship: one_to_one
#     sql_on: (${net_rate_priced.hotel_id} = ${net_rate_tests.hotel_id} and
#              ${net_rate_priced.timestamp_date} >= ${net_rate_tests.start_date_date} and
#              ${net_rate_priced.timestamp_date} <= ${net_rate_tests.end_date_date});;
#   }
# }
#
# explore: net_rate_tests {
#   label: "Net Rate Tests"
#   group_label: "Net Rates"
# }
#
# explore: net_rate_performance {
#   label: "Net Rate Performance"
#   group_label: "Net Rates"
# }
#
# explore: net_rate_matching_reports {
#   label: "Net Rate Matching reports from OLO"
#   group_label: "Net Rates"
# }

explore: gha_scraper {
  label: "GHA Scraper"
  # group_label: "Net Rates"
}

explore: cancellation_model_metrics {
  label: "Cancellation model - Evaluation metrics"
  group_label: "Cancellation model"
  join: cancellation_model_metadata {
    view_label: "Cancellation model - Metadata"
    relationship: many_to_one
    sql_on: ${cancellation_model_metrics.model_uuid} = ${cancellation_model_metadata.model_uuid} and ${cancellation_model_metrics.model_trained_date_date} = ${cancellation_model_metadata.model_trained_date_date} ;;
  }
}

explore: cancellation_model_metrics_wide {
  label: "Cancellation model - Evaluation metrics (wide format)"
  group_label: "Cancellation model"
  join: cancellation_model_metadata {
    view_label: "Cancellation model - Metadata"
    relationship: many_to_one
    sql_on: ${cancellation_model_metrics_wide.model_uuid} = ${cancellation_model_metadata.model_uuid} and ${cancellation_model_metrics_wide.model_trained_date_date} = ${cancellation_model_metadata.model_trained_date_date} ;;
  }
}

explore: cancellation_model_metadata {
  label: "Cancellation model - Metadata"
  group_label: "Cancellation model"
}

explore: cancellation_model_calibration_curve {
  label: "Cancellation model - Calibration curve"
  group_label: "Cancellation model"
}

explore: cancellation_model_predictions {
  label: "Cancellation model - Predictions"
  group_label: "Cancellation model"
  join: booking_flat {
    view_label: "Booking Flat"
    relationship: many_to_one
    sql_on: ${booking_flat.booking_id} = ${cancellation_model_predictions.booking_id} ;;
  }
  join: cancellation_model_metadata {
    view_label: "Cancellation model - Metadata"
    relationship: many_to_one
    sql_on: ${cancellation_model_predictions.model_uuid} = ${cancellation_model_metadata.model_uuid} and ${cancellation_model_predictions.model_trained_date_date} = ${cancellation_model_metadata.model_trained_date_date} ;;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${booking_flat.hotel_id}=${hotel.hotel_id} ;;
  }
}

explore: gha_price_competitiveness {
  label: "GHA Price Competitiveness"
  group_label: "Marketing Performance"
  # join: net_rate_hotels {
  #   view_label: "Net Rate hotels"
  #   relationship: many_to_one
  #   sql_on: ${gha_price_competitiveness.hotel_id} = ${net_rate_hotels.hotel_id} AND ${gha_price_competitiveness.date_date} = ${net_rate_hotels.date_date} ;;
  # }
  # join: net_rate_tests {
  #   view_label: "Net Rate tests"
  #   relationship: many_to_one
  #   sql_on: (${gha_price_competitiveness.hotel_id} = ${net_rate_tests.hotel_id} AND
  #            ${gha_price_competitiveness.date_date} >= ${net_rate_tests.start_date_date} AND
  #            ${gha_price_competitiveness.date_date} <= ${net_rate_tests.end_date_date}) ;;
  # }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${gha_price_competitiveness.hotel_chain_id} ;;
  }
  join: place_redirection {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${gha_price_competitiveness.hotel_place_id}=${place_redirection.from_place_id} ;;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${gha_price_competitiveness.hotel_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.hotel_count,hotel.hotel_country_group]
  }

 join: geo_clustering_kostas {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${gha_price_competitiveness.hotel_id}=${geo_clustering_kostas.hotel_id} ;;
}
  sql_always_where:
  {% if gha_price_competitiveness.current_date_range._is_filtered %}
  {% condition gha_price_competitiveness.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if gha_price_competitiveness.previous_date_range._is_filtered or gha_price_competitiveness.compare_to._in_query %}
  {% if gha_price_competitiveness.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif gha_price_competitiveness.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif gha_price_competitiveness.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;


}

explore: etrip_price_competitiveness {
  group_label: "Marketing Performance"
  # join: net_rate_hotels {
  #   view_label: "Net Rate hotels"
  #   relationship: many_to_one
  #   sql_on: ${etrip_price_competitiveness.hotel_id} = ${net_rate_hotels.hotel_id} AND ${etrip_price_competitiveness.date_date} = ${net_rate_hotels.date_date} ;;
  # }
  # join: net_rate_tests {
  #   view_label: "Net Rate tests"
  #   relationship: many_to_one
  #   sql_on: (${etrip_price_competitiveness.hotel_id} = ${net_rate_tests.hotel_id} AND
  #            ${etrip_price_competitiveness.date_date} >= ${net_rate_tests.start_date_date} AND
  #            ${etrip_price_competitiveness.date_date} <= ${net_rate_tests.end_date_date}) ;;
  # }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${etrip_price_competitiveness.hotel_chain_id} ;;
  }
  join: place_redirection {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${etrip_price_competitiveness.hotel_place_id}=${place_redirection.from_place_id} ;;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${etrip_price_competitiveness.hotel_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.hotel_count,hotel.place_id,hotel.country]
  }

  join: geo_clustering_kostas {
    view_label: "Hotel/Chain Info (for hotel landing traffic)"
    relationship: many_to_one
    sql_on: ${etrip_price_competitiveness.hotel_id}=${geo_clustering_kostas.hotel_id} ;;
  }
  sql_always_where:
  {% if etrip_price_competitiveness.current_date_range._is_filtered %}
  {% condition etrip_price_competitiveness.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if etrip_price_competitiveness.previous_date_range._is_filtered or etrip_price_competitiveness.compare_to._in_query %}
  {% if etrip_price_competitiveness.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif etrip_price_competitiveness.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif etrip_price_competitiveness.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;


  }


explore: goseek_click_performance {
  label: "GoSeek Click Performance (impressions and cost only)"
  view_label: "GoSeek Click Performance"
  group_label: "Marketing Performance"
}

explore: hotel {
  join: all_provider_chains{
    relationship: one_to_one
    sql_on: ${hotel.hotel_id}=${all_provider_chains.hotel_id} ;;
  }
  join: google_file_names {
    relationship: one_to_one
    sql_on: ${google_file_names.hotel_id}=${hotel.hotel_id} ;;
  }
  join: hotel_mapping {
    relationship: one_to_one
    sql_on: ${hotel_mapping.hotel_id}=${hotel.hotel_id} ;;
  }
  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
  }
}




explore: clicktripz_performance_nonzero_clicks {
  label: "Clicktripz Performance (non-zero clicks)"
  view_label: "Clicktripz Performance (non-zero clicks)"
  group_label: "Marketing Performance"
}

explore: mediaalpha_conversion_tracking {
  label: "MediaAlpha Conversion Tracking"
  view_label: "MediaAlpha Conversion Tracking"
  group_label: "Marketing Performance"
}



explore: cancellation_prediction {
  label: "Booking Cancellation Predictions"
  view_label: "Booking Cancellation Predictions"
  group_label: "Cancellation model"
  join: booking_flat {
    view_label: "Booking Flat"
    relationship: one_to_one
    sql_on: ${booking_flat.booking_id} = ${cancellation_prediction.booking_id} ;;
  }
  join: cancellation_model_metadata {
    view_label: "Cancellation model - Metadata"
    relationship: one_to_one
    sql_on: ${cancellation_prediction.model_uuid} = ${cancellation_model_metadata.model_uuid} and ${cancellation_prediction.model_trained_date} = ${cancellation_model_metadata.model_trained_date_date} ;;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${booking_flat.hotel_id}=${hotel.hotel_id} ;;
  }
}

explore: checkout_nps_survey_results {
  group_label: "Checkout"
  label: "Checkout NPS Survey Results"
  join: experiment {
    view_label: "Experiment"
    relationship: many_to_one
    sql_on: ${checkout_nps_survey_results.anonymous_id} = ${experiment.anonymous_id}
      and ${checkout_nps_survey_results.date} = ${experiment.date};;
  }
  join: checkout_bofh_emails {
    view_label: "emails"
    relationship: one_to_many
    sql_on: ${checkout_nps_survey_results.anonymous_id}=${checkout_bofh_emails.anonymous_id} ;;
  }
}

explore: checkout_nps_survey_responders {
  group_label: "Checkout"
  label: "Checkout NPS Survey Responders"
}

explore: checkout_bofh_emails {
  fields: [
    ALL_FIELDS*,
    -booking_flat.local_vs_international
  ]
  group_label: "Checkout"
  label: "Checkout BOFH emails"
  join: booking_flat {
    view_label: "Booking Flat"
    relationship: one_to_many
    sql_on: ${checkout_bofh_emails.anonymous_id}=${booking_flat.anonymous_id} ;;
  }
  join: checkout_nps_survey_results {
    view_label: "Checkout NPS Survey Results"
    relationship: one_to_many
    sql_on:${checkout_nps_survey_results.anonymous_id}=${checkout_bofh_emails.anonymous_id} ;;
  }
}

explore: tripadvisor_cost_revenue {
  label: "TripAdvisor Cost and Revenue [Deprecated]"
  view_label: "TripAdvisor Cost and Revenue [Deprecated]"
  group_label: "Marketing Performance"
}

explore: tripadvisor_click_performance_nonzero_clicks {
  label: "TripAdvisor Click Performance (nonzero clicks)"
  view_label: "TripAdvisor Click Performance (nonzero clicks)"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${tripadvisor_click_performance_nonzero_clicks.partner_property_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.hotel_count, hotel.country]
  }

  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${tripadvisor_click_performance_nonzero_clicks.partner_property_id} ;;
  }

  join: gar_hotel_categories {
    view_label: " GAR Hotel Categories"
    relationship: many_to_one
    sql_on: ${tripadvisor_click_performance_nonzero_clicks.partner_property_id} = ${gar_hotel_categories.hotel_id} ;;

  }

  join: is_new_inventory_tripadvisor {
    view_label: " Is New Inventory"
    relationship: many_to_one
    sql_on: ${tripadvisor_click_performance_nonzero_clicks.partner_property_id} = ${is_new_inventory_tripadvisor.hotel_id} ;;

  }

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }


}

explore: tripadvisor_session_flat {
  label: "TripAdvisor Session Flat"
  view_label: "TripAdvisor Session Flat"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${tripadvisor_session_flat.partner_property_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.hotel_count]
  }

  join: gha_hotel_group {
    view_label: "Hotel Groups"
    relationship: many_to_one
    sql_on: ${gha_hotel_group.hotel_id} = ${tripadvisor_session_flat.partner_property_id} ;;
  }

  join: gar_hotel_categories {
    view_label: " GAR Hotel Categories"
    relationship: many_to_one
    sql_on: ${tripadvisor_session_flat.partner_property_id} = ${gar_hotel_categories.hotel_id} ;;

  }

  join: ppn_sensitive_hotels {
    view_label: " PPN Sensitive Hotels"
    relationship: many_to_one
    sql_on: ${tripadvisor_session_flat.partner_property_id} = ${ppn_sensitive_hotels.hotel_id} ;;

  }

  join: is_new_inventory_tripadvisor {
    view_label: " Is New Inventory"
    relationship: many_to_one
    sql_on: ${tripadvisor_session_flat.partner_property_id} = ${is_new_inventory_tripadvisor.hotel_id} ;;

  }

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hotel.chain_id} = ${hco_chain.chain_id} ;;
  }


}

explore: session_flat_next {
  group_label: "Next"
  label: "Session Flat Next"
  view_label: "Session Flat Next"
  always_filter: {
    filters: {
      field: session_flat_next.date_filter
      value: "7 days"
    }
  }
  join: session_flat_prod {
    view_label: "Session Flat Prod"
    relationship: many_to_many
    type: full_outer
    sql_on: ${session_flat_next.date} = ${session_flat_prod.date} and ${session_flat_next.anonymous_id} = ${session_flat_prod.anonymous_id};;
  }
}

explore: booking_analytics {
  label: "Booking Analytics"
  view_label: "Booking Analytics"
  group_label: "New Core Models"
  join: booking_flat {
    view_label: "Booking Flat"
    relationship: one_to_one
    type: full_outer
    sql_on: ${booking_analytics.booking_id} = ${booking_flat.booking_id}
        and ${booking_analytics.provider_code} = ${booking_flat.provider_code}
        and ${booking_analytics.final_provider_code} = ${booking_flat.final_provider_code};;
  }
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${booking_flat.hotel_id} = ${hotel.hotel_id} ;;
  }
  join: booked_room {
    view_label: "Booked Room"
    relationship: one_to_many
    sql_on: ${booking_analytics.booking_id} = ${booked_room.booking_id}
        and ${booking_analytics.provider_code} = ${booked_room.provider_code}
        and ${booking_analytics.final_provider_code} = ${booked_room.final_provider_code};;
  }
  join: provider_commission_rates {
    view_label: "Provider Commission Rates"
    relationship: many_to_one
    sql_on:  ${booking_analytics.provider_code} = ${provider_commission_rates.provider_code}
        and ${booking_analytics.final_provider_code} = ${provider_commission_rates.final_provider_code}
        and ${booking_analytics.rate_key} = ${provider_commission_rates.rate_key};;
  }
  join: intent_to_cancel {
    view_label: "Intent to Cancel"
    relationship: one_to_one
    sql_on: ${booking_analytics.booking_id} = ${intent_to_cancel.booking_id}
        and ${booking_analytics.provider_code} = ${intent_to_cancel.provider_code}
        and ${booking_analytics.final_provider_code} = ${intent_to_cancel.final_provider_code};;
  }
  join: intent_to_cancel_history {
    view_label: "Intent to Cancel History"
    relationship: one_to_many
    sql_on: ${intent_to_cancel.booking_id} = ${intent_to_cancel_history.booking_id}
        and ${intent_to_cancel.provider_code} = ${intent_to_cancel_history.provider_code}
        and ${intent_to_cancel.final_provider_code} = ${intent_to_cancel_history.final_provider_code};;
  }
  join: manual_commission_adjusters {
    view_label: "Manual Commission Adjusters"
    relationship: many_to_one
    sql_on: ${booking_analytics.provider_code} = ${manual_commission_adjusters.provider_code}
        and (${booking_analytics.final_provider_code} = ${manual_commission_adjusters.final_provider_code}
          or ${manual_commission_adjusters.final_provider_code} = 'all')
        and (${booking_analytics.date_month} = ${manual_commission_adjusters.booking_month_month}
          or ${manual_commission_adjusters.booking_month_month} IS NULL)
        and (${booking_analytics.check_out_month} = ${manual_commission_adjusters.check_out_month_month}
          or ${manual_commission_adjusters.check_out_month_month} IS NULL)
        and (${booking_flat.session_device_type} = ${manual_commission_adjusters.device_type}
          or ${manual_commission_adjusters.device_type} = 'all');;
  }
  join: commission_fallback_from_gbv {
    view_label: "Commission Fallback from GBV"
    relationship: many_to_one
    sql_on: ${booking_analytics.provider_code} = ${commission_fallback_from_gbv.provider_code}
        and ${booking_analytics.final_provider_code} = ${commission_fallback_from_gbv.final_provider_code}
        and ${booking_analytics.date_date}
          between ${commission_fallback_from_gbv.start_date_date} and ${commission_fallback_from_gbv.end_date_date};;
  }
}

#explore: booked_room {
#  label: "Booked Room"
#  view_label: "Booked Room"
#  group_label: "New Core Models"
#  join: booking_analytics {
#    view_label: "New Booking Model"
#    relationship: many_to_one
#    sql_on:  ${booked_room.booking_id} = ${booking_analytics.booking_id}
#        and ${booked_room.provider_code} = ${booking_analytics.provider_code}
#        and ${booked_room.final_provider_code} = ${booking_analytics.final_provider_code};;
#  }
#}

explore: provider_commission_rates {
  label: "Provider Commission Rates"
  view_label: "Provider Commission Rates"
  group_label: "New Core Models"
}

explore: gha_experiments_guru {}

explore: adwords_experiments_guru {}

explore: all_channel_financials {
#Below part is for timeline comparison, please don't touch
  sql_always_where:
  {% if all_channel_financials.current_date_range._is_filtered %}
  {% condition all_channel_financials.current_date_range %} TO_TIMESTAMP(${dates_date}) {% endcondition %}

  {% if all_channel_financials.previous_date_range._is_filtered or all_channel_financials.compare_to._in_query %}
  {% if all_channel_financials.comparison_periods._parameter_value == '2' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}

  {% elsif all_channel_financials.comparison_periods._parameter_value == '3' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}


  {% elsif all_channel_financials.comparison_periods._parameter_value == '4' %}
  or
  ${dates_date} between ${period_2_start} and ${period_2_end}
  or
  ${dates_date} between ${period_3_start} and ${period_3_end}
  or
  ${dates_date} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;
}


explore: bha_share_of_voice {
  label: "BHA Share of Voice Report"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${bha_share_of_voice.hotel_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.hotel_count]
  }

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
  }
  }

explore: tripadvisor_price_competitiveness {
  label: "TripAdvisor price competitiveness reports"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${tripadvisor_price_competitiveness.partner_property_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.hotel_count]
  }

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
  }


}

explore: tripadvisor_mbl_mismatch_report {
  label: "TripAdvisor MBL mismatch reports"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${tripadvisor_mbl_mismatch_report.external_id} = ${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.chain_id,hotel.chain_name,hotel.facility_ids,hotel.guest_sentiment_ids,hotel.guest_type,hotel.last_booked_date,
      hotel.name, hotel.nb_of_rooms_buckets,hotel.number_of_reviews,hotel.place_id,hotel.property_type,hotel.property_type_name,hotel.rating, hotel.theme_ids,
      hotel.wk_place_id,hotel.wk_place_name,hotel.hotel_count]
  }

  join: hco_chain {
    view_label: "HCO Chain Info"
    relationship: many_to_one
    sql_on: ${hco_chain.chain_id} = ${hotel.chain_id} ;;
  }


}

explore: gha_bids_validation {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${gha_bids_validation.hotel_id} ;;
  }
}
explore: gha_multiplier_validation {}

explore: gha_bid_effect_delta {}

explore: gha_campaign_multiplier_validation {}


explore: adwords_bid_validation {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${adwords_bid_validation.hotel_id} ;;
  }
}

explore: temporary_impressions_guru {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${temporary_impressions_guru.hotel_id} ;;
  }

}

explore: price_competitiveness {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${price_competitiveness.hotel_id} ;;
  }
}


explore: price_competitiveness_hotel_level {
  join: hotel {
    relationship: one_to_one
    sql_on: ${hotel.hotel_id}=${price_competitiveness_hotel_level.hotel_id} ;;
}

}

explore: tripadvisor_change_report {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${tripadvisor_change_report.hotel_id} ;;
  }

}

explore: tripadvisor_bid_history {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${tripadvisor_bid_history.hotel_id} ;;
  }
}


explore: trivago_performance_nonzero_clicks {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${trivago_performance_nonzero_clicks.hotel_id} ;;
  }
}


 explore: user_flow {
  group_label: "Product Performance"
}


explore: adwords_user_location_nonzero {
  label: "AdWords User Location (non-zero clicks)"
  view_label: "AdWords User Location (non-zero clicks)"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${adwords_user_location_nonzero.hotel_id}=${hotel.hotel_id} ;;
    fields: [hotel.preferred, hotel.nb_of_rooms_buckets,hotel.property_type,hotel.property_type_name,hotel.number_of_reviews,hotel.rating,hotel.theme_ids,hotel.chain_id,hotel.name,hotel.place_id,hotel.country,hotel.wk_place_id,hotel.wk_place_name]
  }
  join: place {
    view_label: "Place Info"
    relationship: many_to_one
    sql_on: ${adwords_user_location_nonzero.place_id}=${place.place_id};;
    fields: [place.rank,place.place_type_name,place.place_category_name,place.place_group_name,place.name,place.country_code]
  }
}

explore: kayak_session_flat {
  label: "Kayak Session Flat"
  view_label: "Kayak Session Flat"
  group_label: "Analytics"

  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${kayak_session_flat.landing_hotel_id}=${hotel.hotel_id} ;;
    fields: [hotel.chain_id, hotel.name, hotel.place_id, hotel.country, hotel.wk_place_id, hotel.wk_place_name]
  }
}

explore: kayak_bob_report {
  label: "Kayak Bob Report"
  view_label: "Kayak Bob Report"
  group_label: "Analytics"

  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${kayak_bob_report.hotel_id}=${hotel.hotel_id} ;;
    fields: [hotel.chain_id, hotel.name, hotel.place_id, hotel.country, hotel.wk_place_id, hotel.wk_place_name]
  }
}

explore: kayak_experiments_performance {
  label: "Kayak Experiments"
  view_label: "Kayak Experiments"
  group_label: "Analytics"
}

explore: experiments_variance_estimator_look_up {
  label: "Experiments Variance Estimator Look Up"
  view_label: "Experiments Variance Estimator Look Up"
  group_label: "Analytics"
}

explore: adwords_campaign_audience_nonzero {
  label: "AdWords Campaign Audience (non-zero clicks)"
  view_label: "AdWords Campaign Audience (non-zero clicks)"
  group_label: "Marketing Performance"
  }

explore: gha_ad_group_experiments_performance {
  label: "GHA Ad Group Experiments"
  view_label: "GHA Ad Group Experiment"
  group_label: "Marketing Performance"
}

explore: tripadvisor_experiments_performance {
  label: "TripAdvisor Experiment"
  view_label: "TripAdvisor Experiment"
  group_label: "Marketing Performance"

}

explore: hotel_impressions {
  view_label: "GHA Total Hotel Impressions"
  group_label: "Marketing Performance"

  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${hotel_impressions.hotel_id}=${hotel.hotel_id} ;;
  }
}

explore: geo_bid_validation {}

explore: dsa_bid_validation {}

explore: bing_bid_validation {}

explore: bing_bid_multipliers_validation {}

explore: trivago_bid_modifiers_validation {}

explore: trivago_bid_validation {}

explore: bha_bid_multipliers_validation {}

explore: bha_bid_validation {}

explore: bing_geo_bid_multipliers_validation {}

explore: bing_geo_bid_validation {}

explore: kayak_multipliers_validation {}

explore: kayak_bid_validation {

  join: hotel {
    view_label: "Hotel/Chain Info"
    relationship: many_to_one
    sql_on: ${kayak_bid_validation.hotel_id}=${hotel.hotel_id} ;;
    fields: [hotel.chain_id, hotel.name, hotel.place_id, hotel.country, hotel.wk_place_id, hotel.wk_place_name]
  }
}

explore: events_rabbit {
  join: experiment {
    view_label: "Experiment details"
    relationship: many_to_many
    sql_on: ${events_rabbit.anonymous_id} = ${experiment.anonymous_id} ;;
  }
}

explore: price_save_metric {
  label: "Price save analytics"
  group_label: "Search analytics"
  # always_filter: {
  #   filters: {
  #     field: price_save_metric.date_filter
  #     value: "7 days"
  #   }}
  join: hotel {
    view_label: "Hotel Info"
    relationship: many_to_one
    sql_on: ${price_save_metric.hotel_id} = ${hotel.hotel_id} ;;
  }
}

explore: search_fact{
  label: "Search fact"
  group_label: "Search analytics"
  join: experiment {
    relationship: many_to_many
    sql_on: ${search_fact.anonymous_id}=${experiment.anonymous_id} and ${search_fact.search_date}=${experiment.date} ;;

  }
}

explore: search_flattened_events {
  label: "Search events"
  group_label: "Search analytics"
  join: experiment {
    view_label: "Experiment details"
    relationship: many_to_many
    sql_on: ${search_flattened_events.anonymous_id} = ${experiment.anonymous_id} ;;
  }
  join: search_product_interaction {
    view_label: "Product interaction metrics of visitors"
    relationship: many_to_one
    sql_on: ${search_flattened_events.anonymous_id}=${search_product_interaction.anonymous_id} and ${search_flattened_events.event_date}=${search_product_interaction.date} ;;
  }
  join: events_sessions_mapping {
    view_label: "Session attributes"
    relationship: one_to_one
    type: inner
    fields: []
    sql_on: ${search_flattened_events.message_id}=${events_sessions_mapping.message_id} ;;
  }
  join: anonymous_session_derived {
    view_label: "Session attributes"
    relationship: one_to_one
    fields: [anonymous_session_derived.landing_page_type, anonymous_session_derived.landing_page_type_grouped]
    sql_on: ${events_sessions_mapping.session_id}=${anonymous_session_derived.id} ;;
  }
  always_filter: { filters:[is_bot: "no"]}
}


explore: tripadvisor_index_click_share_report {
  label: "TripAdvisor Index-Click Share Report"
  view_label: "TripAdvisor Index-Click Share Report"
  group_label: "Marketing Performance"

}

explore: tripadvisor_real_click_share_report {
  label: "TripAdvisor Real-Click Share Report"
  view_label: "TripAdvisor Real-Click Share Report"
  group_label: "Marketing Performance"

}



explore: tripadvisor_sp_session_flat {
  label: "TripAdvisor SP Session Flat"
  view_label: "TripAdvisor SP Session Flat"
  group_label: "Marketing Performance"
}

explore: tripadvisor_sp_funnel {
  label: "TripAdvisor SP Funnel Report"
  view_label: "TripAdvisor SP Funnel Report"
  group_label: "Marketing Performance"
}

explore: tripadvisor_sp_price_competitiveness {
  label: "TripAdvisor SP Price Competitiveness"
  view_label: "TripAdvisor SP Price Competitiveness"
  group_label: "Marketing Performance"
}

explore: tripadvisor_sp_bid_history {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${tripadvisor_sp_bid_history.hotel_id} ;;
  }
}

explore: tripadvisor_sp_change_report {
  join: hotel {
    relationship: many_to_one
    sql_on: ${hotel.hotel_id}=${tripadvisor_sp_change_report.hotel_id} ;;
  }}

explore: gasf_experiments_performance {
  label: "GHA experiments"
  view_label: "GHA experiments"
  group_label: "Marketing Performance"
    }


explore: ca_experiments_agg {}