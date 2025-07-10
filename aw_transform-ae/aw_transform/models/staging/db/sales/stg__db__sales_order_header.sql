with sales_order_header as (
    select
        accountnumber as account_number
        , cast(billtoaddressid as int) as bill_to_address_id
        , comment
        , creditcardapprovalcode as credit_card_approval_code
        , cast(creditcardid as int) as credit_card_id
        , cast(currencyrateid as int) as currency_rate_id
        , cast(customerid as int) as customer_id
        , to_date(duedate, 'MM/DD/YYYY') as due_date
        , cast(freight as numeric(19,4)) as freight
        , cast(onlineorderflag as boolean) as online_order_flag
        , cast(orderdate as date) as order_date
        , purchaseordernumber as purchase_order_number
        , cast(revisionnumber as int) as revision_number
        , cast(salesorderid as int) as sales_order_id
        , cast(salespersonid as int) as sales_person_id
        , to_date(shipdate, 'MM/DD/YYYY') as ship_date
        , cast(shipmethodid as int) as ship_method_id
        , cast(shiptoaddressid as int) as ship_to_address_id
    from {{ source('source_db', 'sales_order_header') }}
)

select *
from sales_order_header