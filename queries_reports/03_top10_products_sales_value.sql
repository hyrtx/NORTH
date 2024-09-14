SELECT 
	product_name,
	RANK() OVER (ORDER BY SUM(order_value) DESC) AS ranking,
	ROUND(SUM(order_value)::numeric, 2) AS sales_value
FROM temp_table_orders_values
JOIN products
	USING(product_id)
GROUP BY product_name
LIMIT 10;