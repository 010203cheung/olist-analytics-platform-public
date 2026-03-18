with source as (

    select *
    from {{ source('olist_raw', 'products') }}

),

parsed as (

    select
        json_value(data, '$.product_id') as product_id,
        json_value(data, '$.product_category_name') as product_category_name,

        safe_cast(nullif(json_value(data, '$.product_name_lenght'), '') as int64) as product_name_length,
        safe_cast(nullif(json_value(data, '$.product_description_lenght'), '') as int64) as product_description_length,
        safe_cast(nullif(json_value(data, '$.product_photos_qty'), '') as int64) as product_photos_qty,
        safe_cast(nullif(json_value(data, '$.product_weight_g'), '') as int64) as product_weight_g,
        safe_cast(nullif(json_value(data, '$.product_length_cm'), '') as int64) as product_length_cm,
        safe_cast(nullif(json_value(data, '$.product_height_cm'), '') as int64) as product_height_cm,
        safe_cast(nullif(json_value(data, '$.product_width_cm'), '') as int64) as product_width_cm,

        _sdc_received_at

    from source

),

deduplicated as (

    select *
    from parsed
    qualify row_number() over (
        partition by product_id
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated