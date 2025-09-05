with
    sales_territory as (
        select
            cast(territoryid as int) as territory_id
            , name as territory_name
            , countryregioncode as country_region_code
            , `group` as group_name
            , salesytd as sales_ytd
            , saleslastyear as sales_last_year
            , costytd as cost_ytd
            , costlastyear as cost_last_year
            , case
                when countryregioncode = 'US' then 'United States'
                when countryregioncode = 'CA' then 'Canada'
                when countryregioncode = 'FR' then 'France'
                when countryregioncode = 'DE' then 'Germany'
                when countryregioncode = 'GB' then 'United Kingdom'
                when countryregioncode = 'AU' then 'Australia'
                else countryregioncode
            end as country_region_name
            , current_timestamp() as updated_at
        from {{ source('source_db', 'sales_territory') }}
    )

select *
from sales_territory
