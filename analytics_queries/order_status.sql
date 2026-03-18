SELECT
    order_status,
    COUNT(*) AS orders
FROM `m2p-02525.olist_analytics.fct_orders`
GROUP BY order_status
