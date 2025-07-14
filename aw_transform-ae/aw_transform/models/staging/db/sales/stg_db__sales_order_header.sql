with sales_order_header as (
    select
        cast(salesorderid as int) as sales_order_id
        , cast(creditcardid as int) as credit_card_id
        , cast(customerid as int) as customer_id
        , to_date(duedate, 'MM/DD/YYYY') as due_date
        , cast(freight as numeric(19,4)) as freight
        , case 
            when onlineorderflag = false then 'At store' 
            else 'Online' 
        end as online_order_flag
        , cast(territoryid as int) as territory_id
        , cast(orderdate as date) as order_date
        , purchaseordernumber as purchase_order_number
        , cast(revisionnumber as int) as revision_number
        , cast(salespersonid as int) as sales_person_id
        , to_date(shipdate, 'MM/DD/YYYY') as ship_date
        , cast(shipmethodid as int) as ship_method_id
        , cast(shiptoaddressid as int) as ship_to_address_id
    from {{ source('source_db', 'sales_order_header') }}
)

select *
from sales_order_header