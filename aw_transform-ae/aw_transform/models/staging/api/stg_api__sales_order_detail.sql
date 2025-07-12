with sales_order_detail as (
    select
        cast(salesorderdetailid as int) as sales_order_detail_id
        , cast(salesorderid as int) as sales_order_id
        , carriertrackingnumber as carrier_tracking_number
        , cast(productid as int) as product_id
        , cast(orderqty as int) as order_quantity
        , cast(unitprice as numeric(19,4)) as unit_price
        , cast(unitpricediscount as numeric(19,4)) as unit_price_discount
        , cast(linetotal as numeric(38,6)) as line_total
    from {{ source('source_api', 'sales_order_detail') }}
)

select *
from sales_order_detail