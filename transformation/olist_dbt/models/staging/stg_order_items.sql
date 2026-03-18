with source as (

    select *
    from {{ source('olist_raw', 'order_items') }}

),

parsed as (

    select
        json_value(data, '$.order_id') as order_id,
        cast(json_value(data, '$.order_item_id') as int64) as order_item_id,
        json_value(data, '$.product_id') as product_id,
        json_value(data, '$.seller_id') as seller_id,
        cast(json_value(data, '$.shipping_limit_date') as timestamp) as shipping_limit_date,
        cast(json_value(data, '$.price') as numeric) as price,
        cast(json_value(data, '$.freight_value') as numeric) as freight_value,

        _sdc_received_at

    from source

),

deduplicated as (

    select *
    from parsed
    qualify row_number() over (
        partition by order_id, order_item_id
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated
