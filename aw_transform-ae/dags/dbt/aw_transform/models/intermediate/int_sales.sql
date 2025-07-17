with 
    sales_order_detail_db as (
        select 
            sales_order_detail_id,
            sales_order_id,
            carrier_tracking_number,
            product_id,
            order_quantity,
            unit_price,
            unit_price_discount,
            line_total
        from {{ ref('stg_db__sales_order_detail') }}
    )

    , sales_order_detail_api as (
        select 
            sales_order_detail_id,
            sales_order_id,
            carrier_tracking_number,
            product_id,
            order_quantity,
            unit_price,
            unit_price_discount,
            line_total
        from {{ ref('stg_api__sales_order_detail') }}
    )

    , sales_order_header_db as (
        select 
            sales_order_id,
            credit_card_id,
            customer_id,
            due_date,
            freight,
            online_order_flag,
            territory_id,
            order_date,
            purchase_order_number,
            revision_number,
            sales_person_id,
            ship_date,
            ship_method_id,
            ship_to_address_id
        from {{ ref('stg_db__sales_order_header') }}
    )

    , sales_order_header_api as (
        select 
            sales_order_id,
            credit_card_id,
            customer_id,
            due_date,
            freight,
            online_order_flag,
            territory_id,
            order_date,
            purchase_order_number,
            revision_number,
            sales_person_id,
            ship_date,
            ship_method_id,
            ship_to_address_id
        from {{ ref('stg_api__sales_order_header') }}
    )

    , credit_cards as (
        select 
            credit_card_id,
            card_type
        from {{ ref('stg_db__credit_card') }}
    )

    , payment_methods as (
        select 
            payment_method_id,
            payment_method_name
        from {{ ref('int_payment_method') }}
    )

    , unified_sales_order_detail as (
        select * from sales_order_detail_db
        union
        select * from sales_order_detail_api
    )

    , unified_sales_order_header as (
        select * from sales_order_header_db
        union
        select * from sales_order_header_api
    )

    , order_aggregations as (
        select
            soh.sales_order_id
            , count(sod.sales_order_detail_id) as total_items_quantity
            , sum(sod.line_total) as order_total_amount
            , case 
                when soh.ship_date is not null and soh.order_date is not null 
                then datediff(soh.ship_date, soh.order_date)
                else null
            end as days_to_ship
        from unified_sales_order_header soh
        left join unified_sales_order_detail sod
            on soh.sales_order_id = sod.sales_order_id
        group by 
            soh.sales_order_id
            , soh.ship_date
            , soh.order_date
    )

    , sales_with_details as (
        select
            sod.sales_order_detail_id as sales_detail_id
            , soh.sales_order_id
            , soh.customer_id
            , sod.product_id
            , soh.sales_person_id
            , soh.territory_id
            , pm.payment_method_id
            , soh.order_date as order_date_id
            , sod.order_quantity as quantity_sold
            , sod.unit_price as price
            , sod.line_total as price_total
            , sod.unit_price_discount
            , soh.online_order_flag
            , soh.ship_date
            , soh.due_date
            , soh.freight as freight_amount
            , oa.order_total_amount
            , oa.total_items_quantity
            , oa.days_to_ship
        from unified_sales_order_detail sod
        inner join unified_sales_order_header soh
            on sod.sales_order_id = soh.sales_order_id
        left join order_aggregations oa
            on soh.sales_order_id = oa.sales_order_id
        left join credit_cards cc
            on soh.credit_card_id = cc.credit_card_id
        left join payment_methods pm
            on cc.card_type = pm.payment_method_name
    )

select *
from sales_with_details
