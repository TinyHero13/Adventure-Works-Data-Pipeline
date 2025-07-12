with address as (
    select
        cast(addressid as int) as address_id
        , city as city
        , cast(stateprovinceid as int) as state_province_id
    from {{ source('source_db', 'address') }}
)

select *
from address