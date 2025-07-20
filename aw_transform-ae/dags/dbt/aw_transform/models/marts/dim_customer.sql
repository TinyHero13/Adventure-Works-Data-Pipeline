with 
    dim_customers as (
        select 
            customer_pk
            , full_name
            , current_timestamp() as updated_at
        from {{ ref('int_sales_customer_persons') }}
    )

select *
from dim_customers