/*  Test that customer sales data is consistent across sources
    This test validates that customer sales data from API and database sources
    are consistent and identifies any discrepancies between sources */

with 
    api_customer_sales as (
        select
            customer_fk
            , count(*) as api_sales_count
            , sum(line_total) as api_total_amount
        from {{ ref('stg_api__sales_order_detail') }} sales_order_detail
        join {{ ref('stg_api__sales_order_header') }} sales_order_header
            on sales_order_detail.sales_order_fk = sales_order_header.sales_order_pk
        group by customer_fk
    )

    , db_customer_sales as (
        select
            customer_fk
            , count(*) as db_sales_count
            , sum(line_total) as db_total_amount
        from {{ ref('stg_db__sales_order_detail') }} sales_order_detail
        join {{ ref('stg_db__sales_order_header') }} sales_order_header
            on sales_order_detail.sales_order_fk = sales_order_header.sales_order_pk
        group by customer_fk
    )

    , inconsistent_customers as (
        select
            coalesce(api_customer_sales.customer_fk, db_customer_sales.customer_fk) as customer_fk
            , api_customer_sales.api_sales_count
            , db_customer_sales.db_sales_count
            , api_customer_sales.api_total_amount
            , db_customer_sales.db_total_amount
            , case 
                when api_customer_sales.customer_fk is null then 'Missing in API'
                when db_customer_sales.customer_fk is null then 'Missing in DB'
                when abs(api_customer_sales.api_total_amount - db_customer_sales.db_total_amount) > 0.01 then 'Amount Mismatch'
                else 'Unknown Issue'
            end as issue_type
        from api_customer_sales
        full outer join db_customer_sales
            on api_customer_sales.customer_fk = db_customer_sales.customer_fk
        where api_customer_sales.customer_fk is null 
        or db_customer_sales.customer_fk is null
        or abs(api_customer_sales.api_total_amount - db_customer_sales.db_total_amount) > 0.01
)

select * 
from inconsistent_customers
