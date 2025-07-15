{{ config(materialized='table') }}

with 
    sales_reason_bridge as (
    select * from {{ ref('stg_db__sales_order_header_sales_reason') }}
)

select *
from sales_reason_bridge