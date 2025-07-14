with 
    customers as (
        select 
            customer_id
            , person_id
    from {{ ref('stg_db__customer') }}
    )

    , persons as (
        select 
            business_entity_id
            , full_name
            , person_type
        from {{ ref('stg_db__person') }}
    )

    ,final as (
        select
            customers.customer_id as id_cliente
            , persons.full_name
            , persons.person_type
        from customers
        left join persons
            on customers.customer_id = persons.business_entity_id
)

select *
from final