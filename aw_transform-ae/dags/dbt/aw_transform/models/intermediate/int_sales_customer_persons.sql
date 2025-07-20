with 
    customers as (
        select 
            customer_pk
            , person_fk
    from {{ ref('stg_db__customer') }}
    )

    , persons as (
        select 
            business_entity_pk
            , full_name
            , person_type
        from {{ ref('stg_db__person') }}
    )

    ,final as (
        select
            customers.customer_pk
            , persons.full_name
            , current_timestamp() as updated_at
        from customers
        left join persons
            on customers.person_fk = persons.business_entity_pk
        where persons.person_type = 'Individual (retail) customer'
)

select *
from final