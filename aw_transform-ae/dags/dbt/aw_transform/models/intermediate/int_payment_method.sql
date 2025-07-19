with 
    credit_cards as (
        select 
            credit_card_pk
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
            row_number() over (order by payment_method_name) as payment_method_pk
            , payment_method_name
            , current_timestamp() as updated_at
        from payment_types
    )

select * 
from dim_payment_method