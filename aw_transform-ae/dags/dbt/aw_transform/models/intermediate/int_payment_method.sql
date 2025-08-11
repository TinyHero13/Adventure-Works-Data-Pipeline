with
    credit_cards as (
        select
            credit_card_id
            , card_type
        from {{ ref('stg_db__credit_card') }}
    )

    , payment_types as (
        select distinct 
            card_type as payment_method_name
        from credit_cards
    )

    , dim_payment_method as (
        select
            payment_method_name
            , row_number()
                over (order by payment_method_name)
                as payment_method_id
            , current_timestamp() as updated_at
        from payment_types
    )

    , unknown_record as (
        select
            'Other' as payment_method_name
            , 0 as payment_method_id
            , current_timestamp() as updated_at
    )

    , final as (
        select * from unknown_record
        union all
        select * from dim_payment_method
    )

select *
from final
