with
    dim_sales_reason as (
        select
            sales_reason_id as sales_reason_pk
            , sales_reason_name
            , reason_type
            , current_timestamp() as updated_at
        from {{ ref('stg_db__sales_reason') }}
    )

select *
from dim_sales_reason
