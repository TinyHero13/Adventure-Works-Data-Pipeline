with credit_card as (
    select
        creditcardid as credit_card_id
        , cardtype as card_type
    from {{ source('source_db', 'credit_card') }}
)

select *
from credit_card