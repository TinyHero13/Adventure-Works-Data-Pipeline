with 
    dim_customers as (
        select 
            id_cliente as customer_id
            , full_name
        from {{ ref('int_sales_customer_persons') }}
    )

select *
from dim_customers