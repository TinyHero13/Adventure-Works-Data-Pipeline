with 
    products as (
        select 
            product_id
            , product_name
            , product_number
            , make_flag
            , finished_goods_flag
            , color
            , safety_stock_level
            , reorder_point
            , list_price
            , size
            , size_unit_measure_code
            , weight
            , weight_unit_measure_code
            , days_to_manufacture
            , product_line
            , class
            , style
            , product_subcategory_id
            , sell_start_date
            , sell_end_date
            , discontinued_date
        from {{ ref('stg_db__product') }}
    )

    , product_subcategories as (
        select 
            product_subcategory_id
            , product_category_id
            , product_subcategory_name
        from {{ ref('stg_db__product_subcategory') }}
    )

    , product_categories as (
        select 
            product_category_id
            , product_category_name
        from {{ ref('stg_db__product_category') }}
    )

    , products_with_subcategories as (
        select
            products.product_id
            , products.product_name
            , products.product_number
            , products.make_flag
            , products.finished_goods_flag
            , products.color
            , products.safety_stock_level
            , products.reorder_point
            , products.list_price
            , products.size
            , products.size_unit_measure_code
            , products.weight
            , products.weight_unit_measure_code
            , products.days_to_manufacture
            , products.product_line
            , products.class
            , products.style
            , products.sell_start_date
            , products.sell_end_date
            , products.discontinued_date
            , products.product_subcategory_id
            , product_subcategories.product_subcategory_name
            , product_subcategories.product_category_id
        from products
        left join product_subcategories
            on products.product_subcategory_id = product_subcategories.product_subcategory_id
    )

    , products_with_categories as (
        select
            products_with_subcategories.*
            , product_categories.product_category_name
        from products_with_subcategories
        left join product_categories
        on products_with_subcategories.product_category_id = product_categories.product_category_id
    )

    , final as (
        select
            product_id
            , product_name
            , product_number
            , product_category_name
            , product_subcategory_name
            , color
            , size
            , size_unit_measure_code
            , weight
            , weight_unit_measure_code
            , make_flag
            , finished_goods_flag
            , days_to_manufacture
            , product_line
            , class
            , style
            , list_price
            , safety_stock_level
            , reorder_point
            , sell_start_date
            , sell_end_date
            , discontinued_date
        from products_with_categories
    )

select * 
from final