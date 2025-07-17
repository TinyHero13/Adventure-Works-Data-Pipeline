with 
    dim_territory as (
        select * 
        from {{ ref('stg_db__sales_territory') }}
    )

select *
from dim_territory