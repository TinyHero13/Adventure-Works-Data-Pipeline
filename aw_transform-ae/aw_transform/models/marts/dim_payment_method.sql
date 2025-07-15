with 
    dim_payment_method as (
        select * 
        from {{ ref('int_payment_method') }}
    )

select *
from dim_payment_method
