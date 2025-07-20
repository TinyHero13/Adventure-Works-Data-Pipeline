with 
    sales_order_detail_db as (
        select 
            sales_order_detail_pk,
            sales_order_fk,
            carrier_tracking_number,
            product_fk,
            order_quantity,
            unit_price,
            unit_price_discount,
            line_total
        from {{ ref('stg_db__sales_order_detail') }}
    )

    , sales_order_detail_api as (
        select 
            sales_order_detail_pk,
            sales_order_fk,
            carrier_tracking_number,
            product_fk,
            order_quantity,
            unit_price,
            unit_price_discount,
            line_total
        from {{ ref('stg_api__sales_order_detail') }}
    )

    , sales_order_header_db as (
        select 
            sales_order_pk,
            credit_card_fk,
            customer_fk,
            due_date,
            freight,
            online_order_flag,
            territory_fk,
            order_date,
            purchase_order_number,
            revision_number,
            sales_person_fk,
            ship_date,
            ship_method_fk,
            ship_to_address_fk
        from {{ ref('stg_db__sales_order_header') }}
    )

    , sales_order_header_api as (
        select 
            sales_order_pk,
            credit_card_fk,
            customer_fk,
            due_date,
            freight,
            online_order_flag,
            territory_fk,
            order_date,
            purchase_order_number,
            revision_number,
            sales_person_fk,
            ship_date,
            ship_method_fk,
            ship_to_address_fk
        from {{ ref('stg_api__sales_order_header') }}
    )

    , credit_cards as (
        select 
            credit_card_pk,
            card_type
        from {{ ref('stg_db__credit_card') }}
    )

    , payment_methods as (
        select 
            payment_method_pk,
            payment_method_name
        from {{ ref('int_payment_method') }}
    )

    , sales_order_header_sales_reason as (
        select
            sales_order_fk,
            sales_reason_fk
        from {{ ref('stg_db__sales_order_header_sales_reason') }}
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
            unified_sales_order_header.sales_order_pk
            , count(unified_sales_order_detail.sales_order_detail_pk) as total_items_quantity
            , sum(unified_sales_order_detail.line_total) as order_total_amount
            , case 
                when unified_sales_order_header.ship_date is not null and unified_sales_order_header.order_date is not null 
                then datediff(unified_sales_order_header.ship_date, unified_sales_order_header.order_date)
                else null
            end as days_to_ship
        from unified_sales_order_header 
        left join unified_sales_order_detail unified_sales_order_detail
            on unified_sales_order_header.sales_order_pk = unified_sales_order_detail.sales_order_fk
        group by 
            unified_sales_order_header.sales_order_pk
            , unified_sales_order_header.ship_date
            , unified_sales_order_header.order_date
    )

    , sales_with_details as (
        select
            unified_sales_order_detail.sales_order_detail_pk
            , unified_sales_order_header.sales_order_pk
            , unified_sales_order_header.customer_fk
            , unified_sales_order_detail.product_fk
            , unified_sales_order_header.sales_person_fk
            , unified_sales_order_header.territory_fk
            , payment_methods.payment_method_pk as payment_method_fk
            , unified_sales_order_header.order_date
            , unified_sales_order_detail.order_quantity as quantity_sold
            , unified_sales_order_detail.unit_price as price
            , unified_sales_order_detail.line_total as price_total
            , unified_sales_order_detail.unit_price_discount
            , unified_sales_order_header.online_order_flag
            , unified_sales_order_header.ship_date
            , unified_sales_order_header.due_date
            , unified_sales_order_header.freight as freight_amount
            , order_aggregations.order_total_amount
            , order_aggregations.total_items_quantity
            , order_aggregations.days_to_ship
            , sales_order_header_sales_reason.sales_reason_fk
            , current_timestamp() as updated_at
        from unified_sales_order_detail
        inner join unified_sales_order_header
            on unified_sales_order_detail.sales_order_fk = unified_sales_order_header.sales_order_pk
        left join order_aggregations
            on unified_sales_order_header.sales_order_pk = order_aggregations.sales_order_pk
        left join credit_cards
            on unified_sales_order_header.credit_card_fk = credit_cards.credit_card_pk
        left join payment_methods
            on credit_cards.card_type = payment_methods.payment_method_name
        left join sales_order_header_sales_reason
            on unified_sales_order_header.sales_order_pk = sales_order_header_sales_reason.sales_order_fk
    )

select *
from sales_with_details
