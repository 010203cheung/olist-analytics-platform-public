with source as (

    select *
    from {{ source('olist_raw', 'order_payments') }}

),

parsed as (

    select
        json_value(data, '$.order_id') as order_id,
        cast(json_value(data, '$.payment_sequential') as int64) as payment_sequential,
        json_value(data, '$.payment_type') as payment_type,
        cast(json_value(data, '$.payment_installments') as int64) as payment_installments,
        cast(json_value(data, '$.payment_value') as numeric) as payment_value,

        _sdc_received_at

    from source

),

deduplicated as (

    select *
    from parsed
    qualify row_number() over (
        partition by order_id, payment_sequential
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated
