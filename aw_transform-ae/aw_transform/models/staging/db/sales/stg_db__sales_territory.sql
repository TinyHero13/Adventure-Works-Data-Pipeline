with sales_territory as (
    select
        cast(territoryid as int) as territory_id
        , name as territory_name
        , countryregioncode as country_region_code
        , salesytd as sales_ytd
        , saleslastyear as sales_last_year
    from {{ source('source_db', 'sales_territory') }}
)

select * 
from sales_territory