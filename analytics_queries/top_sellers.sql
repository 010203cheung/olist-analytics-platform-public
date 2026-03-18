SELECT
    seller_id,
    SUM(price) AS revenue
FROM `m2p-02525.olist_analytics.fct_order_items`
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10
