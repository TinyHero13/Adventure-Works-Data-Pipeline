with 
    sales_facts as (
        select 
            sales_order_detail_pk
            , sales_order_pk
            , customer_fk
            , product_fk
            , sales_person_fk
            , territory_fk
            , payment_method_fk
            , sales_reason_fk
            , order_date
            , quantity_sold
            , price
            , price_total
            , unit_price_discount
            , online_order_flag
            , ship_date
            , due_date
            , freight_amount
            , order_total_amount
            , total_items_quantity
            , current_timestamp() as updated_at
        from {{ ref('int_sales') }}
    )

select *
from sales_facts