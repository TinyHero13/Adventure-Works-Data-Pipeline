{{
    config(
        re_data_monitored=true,
        re_data_time_filter='date_actual',
    )
}}

with 
    sales_date_range as (
        select 
            date_sub(min(order_date), 30) as start_date,
            date_add(max(order_date), 30) as end_date
        from {{ ref('int_sales') }}
    )

    , date_spine_base as (
        select explode(sequence(
            (select start_date from sales_date_range),
            (select end_date from sales_date_range),
            interval 1 day
        )) as date_day
    )

    , casting_fix as (
        select cast(date_day as date) as date_day
        from date_spine_base
    )

    , dates as (
        select
            {{
                dbt_utils.generate_surrogate_key(['date_day'])
            }} as date_sk
            , date_format(date_day, 'yyyyMMdd') as date_dim_id
            , date_day as date_actual
            , date_trunc('week', date_day) as reference_week
            , date_trunc('month', date_day) as reference_month
            , case 
                when dayofmonth(date_day) = 1 then '1st'
                when dayofmonth(date_day) = 2 then '2nd' 
                when dayofmonth(date_day) = 3 then '3rd'
                when dayofmonth(date_day) % 10 = 1 and dayofmonth(date_day) != 11 then concat(dayofmonth(date_day), 'st')
                when dayofmonth(date_day) % 10 = 2 and dayofmonth(date_day) != 12 then concat(dayofmonth(date_day), 'nd')
                when dayofmonth(date_day) % 10 = 3 and dayofmonth(date_day) != 13 then concat(dayofmonth(date_day), 'rd')
                else concat(dayofmonth(date_day), 'th')
            end as day_suffix
            , date_format(date_day, 'EEEE') as day_name
            , dayofweek(date_day) as day_of_week
            , dayofmonth(date_day) as day_of_month
            , datediff(date_day, date_trunc('quarter', date_day)) + 1 as day_of_quarter
            , dayofyear(date_day) as day_of_year
            , weekofyear(date_day) - weekofyear(date_trunc('month', date_day)) + 1 as week_of_month
            , weekofyear(date_day) as week_of_year
            , concat(year(date_day), '-W', lpad(weekofyear(date_day), 2, '0'), '-', dayofweek(date_day)) as week_of_year_iso
            , month(date_day) as month_actual
            , date_format(date_day, 'MMMM') as month_name
            , date_format(date_day, 'MMM') as month_name_abbreviated
            , quarter(date_day) as quarter_actual
            , case
                when quarter(date_day) = 1 then 'First'
                when quarter(date_day) = 2 then 'Second'
                when quarter(date_day) = 3 then 'Third'
                when quarter(date_day) = 4 then 'Fourth'
            end as quarter_name
            , year(date_day) as year_actual
            , date_sub(date_day, dayofweek(date_day) - 1) as first_day_of_week
            , date_add(date_day, 7 - dayofweek(date_day)) as last_day_of_week
            , date_trunc('month', date_day) as first_day_of_month
            , last_day(date_day) as last_day_of_month
            , date_trunc('quarter', date_day) as first_day_of_quarter
            , last_day(add_months(date_trunc('quarter', date_day), 2)) as last_day_of_quarter
            , date_trunc('year', date_day) as first_day_of_year
            , date(concat(year(date_day), '-12-31')) as last_day_of_year
            , date_format(date_day, 'MMyyyy') as mmyyyy
            , date_format(date_day, 'MMddyyyy') as mmddyyyy
            , dayofweek(date_day) in (1, 7) as is_weekend_day
        from casting_fix
        order by date_day desc
    )

select *
from dates
