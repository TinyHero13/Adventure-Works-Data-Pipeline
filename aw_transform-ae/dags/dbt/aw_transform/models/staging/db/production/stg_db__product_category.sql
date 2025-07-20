with product_category as (
    select
        cast(productcategoryid as int) as product_category_pk
        , name as product_category_name
        , current_timestamp() as updated_at
    from {{ source('source_db', 'product_category') }}
)

select * 
from product_category