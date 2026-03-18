with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

orders as (

    select *
    from {{ ref('stg_orders') }}

)

select
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    o.customer_id,
    o.order_status,

    o.order_purchase_timestamp,
    date(o.order_purchase_timestamp) as order_purchase_date,
    format_date('%Y%m%d', date(o.order_purchase_timestamp)) as order_date_id,

    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.shipping_limit_date,

    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value as gross_item_value

from order_items oi
left join orders o
    on oi.order_id = o.order_id
