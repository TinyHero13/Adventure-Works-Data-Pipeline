with 
    sales_monthly_agg as (
        select * 
        from {{ ref('int_sales_monthly_agg') }}
    )

select *
from sales_monthly_agg