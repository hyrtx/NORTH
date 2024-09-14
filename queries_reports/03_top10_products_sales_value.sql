SELECT 
	product_name,
	ROUND(SUM(order_value)::numeric, 2) AS sales_value
FROM temp_table_orders_values
JOIN products
	USING(product_id)
GROUP BY product_name
ORDER BY sales_value DESC
LIMIT 10;