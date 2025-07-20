with credit_card as (
    select
        creditcardid as credit_card_pk
        , cardtype as card_type
        , cardnumber as card_number
        , expmonth as exp_month
        , expyear as exp_year
        , current_timestamp() as updated_at
    from {{ source('source_db', 'credit_card') }}
)

select *
from credit_card