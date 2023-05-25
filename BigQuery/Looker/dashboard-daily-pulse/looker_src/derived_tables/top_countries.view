# If necessary, uncomment the line below to include explore_source.
# include: "gaming.model.lkml"

view: top_countries {
  view_label: "Events"
  derived_table: {
    explore_source: events {
      column: country {}
      column: total_revenue {}
      bind_all_filters: yes
      derived_column: country_rank {
        sql:  RANK() OVER (ORDER BY total_revenue desc)  ;;
      }
    }
  }
  dimension: country {hidden:yes}
  dimension: total_revenue { type: number hidden:yes }
  dimension: country_rank {
    group_label: "Location"
    description: "(Based on Revenue, respects all applied filters)"
    type:number}

  dimension: is_top_10_country {
    group_label: "Location"
    description: "(Based on Revenue, respects all applied filters)"
    type: yesno
    sql: ${country_rank} <= 10 ;;
  }
}
