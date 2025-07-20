with customer as (
    select
        cast(customerid as int) as customer_pk
        , cast(personid as int) as person_fk
        , cast(storeid as int) as store_fk
        , cast(territoryid as int) as territory_fk
        , accountnumber as account_number
        , current_timestamp() as updated_at
    from {{ source('source_db', 'customer') }}
)

select *
from customer