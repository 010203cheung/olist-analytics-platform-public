SELECT
    p.product_category_name_english,
    SUM(f.price) AS revenue
FROM `m2p-02525.olist_analytics.fct_order_items` f
JOIN `m2p-02525.olist_analytics.dim_products` p
ON f.product_id = p.product_id
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10
