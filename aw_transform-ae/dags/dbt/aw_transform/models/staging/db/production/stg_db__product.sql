with product as (
    select
        cast(productid as int) as product_pk
        , cast(productsubcategoryid as int) as product_subcategory_fk
        , cast(productmodelid as int) as product_model_fk
        , name as product_name
        , productnumber as product_number
        , case 
            when makeflag = false then 'Purchased'
            else 'Manufactured'
        end as make_flag
        , case 
            when finishedgoodsflag = false then 'Not Finished'
            else 'Finished'
        end as finished_goods_flag
        , color
        , cast(safetystocklevel as int) as safety_stock_level
        , cast(reorderpoint as int) as reorder_point
        , cast(standardcost as decimal(19, 4)) as standard_cost
        , cast(listprice as decimal(19, 4)) as list_price
        , size
        , sizeunitmeasurecode as size_unit_measure_code
        , cast(weight as decimal(8, 2)) as weight 
        , weightunitmeasurecode as weight_unit_measure_code
        , cast(daystomanufacture as int) as days_to_manufacture
        , case 
            when trim(productline) = 'R' then 'Road'
            when trim(productline) = 'M' then 'Mountain'
            when trim(productline) = 'T' then 'Touring'
            when trim(productline) = 'S' then 'Standard'
            else 'Other'
        end as product_line
        , case 
            when trim(class) = 'H' then 'High'
            when trim(class) = 'M' then 'Medium'
            when trim(class) = 'L' then 'Low'
            else 'Other'
        end as class
        , case 
            when trim(style) = 'M' then 'Mens'
            when trim(style) = 'W' then 'Womens'
            when trim(style) = 'U' then 'Universal'
            else 'Other'
        end as style
        , to_date(sellstartdate, 'MM/DD/YYYY') as sell_start_date
        , to_date(sellenddate, 'MM/DD/YYYY') as sell_end_date
        , to_date(discontinueddate, 'MM/DD/YYYY') as discontinued_date
        , current_timestamp() as updated_at
    from {{ source('source_db', 'product') }}
)

select *
from product