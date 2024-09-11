SELECT
	company_name,
	ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid,
	RANK() OVER (ORDER BY SUM(order_value_wdisc) DESC) AS ranking
FROM view_orders_values AS vov
JOIN customers AS c
	USING(customer_id)
WHERE country = 'UK'
GROUP BY company_name
HAVING SUM(order_value_wdisc) > 1000;