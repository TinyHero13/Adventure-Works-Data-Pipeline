with sales_reason as (
    select
        cast(salesreasonid as int) as sales_reason_id
        , name
        , to_date(modifieddate, 'MM/DD/YYYY') as modified_date
    from {{ source('source_db', 'sales_reason') }}
)

select * 
from sales_reason