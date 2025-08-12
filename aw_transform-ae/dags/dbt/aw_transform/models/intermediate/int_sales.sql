with
    sales_order_detail_db as (
        select
            sales_order_detail_id
            , sales_order_id
            , carrier_tracking_number
            , product_id
            , order_quantity
            , unit_price
            , unit_price_discount
            , line_total
        from {{ ref('stg_db__sales_order_detail') }}
    )

    , sales_order_detail_api as (
        select
            sales_order_detail_id
            , sales_order_id
            , carrier_tracking_number
            , product_id
            , order_quantity
            , unit_price
            , unit_price_discount
            , line_total
        from {{ ref('stg_api__sales_order_detail') }}
    )

    , sales_order_header_db as (
        select
            sales_order_id
            , credit_card_id
            , customer_id
            , due_date
            , freight
            , subtotal
            , total_due
            , online_order_flag
            , territory_id
            , order_date
            , purchase_order_number
            , revision_number
            , sales_person_id
            , ship_date
            , ship_method_id
            , ship_to_address_id
        from {{ ref('stg_db__sales_order_header') }}
    )

    , sales_order_header_api as (
        select
            sales_order_id
            , credit_card_id
            , customer_id
            , due_date
            , freight
            , subtotal
            , total_due
            , online_order_flag
            , territory_id
            , order_date
            , purchase_order_number
            , revision_number
            , sales_person_id
            , ship_date
            , ship_method_id
            , ship_to_address_id
        from {{ ref('stg_api__sales_order_header') }}
    )

    , credit_cards as (
        select
            credit_card_id
            , card_type
        from {{ ref('stg_db__credit_card') }}
    )

    , payment_methods as (
        select
            payment_method_id
            , payment_method_name
        from {{ ref('int_payment_method') }}
    )

    , sales_order_header_sales_reason as (
        select
            sales_order_id
            , sales_reason_id
        from {{ ref('stg_db__sales_order_header_sales_reason') }}
    )

    , unified_sales_order_detail as (
        select * from sales_order_detail_db
        union distinct
        select * from sales_order_detail_api
    )

    , unified_sales_order_header as (
        select * from sales_order_header_db
        union distinct
        select * from sales_order_header_api
    )

    , order_aggregations as (
        select
            unified_sales_order_header.sales_order_id
            , count(unified_sales_order_detail.sales_order_detail_id) as total_items_quantity
            , sum(unified_sales_order_detail.line_total) as order_total_amount
            , case
                when
                    unified_sales_order_header.ship_date is not null
                    and unified_sales_order_header.order_date is not null
                    then
                        datediff(
                            unified_sales_order_header.ship_date
                            , unified_sales_order_header.order_date
                        )
            end as days_to_ship
        from unified_sales_order_header
        left join unified_sales_order_detail as unified_sales_order_detail
            on unified_sales_order_header.sales_order_id
            = unified_sales_order_detail.sales_order_id
        group by
            unified_sales_order_header.sales_order_id
            , unified_sales_order_header.ship_date
            , unified_sales_order_header.order_date
    )

    , sales_with_details as (
        select
            unified_sales_order_detail.sales_order_detail_id
            , unified_sales_order_header.sales_order_id
            , unified_sales_order_header.customer_id
            , unified_sales_order_detail.product_id
            , unified_sales_order_header.sales_person_id
            , unified_sales_order_header.territory_id
            , payment_methods.payment_method_id
            , unified_sales_order_header.order_date
            , unified_sales_order_detail.order_quantity
            , unified_sales_order_detail.unit_price
            , unified_sales_order_detail.line_total
            , unified_sales_order_detail.unit_price_discount
            , unified_sales_order_header.online_order_flag
            , unified_sales_order_header.ship_date
            , unified_sales_order_header.due_date
            , unified_sales_order_header.freight
            , unified_sales_order_header.subtotal
            , unified_sales_order_header.total_due
            , order_aggregations.order_total_amount
            , order_aggregations.total_items_quantity
            , order_aggregations.days_to_ship
            , sales_order_header_sales_reason.sales_reason_id
            , current_timestamp() as updated_at
        from unified_sales_order_detail
        inner join unified_sales_order_header
            on unified_sales_order_detail.sales_order_id
            = unified_sales_order_header.sales_order_id
        left join order_aggregations
            on unified_sales_order_header.sales_order_id
            = order_aggregations.sales_order_id
        left join credit_cards
            on unified_sales_order_header.credit_card_id
            = credit_cards.credit_card_id
        left join payment_methods
            on credit_cards.card_type = payment_methods.payment_method_name
        left join sales_order_header_sales_reason
            on unified_sales_order_header.sales_order_id
            = sales_order_header_sales_reason.sales_order_id
    )

select *
from sales_with_details
