with sales_order_header_reason as (
    select
        cast(salesorderid as int) as sales_order_id
        , cast(salesreasonid as int) as sales_reason_id
    from {{ source('source_db', 'sales_order_header_sales_reason') }}
)

select *
from sales_order_header_reason