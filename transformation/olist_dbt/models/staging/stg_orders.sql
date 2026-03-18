with source as (

    select *
    from {{ source('olist_raw', 'orders') }}

),

parsed as (

    select
        json_value(data, '$.order_id') as order_id,
        json_value(data, '$.customer_id') as customer_id,
        json_value(data, '$.order_status') as order_status,

        safe_cast(nullif(json_value(data, '$.order_purchase_timestamp'), '') as timestamp) as order_purchase_timestamp,
        safe_cast(nullif(json_value(data, '$.order_approved_at'), '') as timestamp) as order_approved_at,
        safe_cast(nullif(json_value(data, '$.order_delivered_carrier_date'), '') as timestamp) as order_delivered_carrier_date,
        safe_cast(nullif(json_value(data, '$.order_delivered_customer_date'), '') as timestamp) as order_delivered_customer_date,
        safe_cast(nullif(json_value(data, '$.order_estimated_delivery_date'), '') as timestamp) as order_estimated_delivery_date,

        _sdc_received_at

    from source

),

deduplicated as (

    select *
    from parsed
    qualify row_number() over (
        partition by order_id
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated
