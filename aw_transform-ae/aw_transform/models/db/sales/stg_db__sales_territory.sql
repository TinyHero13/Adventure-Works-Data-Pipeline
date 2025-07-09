with sales_territory as (
    select
        cast(territoryid as int) as territory_id
        , name
        , countryregioncode as country_region_code
        , salesytd as sales_ytd
        , saleslastyear as sales_last_year
        , costytd as cost_ytd
        , costlastyear as cost_last_year
        , rowguid as row_guid
        , to_date(modifieddate, 'MM/DD/YYYY') as modified_date
    from {{ source('source_db', 'sales_territory') }}
)

select * 
from sales_territory