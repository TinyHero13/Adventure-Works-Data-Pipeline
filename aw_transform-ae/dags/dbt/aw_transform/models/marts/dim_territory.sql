with
    dim_territory as (
        select
            territory_id as territory_pk
            , territory_name
            , country_region_code
            , group_name
            , sales_ytd
            , sales_last_year
            , cost_ytd
            , cost_last_year
            , country_region_name
            , current_timestamp() as updated_at
        from {{ ref('stg_db__sales_territory') }}
    )

select *
from dim_territory
