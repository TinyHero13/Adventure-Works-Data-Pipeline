with product as (
    select
        cast(productid as int) as product_id
        , name
        , productnumber as product_number
        , makeflag as make_flag
        , finishedgoodsflag as finished_goods_flag
        , color
        , cast(safetystocklevel as int) as safety_stock_level
        , cast(reorderpoint as int) as reorder_point
        , cast(listprice as decimal(19, 4)) as list_price
        , size
        , sizeunitmeasurecode as size_unit_measure_code
        , weightunitmeasurecode as weight_unit_measure_code
        , cast(weight as decimal(8, 2)) as weight 
        , cast(daystomanufacture as int) as days_to_manufacture
        , productline as product_line
        , class
        , style
        , cast(productsubcategoryid as int) as product_subcategory_id
        , cast(ProductModelID as int) as product_model_id
        , to_date(sellstartdate, 'MM/DD/YYYY') as sell_start_date
        , to_date(sellenddate, 'MM/DD/YYYY') as sell_end_date
        , to_date(discontinueddate, 'MM/DD/YYYY') as discontinued_date
        , rowguid as row_guid
        , to_date(modifieddate, 'MM/DD/YYYY') as modified_date
    from {{ source('source_db', 'product') }}
)

select *
from product