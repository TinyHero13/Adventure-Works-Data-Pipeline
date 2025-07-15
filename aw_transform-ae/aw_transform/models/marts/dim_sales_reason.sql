with 
    dim_sales_reason as (
        select * 
        from {{ ref('stg_db__sales_reason') }}
    )

select *
from dim_sales_reason
