with 
    dim_sales_person as (
        select 
            sales_person_pk as sales_person_id
            , sales_person_name
            , sales_quota
            , bonus
            , commission_pct
            , sales_ytd
            , sales_last_year
            , quota_achievement_pct
            , sales_growth_pct
            , current_timestamp() as updated_at
        from {{ ref('int_sales_sales_person_person') }}
    )

select *
from dim_sales_person