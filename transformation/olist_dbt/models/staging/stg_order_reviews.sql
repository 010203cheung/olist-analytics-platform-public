with source as (

    select *
    from {{ source('olist_raw', 'order_reviews') }}

),

parsed as (

    select
        json_value(data, '$.review_id') as review_id,
        json_value(data, '$.order_id') as order_id,
        cast(json_value(data, '$.review_score') as int64) as review_score,
        json_value(data, '$.review_comment_title') as review_comment_title,
        json_value(data, '$.review_comment_message') as review_comment_message,
        cast(json_value(data, '$.review_creation_date') as timestamp) as review_creation_date,
        cast(json_value(data, '$.review_answer_timestamp') as timestamp) as review_answer_timestamp,

        _sdc_received_at

    from source

),

deduplicated as (

    select *
    from parsed
    qualify row_number() over (
        partition by review_id
        order by _sdc_received_at desc
    ) = 1

)

select *
from deduplicated
