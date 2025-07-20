/*  Test that sales order totals match the sum of line items
    This test validates that the calculated totals from detail records
    match the aggregated totals in the fact table */

with 
    order_totals_from_details as (
        select
            sales_order_pk,
            sum(price_total) as calculated_total_from_details
        from {{ ref('fact_sales') }}
        group by sales_order_pk
    )

    , order_totals_from_agg as (
        select
            sales_order_pk
            , order_total_amount
        from {{ ref('fact_sales') }}
        group by sales_order_pk, order_total_amount
    )

    , mismatched_totals as (
        select
            order_totals_from_details.sales_order_pk
            , order_totals_from_details.calculated_total_from_details
            , order_totals_from_agg.order_total_amount
            , abs(order_totals_from_details.calculated_total_from_details - order_totals_from_agg.order_total_amount) as difference
        from order_totals_from_details
        join order_totals_from_agg on order_totals_from_details.sales_order_pk = order_totals_from_agg.sales_order_pk
        where abs(order_totals_from_details.calculated_total_from_details - order_totals_from_agg.order_total_amount) > 0.01
    )

select * 
from mismatched_totals
