with purchase_order_detail as (
    select
        cast(productid as int) as product_id
        , cast(purchaseorderid as int) as purchase_order_id
        , cast(purchaseorderdetailid as int) as purchase_order_detail_id
        , cast(orderqty as int) as order_quantity
        , cast(unitprice as numeric(19,4)) as unit_price
        , to_date(duedate, 'MM/DD/YYYY') as due_date
        , cast(linetotal as numeric(19,4)) as line_total
        , cast(receivedqty as numeric(19,4)) as received_quantity
        , cast(rejectedqty as numeric(19,4)) as rejected_quantity
        , cast(stockedqty as numeric(19,4)) as stocked_quantity
    from {{ source('source_api', 'purchase_order_detail') }}
)

select *
from purchase_order_detail