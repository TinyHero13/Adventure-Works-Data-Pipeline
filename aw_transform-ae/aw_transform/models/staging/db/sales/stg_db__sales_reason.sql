with sales_reason as (
    select
        cast(salesreasonid as int) as sales_reason_id
        , name as sales_reason_name
    from {{ source('source_db', 'sales_reason') }}
)

select * 
from sales_reason