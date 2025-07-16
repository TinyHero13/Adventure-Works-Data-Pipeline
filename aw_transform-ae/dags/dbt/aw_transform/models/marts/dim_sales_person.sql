with 
    dim_sales_person as (
        select * 
        from {{ ref('int_sales_sales_person_person') }}
    )

select * 
from dim_sales_person