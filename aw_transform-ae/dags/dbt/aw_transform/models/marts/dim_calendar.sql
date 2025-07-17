with 
    dim_calendar as (
        select * 
        from {{ ref('dates') }}
    )

select *
from dim_calendar
