with source as (

    select *
    from {{ source('olist_raw', 'product_category_translation') }}

),

parsed as (

    select
        json_value(data, '$.﻿product_category_name') as product_category_name,
        json_value(data, '$.product_category_name_english') as product_category_name_english,
        _sdc_received_at
    from source

),

filtered as (

    select *
    from parsed
    where product_category_name is not null

),

deduplicated as (

    select *
    from filtered
    qualify row_number() over (
        partition by product_category_name
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated