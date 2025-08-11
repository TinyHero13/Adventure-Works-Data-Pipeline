with
    customers as (
        select
            person_id
            , customer_id
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

    , sales_orders_db as (
        select 
            customer_id
            , order_date
        from {{ ref('stg_db__sales_order_header') }}
    )

    , sales_orders_api as (
        select 
            customer_id
            , order_date
        from {{ ref('stg_api__sales_order_header') }}
    )

    , unified_sales_orders as (
        select customer_id, order_date from sales_orders_db
        union distinct
        select customer_id, order_date from sales_orders_api
    )

    , customer_last_orders as (
        select 
            customer_id
            , max(order_date) as last_order_date
            , max(max(order_date)) over () as dataset_max_date
        from unified_sales_orders
        group by customer_id
    )

    , customer_status_calc as (
        select 
            customer_id
            , last_order_date
            , dataset_max_date
            , datediff(dataset_max_date, last_order_date) as days_since_last_order
            , case 
                when datediff(dataset_max_date, last_order_date) <= 90 
                    then 'Active (3 months)'
                when datediff(dataset_max_date, last_order_date) <= 180 
                    then 'At risk (3-6 months)'
                when datediff(dataset_max_date, last_order_date) <= 365 
                    then 'Inactive (6-12 months)'
                else 'Churned (more than 1 year)'
            end as customer_status
        from customer_last_orders
    )

    , final as (
        select
            customers.person_id
            , customers.customer_id
            , persons.full_name
            , coalesce(customer_status_calc.customer_status, 'No purchases') as customer_status
            , customer_status_calc.last_order_date
            , customer_status_calc.days_since_last_order
            , current_timestamp() as updated_at
        from customers
        left join persons
            on customers.person_id = persons.business_entity_id
        left join customer_status_calc
            on customers.customer_id = customer_status_calc.customer_id
    )

select *
from final