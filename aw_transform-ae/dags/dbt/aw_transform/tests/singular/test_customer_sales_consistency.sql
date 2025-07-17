/*  Test that customer sales data is consistent across sources
    This test validates that customer sales data from API and database sources
    are consistent and identifies any discrepancies between sources */

with 
    api_customer_sales as (
        select
            customer_id
            , count(*) as api_sales_count
            , sum(line_total) as api_total_amount
        from {{ ref('stg_api__sales_order_detail') }} sales_order_detail
        join {{ ref('stg_api__sales_order_header') }} sales_order_header
            on sales_order_detail.sales_order_id = sales_order_header.sales_order_id
        group by customer_id
    )

    , db_customer_sales as (
        select
            customer_id
            , count(*) as db_sales_count
            , sum(line_total) as db_total_amount
        from {{ ref('stg_db__sales_order_detail') }} sales_order_detail
        join {{ ref('stg_db__sales_order_header') }} sales_order_header
            on sales_order_detail.sales_order_id = sales_order_header.sales_order_id
        group by customer_id
    )

    , inconsistent_customers as (
        select
            coalesce(api_customer_sales.customer_id, db_customer_sales.customer_id) as customer_id
            , api_customer_sales.api_sales_count
            , db_customer_sales.db_sales_count
            , api_customer_sales.api_total_amount
            , db_customer_sales.db_total_amount
            , case 
                when api_customer_sales.customer_id is null then 'Missing in API'
                when db_customer_sales.customer_id is null then 'Missing in DB'
                when abs(api_customer_sales.api_total_amount - db_customer_sales.db_total_amount) > 0.01 then 'Amount Mismatch'
                else 'Unknown Issue'
            end as issue_type
        from api_customer_sales
        full outer join db_customer_sales
            on api_customer_sales.customer_id = db_customer_sales.customer_id
        where api_customer_sales.customer_id is null 
        or db_customer_sales.customer_id is null
        or abs(api_customer_sales.api_total_amount - db_customer_sales.db_total_amount) > 0.01
)

select * 
from inconsistent_customers
