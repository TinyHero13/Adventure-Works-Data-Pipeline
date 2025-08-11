with
    person as (
        select
            cast(businessentityid as int) as business_entity_id
            , title
            , suffix
            , emailpromotion as email_promotion
            , additionalcontactinfo as additional_contact_info
            , demographics
            , case persontype
                when 'SC' then 'Store Contact'
                when 'IN' then 'Individual (retail) customer'
                when 'SP' then 'Sales person'
                when 'EM' then 'Employee (non-sales)'
                when 'VC' then 'Vendor contact'
                when 'GC' then 'General contact'
                else 'Other'
            end as person_type
            , coalesce(firstname, '') || ' ' || coalesce(middlename, '') || ' ' || coalesce(lastname, '') as full_name
            , current_timestamp() as updated_at
        from {{ source('source_db', 'person') }}
    )

select *
from person
