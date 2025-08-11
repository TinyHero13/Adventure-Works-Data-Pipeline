/*  Test that sales order totals match the sum of line items
    This test validates that the calculated totals from detail records
    match the aggregated totals in the fact table */

with
    order_totals as (
        select
            sales_order_fk
            , sum(line_total) as calculated_total_from_details
            , max(order_total_amount) as order_total_amount
        from {{ ref('fact_sales') }}
        group by sales_order_fk
    )

    , mismatched_totals as (
        select
            sales_order_fk
            , calculated_total_from_details
            , order_total_amount
            , abs(calculated_total_from_details - order_total_amount)
                as difference
        from order_totals
        where abs(calculated_total_from_details - order_total_amount) > 0.01
    )

select *
from mismatched_totals
