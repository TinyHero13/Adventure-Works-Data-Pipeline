with person as (
     select
         cast(businessentityid as int) as business_entity_id
         , persontype as person_type
         , firstname as first_name
        , lastname as last_name
        , middlename as middle_name
    from {{ source('source_db', 'person') }}
)

select *
from person