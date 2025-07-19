with 
    sales_reason_bridge as (
        select 
            sales_order_pk
            , sales_reason_fk
            , current_timestamp() as updated_at
        from {{ ref('stg_db__sales_order_header_sales_reason') }}
)

select *
from sales_reason_bridge