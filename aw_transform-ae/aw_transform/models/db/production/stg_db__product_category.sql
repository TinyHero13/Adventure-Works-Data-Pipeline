with product_category as (
    select
        cast(productcategoryid as int) as product_category_id
        , name
    from {{ source('source_db', 'product_category') }}
)

select * 
from product_category