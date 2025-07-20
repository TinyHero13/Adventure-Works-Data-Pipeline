with sales_reason as (
    select
        cast(salesreasonid as int) as sales_reason_pk
        , name as sales_reason_name
        , reasontype as reason_type
        , current_timestamp() as updated_at
    from {{ source('source_db', 'sales_reason') }}
)

select * 
from sales_reason