with source as (

    select *
    from {{ source('olist_raw', 'customers') }}

),

parsed as (

    select
        json_value(data, '$.customer_id') as customer_id,
        json_value(data, '$.customer_unique_id') as customer_unique_id,
        cast(json_value(data, '$.customer_zip_code_prefix') as int64) as customer_zip_code_prefix,
        json_value(data, '$.customer_city') as customer_city,
        json_value(data, '$.customer_state') as customer_state,

        _sdc_received_at

    from source

),

deduplicated as (

    select *
    from parsed
    qualify row_number() over (
        partition by customer_id
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated