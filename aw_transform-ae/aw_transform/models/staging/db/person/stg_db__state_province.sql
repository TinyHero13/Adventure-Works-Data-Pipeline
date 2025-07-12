with state_province as (
    select
        cast(stateprovinceid as int) as state_province_id
        , countryregioncode as country_region_code
        , name
        , cast(territoryid as int) as territory_id
    from {{ source('source_db', 'state_province') }}
)

select *
from state_province