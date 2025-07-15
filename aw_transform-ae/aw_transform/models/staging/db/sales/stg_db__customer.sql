with customer as (
    select
        cast(customerid as int) as customer_id
        , cast(personid as int) as person_id
    from {{ source('source_db', 'customer') }}
)

select *
from customer