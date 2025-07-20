with 
    sales_data as (
        select 
            sales_person_fk
            , sales_order_pk
            , customer_fk
            , product_fk
            , territory_fk
            , payment_method_fk
            , order_date
            , quantity_sold
            , price
            , price_total
            , unit_price_discount
            , online_order_flag
            , ship_date
            , due_date
            , freight_amount
            , order_total_amount
            , total_items_quantity
            , days_to_ship
        from {{ ref('int_sales') }}
    )
    
    , calendar_data as (
        select 
            date_actual
            , reference_month
            , year_actual
            , month_actual
            , month_name
            , quarter_actual
            , mmyyyy
        from {{ ref('dates') }}
    )

    , sales_with_calendar as (
        select 
            sales_data.sales_person_fk
            , sales_data.sales_order_pk
            , sales_data.customer_fk
            , sales_data.product_fk
            , sales_data.territory_fk
            , sales_data.payment_method_fk
            , sales_data.order_date
            , sales_data.quantity_sold
            , sales_data.price
            , sales_data.price_total
            , sales_data.unit_price_discount
            , sales_data.online_order_flag
            , sales_data.ship_date
            , sales_data.due_date
            , sales_data.freight_amount
            , sales_data.order_total_amount
            , sales_data.total_items_quantity
            , sales_data.days_to_ship
            , calendar_data.reference_month
            , calendar_data.year_actual
            , calendar_data.month_actual
            , calendar_data.month_name
            , calendar_data.quarter_actual
            , calendar_data.mmyyyy
        from sales_data
        inner join calendar_data
            on sales_data.order_date = calendar_data.date_actual
    )

    , monthly_agg_metrics as (
        select
            /* Dimension Keys */
            reference_month as month_year
            , territory_fk  
            , product_fk
            , payment_method_fk
            , year_actual
            , month_actual
            , month_name
            , quarter_actual
            , mmyyyy
            
            /* Volume metrics */
            , count(distinct sales_person_fk) as total_sales_transactions
            , count(distinct sales_order_pk) as total_orders
            , count(distinct customer_fk) as unique_customers
            
            /* Revenue metrics */
            , sum(price_total) as total_revenue
            , sum(order_total_amount) as total_order_value
            , sum(freight_amount) as total_freight
            , sum(unit_price_discount) as total_discount_amount
            
            /* Quantity metrics */
            , sum(quantity_sold) as total_quantity_sold
            , sum(total_items_quantity) as total_items_in_orders
            
            /* Calculated metrics */
            , round(sum(price_total) / count(distinct sales_order_pk), 2) as avg_order_value
            , round(sum(price_total) / count(distinct customer_fk), 2) as avg_revenue_per_customer
            , round(sum(quantity_sold) / count(distinct sales_order_pk), 2) as avg_items_per_order
            , round(avg(price), 2) as avg_unit_price
            , round(avg(days_to_ship), 1) as avg_days_to_ship
            
            /* Channel metrics */
            , sum(case when online_order_flag = 'Online' then price_total else 0 end) as online_revenue
            , sum(case when online_order_flag = 'At store' then price_total else 0 end) as offline_revenue
            , count(distinct case when online_order_flag = 'Online' then sales_order_pk end) as online_orders_count
            , count(distinct case when online_order_flag = 'At store' then sales_order_pk end) as offline_orders_count
            
            /* Channel percentages */
            , round(
                sum(case when online_order_flag = 'Online' then price_total else 0 end) * 100.0 / 
                nullif(sum(price_total), 0), 2
            ) as online_revenue_percentage
            
            /* Discount metrics */
            , round(
                sum(unit_price_discount) * 100.0 / 
                nullif(sum(price_total + unit_price_discount), 0), 2
            ) as discount_percentage
            
            /* Freight metrics */
            , round(
                sum(freight_amount) * 100.0 / 
                nullif(sum(price_total), 0), 2
            ) as freight_percentage
            
        from sales_with_calendar
        group by 
            reference_month
            , territory_fk
            , product_fk
            , payment_method_fk
            , year_actual
            , month_actual
            , month_name
            , quarter_actual
            , mmyyyy
    )
    
    , monthly_agg_with_growth as (
        select 
            *
            , current_timestamp() as updated_at
            /* Month-over-month growth rate by territory, product and payment method */
            , round(
                (total_revenue - lag(total_revenue) over (
                    partition by territory_fk, product_fk, payment_method_fk 
                    order by month_year
                )) * 100.0 / 
                nullif(lag(total_revenue) over (
                    partition by territory_fk, product_fk, payment_method_fk 
                    order by month_year
                ), 0), 2
            ) as revenue_growth_mom
            
            , round(
                (total_orders - lag(total_orders) over (
                    partition by territory_fk, product_fk, payment_method_fk 
                    order by month_year
                )) * 100.0 / 
                nullif(lag(total_orders) over (
                    partition by territory_fk, product_fk, payment_method_fk 
                    order by month_year
                ), 0), 2
            ) as orders_growth_mom
            
            /* Year-to-date accumulated by territory, product and payment method */
            , sum(total_revenue) over (
                partition by territory_fk, product_fk, payment_method_fk, year_actual 
                order by month_actual 
                rows unbounded preceding
            ) as ytd_revenue
            
            , sum(total_orders) over (
                partition by territory_fk, product_fk, payment_method_fk, year_actual 
                order by month_actual 
                rows unbounded preceding
            ) as ytd_orders
            
            /* Market share within territory for the month */
            , round(
                total_revenue * 100.0 / 
                sum(total_revenue) over (partition by territory_fk, month_year), 2
            ) as product_share_in_territory
            
        from monthly_agg_metrics
    )

select *
from monthly_agg_with_growth
order by month_year, territory_fk, product_fk, payment_method_fk