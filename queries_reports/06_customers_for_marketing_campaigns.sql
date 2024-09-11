WITH cte_customer_segmentation AS (
	SELECT
		company_name,
		ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid,
		NTILE(5) OVER (ORDER BY SUM(order_value_wdisc) DESC) AS customer_segmentation
	FROM view_orders_values AS vov
	JOIN customers
		USING(customer_id)
	GROUP BY company_name
)

SELECT
	company_name,
	customer_segmentation
FROM cte_customer_segmentation
WHERE customer_segmentation IN (3, 4, 5)
ORDER BY
	customer_segmentation,
	amount_paid DESC