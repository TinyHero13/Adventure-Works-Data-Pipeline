with 
    dim_customers as (
        select * 
        from {{ ref('int_sales_customer_persons') }}
    )

select *
from dim_customers