with source as (

    select *
    from {{ source('olist_raw', 'sellers') }}

),

parsed as (

    select
        json_value(data, '$.seller_id') as seller_id,
        cast(json_value(data, '$.seller_zip_code_prefix') as int64) as seller_zip_code_prefix,
        json_value(data, '$.seller_city') as seller_city,
        json_value(data, '$.seller_state') as seller_state,

        _sdc_received_at

    from source

),

deduplicated as (

    select *
    from parsed
    qualify row_number() over (
        partition by seller_id
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated