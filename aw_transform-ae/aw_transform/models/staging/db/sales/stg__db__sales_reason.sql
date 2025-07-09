with sales_reason as (
    select
        cast(salesreasonid as int) as sales_reason_id
        , name
    from {{ source('source_db', 'sales_reason') }}
)

select * 
from sales_reason