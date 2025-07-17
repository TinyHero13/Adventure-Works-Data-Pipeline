with 
    sales_persons as (
        select 
            business_entity_id,
            territory_id,
            sales_quota,
            bonus,
            commission_pct,
            sales_ytd,
            sales_last_year
        from {{ ref('stg_db__sales_person') }}
    )

    , persons as (
        select 
            business_entity_id,
            person_type,
            full_name
        from {{ ref('stg_db__person') }}
    )

    , sales_persons_with_names as (
        select
            sales_persons.business_entity_id as sales_person_id
            , sales_persons.sales_quota
            , sales_persons.bonus
            , sales_persons.commission_pct
            , sales_persons.sales_ytd
            , sales_persons.sales_last_year
            , persons.full_name as sales_person_name
            , persons.person_type
        from sales_persons
        left join persons
            on sales_persons.business_entity_id = persons.business_entity_id
    )

    , final as (
        select
            sales_person_id
            , sales_person_name
            , sales_quota
            , bonus
            , commission_pct
            , sales_ytd
            , sales_last_year
            , case 
                when sales_quota > 0 and sales_ytd is not null
                then (sales_ytd / sales_quota) * 100
                else null
            end as quota_achievement_pct
            , case 
                when sales_last_year > 0 and sales_ytd is not null
                then ((sales_ytd - sales_last_year) / sales_last_year) * 100
                else null
            end as sales_growth_pct
        from sales_persons_with_names
    )

select * 
from final