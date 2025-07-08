with customer as (
    select
        cast(customerid as int) as customer_id
        , cast(personid as int) as person_id
        , cast(storeid as int) as store_id
        , cast(territoryid as int) as territory_id
        , accountnumber as account_number
        , rowguid as row_guid
        , to_date(modifieddate, 'MM/DD/YYYY') as modified_date
    from {{ source('source_db', 'customer') }}
)

select *
from customer