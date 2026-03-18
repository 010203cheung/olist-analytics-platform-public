with order_dates as (

    select distinct
        date(order_purchase_timestamp) as date_day
    from {{ ref('stg_orders') }}
    where order_purchase_timestamp is not null

)

select
    format_date('%Y%m%d', date_day) as date_id,
    date_day,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    format_date('%B', date_day) as month_name,
    extract(day from date_day) as day_of_month,
    extract(dayofweek from date_day) as day_of_week,
    format_date('%A', date_day) as day_name,
    extract(week from date_day) as week_of_year
from order_dates
