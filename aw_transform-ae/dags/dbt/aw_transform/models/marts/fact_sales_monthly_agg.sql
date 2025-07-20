with 
    sales_monthly_agg as (
        select 
            month_year
            , territory_fk
            , product_fk
            , payment_method_fk
            , year_actual
            , month_actual
            , month_name
            , quarter_actual
            , mmyyyy
            , total_sales_transactions
            , total_orders
            , unique_customers
            , total_revenue
            , total_order_value
            , total_freight
            , total_discount_amount
            , total_quantity_sold
            , total_items_in_orders
            , avg_order_value
            , avg_revenue_per_customer
            , avg_items_per_order
            , avg_unit_price
            , avg_days_to_ship
            , online_revenue
            , offline_revenue
            , online_orders_count
            , offline_orders_count
            , online_revenue_percentage
            , discount_percentage
            , freight_percentage
            , revenue_growth_mom
            , orders_growth_mom
            , ytd_revenue
            , ytd_orders
            , product_share_in_territory
            , current_timestamp() as updated_at
        from {{ ref('int_sales_monthly_agg') }}
    )

select *
from sales_monthly_agg