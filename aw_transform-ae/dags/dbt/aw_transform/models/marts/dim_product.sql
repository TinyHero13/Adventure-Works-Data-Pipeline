with 
    dim_products as (
        select * 
        from {{ ref('int_sales_product') }}
    )

select *
from dim_products