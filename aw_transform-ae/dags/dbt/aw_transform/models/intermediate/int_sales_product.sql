with 
    products as (
        select 
            product_pk
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
            , product_subcategory_fk
            , sell_start_date
            , sell_end_date
            , discontinued_date
        from {{ ref('stg_db__product') }}
    )

    , product_subcategories as (
        select 
            product_subcategory_pk
            , product_category_fk
            , product_subcategory_name
        from {{ ref('stg_db__product_subcategory') }}
    )

    , product_categories as (
        select 
            product_category_pk
            , product_category_name
        from {{ ref('stg_db__product_category') }}
    )

    , products_with_subcategories as (
        select
            products.product_pk
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
            , products.product_subcategory_fk
            , product_subcategories.product_subcategory_name
            , product_subcategories.product_category_fk
        from products
        left join product_subcategories
            on products.product_subcategory_fk = product_subcategories.product_subcategory_pk
    )

    , products_with_categories as (
        select
            products_with_subcategories.product_pk
            , products_with_subcategories.product_name
            , products_with_subcategories.product_number
            , products_with_subcategories.make_flag
            , products_with_subcategories.finished_goods_flag
            , products_with_subcategories.color
            , products_with_subcategories.safety_stock_level
            , products_with_subcategories.reorder_point
            , products_with_subcategories.list_price
            , products_with_subcategories.size
            , products_with_subcategories.size_unit_measure_code
            , products_with_subcategories.weight
            , products_with_subcategories.weight_unit_measure_code
            , products_with_subcategories.days_to_manufacture
            , products_with_subcategories.product_line
            , products_with_subcategories.class
            , products_with_subcategories.style
            , products_with_subcategories.sell_start_date
            , products_with_subcategories.sell_end_date
            , products_with_subcategories.discontinued_date
            , products_with_subcategories.product_subcategory_fk
            , products_with_subcategories.product_subcategory_name
            , products_with_subcategories.product_category_fk
            , product_categories.product_category_name
        from products_with_subcategories
        left join product_categories
        on products_with_subcategories.product_category_fk = product_categories.product_category_pk
    )

    , final as (
        select
            product_pk
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
            , current_timestamp() as updated_at
        from products_with_categories
    )

select * 
from final