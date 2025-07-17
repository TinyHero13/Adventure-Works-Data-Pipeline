with product_subcategory as (
    select
        cast(productsubcategoryid as int) as product_subcategory_pk
        , cast(productcategoryid as int) as product_category_fk
        , name as product_subcategory_name
        , current_timestamp() as updated_at
    from {{ source('source_db', 'product_subcategory') }}
)

select *
from product_subcategory