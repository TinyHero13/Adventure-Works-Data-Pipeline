/*  Test that product sales quantities are within reasonable business limits
    This test validates that order quantities are realistic and identifies
    any potential data quality issues with extreme values */

with 
    product_quantity_stats as (
        select
            product_id
            , min(quantity_sold) as min_quantity
            , max(quantity_sold) as max_quantity
            , avg(quantity_sold) as avg_quantity
            , stddev(quantity_sold) as stddev_quantity
            , count(*) as total_orders
        from {{ ref('fact_sales') }}
        group by product_id
    )

    , outlier_products as (
        select
            product_id
            , min_quantity
            , max_quantity
            , avg_quantity
            , stddev_quantity
            , total_orders
            , case 
                when min_quantity <= 0 then 'Negative or Zero Quantity'
                when max_quantity > 1000 then 'Extremely High Quantity'
                when stddev_quantity > (avg_quantity * 2) then 'High Variance in Quantities'
                else 'Unknown Issue'
            end as issue_type
        from product_quantity_stats
        where min_quantity <= 0
        or max_quantity > 1000
        or stddev_quantity > (avg_quantity * 2)
    )

select *
from outlier_products
