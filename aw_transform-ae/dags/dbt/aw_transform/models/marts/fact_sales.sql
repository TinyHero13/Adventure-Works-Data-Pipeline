with
    dim_product as (
        select product_pk
        from {{ ref('dim_product') }}
    )

    , dim_customer as (
        select customer_fk
        from {{ ref('dim_customer') }}
    )

    , dim_sales_person as (
        select sales_person_pk
        from {{ ref('dim_sales_person') }}
    )

    , dim_territory as (
        select territory_pk
        from {{ ref('dim_territory') }}
    )

    , dim_payment_method as (
        select payment_method_pk
        from {{ ref('dim_payment_method') }}
    )

    , dim_sales_reason as (
        select sales_reason_pk
        from {{ ref('dim_sales_reason') }}
    )

    , sales_facts as (
        select
            int_sales.sales_order_detail_id as sales_order_detail_pk
            , int_sales.sales_order_id as sales_order_fk
            , try_cast(dim_customer.customer_fk as bigint) as customer_fk
            , try_cast(dim_product.product_pk as bigint) as product_fk
            , coalesce(try_cast(dim_sales_person.sales_person_pk as bigint), 0) as sales_person_fk
            , try_cast(dim_territory.territory_pk as bigint) as territory_fk
            , coalesce(try_cast(dim_payment_method.payment_method_pk as bigint), 0) as payment_method_fk
            , try_cast(dim_sales_reason.sales_reason_pk as bigint) as sales_reason_fk
            , int_sales.order_date
            , int_sales.order_quantity
            , int_sales.unit_price
            , int_sales.line_total
            , int_sales.unit_price_discount
            , int_sales.online_order_flag
            , int_sales.ship_date
            , int_sales.due_date
            , int_sales.subtotal
            , int_sales.total_due
            , int_sales.freight
            , int_sales.order_total_amount
            , int_sales.total_items_quantity
            , int_sales.days_to_ship
            , current_timestamp() as updated_at
        from {{ ref('int_sales') }} as int_sales
        left join dim_product
            on try_cast(int_sales.product_id as bigint) = try_cast(dim_product.product_pk as bigint)
        left join dim_customer
            on try_cast(int_sales.customer_id as bigint) = try_cast(dim_customer.customer_fk as bigint)
        left join dim_sales_person
            on try_cast(int_sales.sales_person_id as bigint) = try_cast(dim_sales_person.sales_person_pk as bigint)
        left join dim_territory
            on try_cast(int_sales.territory_id as bigint) = try_cast(dim_territory.territory_pk as bigint)
        left join dim_payment_method
            on try_cast(int_sales.payment_method_id as bigint)
            = try_cast(dim_payment_method.payment_method_pk as bigint)
        left join dim_sales_reason
            on try_cast(int_sales.sales_reason_id as bigint) = try_cast(dim_sales_reason.sales_reason_pk as bigint)
    )

select *
from sales_facts
