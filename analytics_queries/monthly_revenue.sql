SELECT
    DATE_TRUNC(order_purchase_timestamp, MONTH) AS month,
    SUM(price) AS revenue
FROM `m2p-02525.olist_analytics.fct_order_items`
GROUP BY 1
ORDER BY 1
