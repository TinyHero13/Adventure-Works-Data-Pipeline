with 
    dim_territory as (
        select 
            territory_pk
            , territory_name
            , country_region_code
            , group
            , sales_ytd
            , sales_last_year
            , cost_ytd
            , cost_last_year
            , current_timestamp() as updated_at
        from {{ ref('stg_db__sales_territory') }}
    )

select *
from dim_territory