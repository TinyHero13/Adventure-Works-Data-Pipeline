with
    customer as (
        select
            cast(personid as int) as person_id
            , cast(customerid as int) as customer_id
            , cast(storeid as int) as store_id
            , cast(territoryid as int) as territory_id
            , accountnumber as account_number
            , current_timestamp() as updated_at
        from {{ source('source_db', 'customer') }}
    )

select *
from customer
