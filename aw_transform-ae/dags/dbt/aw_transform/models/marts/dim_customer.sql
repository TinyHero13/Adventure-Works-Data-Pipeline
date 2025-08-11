with
    dim_customers as (
        select
            person_id as person_pk
            , customer_id as customer_fk
            , full_name
            , customer_status
            , last_order_date
            , days_since_last_order
            , current_timestamp() as updated_at
        from {{ ref('int_sales_customer_persons') }}
    )

select *
from dim_customers
