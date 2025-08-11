with
    sales_order_header as (
        select
            cast(salesorderid as int) as sales_order_id
            , cast(creditcardid as int) as credit_card_id
            , cast(customerid as int) as customer_id
            , cast(salespersonid as int) as sales_person_id
            , cast(territoryid as int) as territory_id
            , cast(billtoaddressid as int) as bill_to_address_id
            , cast(shiptoaddressid as int) as ship_to_address_id
            , cast(shipmethodid as int) as ship_method_id
            , cast(currencyrateid as int) as currency_rate_id
            , cast(revisionnumber as int) as revision_number
            , cast(orderdate as date) as order_date
            , cast(status as int) as status
            , salesordernumber as sales_order_number
            , purchaseordernumber as purchase_order_number
            , accountnumber as account_number
            , creditcardapprovalcode as credit_card_approval_code
            , cast(subtotal as numeric(19, 4)) as subtotal
            , cast(freight as numeric(19, 4)) as freight
            , to_date(duedate, 'MM/DD/YYYY') as due_date
            , to_date(shipdate, 'MM/DD/YYYY') as ship_date
            , case
                when onlineorderflag = false then 'At store'
                else 'Online'
            end as online_order_flag
            , current_timestamp() as updated_at
        from {{ source('source_api', 'sales_order_header') }}
    )

select *
from sales_order_header
