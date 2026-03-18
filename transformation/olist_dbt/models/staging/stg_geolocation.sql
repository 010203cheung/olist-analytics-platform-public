with source as (

    select *
    from {{ source('olist_raw', 'geolocation') }}

),

parsed as (

    select
        cast(json_value(data, '$.geolocation_zip_code_prefix') as int64) as geolocation_zip_code_prefix,
        cast(json_value(data, '$.geolocation_lat') as float64) as geolocation_lat,
        cast(json_value(data, '$.geolocation_lng') as float64) as geolocation_lng,
        json_value(data, '$.geolocation_city') as geolocation_city,
        json_value(data, '$.geolocation_state') as geolocation_state,

        _sdc_received_at

    from source

)

select *
from parsed
