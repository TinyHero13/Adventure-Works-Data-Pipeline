with
    sales_person as (
        select
            cast(businessentityid as int) as business_entity_id
            , cast(territoryid as int) as territory_id
            , cast(salesquota as numeric(19, 4)) as sales_quota
            , cast(bonus as numeric(19, 4)) as bonus
            , cast(commissionpct as numeric(19, 4)) as commission_pct
            , cast(salesytd as numeric(19, 4)) as sales_ytd
            , cast(saleslastyear as numeric(19, 4)) as sales_last_year
            , current_timestamp() as updated_at
        from {{ source('source_db', 'sales_person') }}
    )

select *
from sales_person
