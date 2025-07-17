with person as (
    select
        cast(businessentityid as int) as business_entity_id
        , case persontype
            when 'SC' then 'Store Contact'
            when 'IN' then 'Individual (retail) customer'
            when 'SP' then 'Sales person'
            when 'EM' then 'Employee (non-sales)'
            when 'VC' then 'Vendor contact'
            when 'GC' then 'General contact'
            else 'Other'
        end as person_type
        , firstname || ' ' || middlename || ' ' || lastname as full_name
    from {{ source('source_db', 'person') }}
)

select *
from person