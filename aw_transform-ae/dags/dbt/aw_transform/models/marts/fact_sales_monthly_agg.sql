with
    dim_product as (
        select product_pk
        from {{ ref('dim_product') }}
    )

    , dim_territory as (
        select territory_pk
        from {{ ref('dim_territory') }}
    )

    , dim_payment_method as (
        select payment_method_pk
        from {{ ref('dim_payment_method') }}
    )

    , sales_monthly_agg as (
        select
            int_sales_monthly_agg.month_year
            , dim_territory.territory_pk as territory_fk
            , dim_product.product_pk as product_fk
            , dim_payment_method.payment_method_pk as payment_method_fk
            , int_sales_monthly_agg.year_actual
            , int_sales_monthly_agg.month_actual
            , int_sales_monthly_agg.month_name
            , int_sales_monthly_agg.quarter_actual
            , int_sales_monthly_agg.mmyyyy
            , int_sales_monthly_agg.total_sales_transactions
            , int_sales_monthly_agg.total_orders
            , int_sales_monthly_agg.unique_customers
            , int_sales_monthly_agg.total_revenue
            , int_sales_monthly_agg.total_order_value
            , int_sales_monthly_agg.total_freight
            , int_sales_monthly_agg.total_discount_amount
            , int_sales_monthly_agg.total_quantity_sold
            , int_sales_monthly_agg.total_items_in_orders
            , int_sales_monthly_agg.avg_order_value
            , int_sales_monthly_agg.avg_revenue_per_customer
            , int_sales_monthly_agg.avg_items_per_order
            , int_sales_monthly_agg.avg_unit_price
            , int_sales_monthly_agg.avg_days_to_ship
            , int_sales_monthly_agg.online_revenue
            , int_sales_monthly_agg.offline_revenue
            , int_sales_monthly_agg.online_orders_count
            , int_sales_monthly_agg.offline_orders_count
            , int_sales_monthly_agg.online_revenue_percentage
            , int_sales_monthly_agg.discount_percentage
            , int_sales_monthly_agg.freight_percentage
            , int_sales_monthly_agg.revenue_growth_mom
            , int_sales_monthly_agg.orders_growth_mom
            , int_sales_monthly_agg.ytd_revenue
            , int_sales_monthly_agg.ytd_orders
            , int_sales_monthly_agg.product_share_in_territory
            , current_timestamp() as updated_at
        from {{ ref('int_sales_monthly_agg') }} as int_sales_monthly_agg
        left join dim_product
            on int_sales_monthly_agg.product_id = dim_product.product_pk
        left join dim_territory
            on int_sales_monthly_agg.territory_id = dim_territory.territory_pk
        left join dim_payment_method
            on int_sales_monthly_agg.payment_method_id
            = dim_payment_method.payment_method_pk
    )

select *
from sales_monthly_agg
