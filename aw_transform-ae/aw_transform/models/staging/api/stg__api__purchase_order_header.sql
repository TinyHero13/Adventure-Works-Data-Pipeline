with purchase_order_header as (
    select 
        cast(employeeid as int) as employee_id
        , cast(freight as numeric(19,4)) as freight
        , to_date(orderdate, 'MM/DD/YYYY') as order_date
        , cast(purchaseorderid as int) as purchase_order_id
        , cast(revisionnumber as int) as revision_number
        , to_date(shipdate, 'MM/DD/YYYY') as ship_date
        , cast(shipmethodid as int) as ship_method_id
        , cast(status as int) as status
        , cast(subtotal as numeric(19,4)) as sub_total
        , cast(taxamt as numeric(19,4)) as tax_amount
        , cast(totaldue as numeric(19,4)) as total_due
        , cast(vendorid as int) as vendor_id
    from {{ source('source_api',   'purchase_order_header') }}
)

select *
from purchase_order_header