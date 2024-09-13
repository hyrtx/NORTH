SELECT
    company_name,
    ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid,
    NTILE(5) OVER (ORDER BY SUM(order_value_wdisc) DESC) AS customer_segmentation
FROM temp_table_orders_values AS vov
JOIN customers
    USING(customer_id)
GROUP BY company_name