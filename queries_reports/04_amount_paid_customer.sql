SELECT
	company_name,
	ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid
FROM temp_table_orders_values AS vov
JOIN customers AS c
	USING(customer_id)
GROUP BY company_name
ORDER BY
	amount_paid DESC,
	company_name