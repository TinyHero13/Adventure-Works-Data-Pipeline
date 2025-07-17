with sales_territory as (
    select
        cast(territoryid as int) as territory_pk
        , name as territory_name
        , countryregioncode as country_region_code
        , group
        , salesytd as sales_ytd
        , saleslastyear as sales_last_year
        , costytd as cost_ytd
        , costlastyear as cost_last_year
        , current_timestamp() as updated_at
    from {{ source('source_db', 'sales_territory') }}
)

select * 
from sales_territory