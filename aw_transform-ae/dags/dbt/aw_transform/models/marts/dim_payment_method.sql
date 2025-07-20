with 
    dim_payment_method as (
        select 
            payment_method_pk
            , payment_method_name
            , current_timestamp() as updated_at
        from {{ ref('int_payment_method') }}
    )

select *
from dim_payment_method
