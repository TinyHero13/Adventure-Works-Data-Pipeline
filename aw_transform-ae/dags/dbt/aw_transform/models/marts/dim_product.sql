with
    dim_products as (
        select
            product_id as product_pk
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
            , standard_cost
            , class
            , style
            , list_price
            , safety_stock_level
            , reorder_point
            , sell_start_date
            , sell_end_date
            , discontinued_date
            , current_timestamp() as updated_at
        from {{ ref('int_sales_product') }}
    )

select *
from dim_products
