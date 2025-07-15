with 
    sales_facts as (
        select * from {{ ref('int_sales') }}
    )

select *
from sales_facts
