with
    sales_order_detail as (
        select
            cast(salesorderdetailid as int) as sales_order_detail_id
            , cast(productid as int) as product_id
            , cast(salesorderid as int) as sales_order_id
            , cast(specialofferid as int) as special_offer_id
            , carriertrackingnumber as carrier_tracking_number
            , cast(orderqty as int) as order_quantity
            , cast(unitprice as numeric(19, 4)) as unit_price
            , cast(unitpricediscount as numeric(19, 4)) as unit_price_discount
            , cast(linetotal as numeric(38, 6)) as line_total
            , current_timestamp() as updated_at
        from {{ source('source_db', 'sales_order_detail') }}
    )

select *
from sales_order_detail
