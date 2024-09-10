--------------------------------------------------------------------------
-- MODELLING
--------------------------------------------------------------------------

-- View with all the ids, order date and order value calculation
CREATE TEMP VIEW view_orders_values AS (
	SELECT
		o.order_date,
		o.customer_id,
		od.order_id,
		od.product_id,
		od.quantity,
		od.unit_price,
		od.quantity * od.unit_price AS order_value,
		od.quantity * od.unit_price * (1 - discount) AS order_value_wdisc
	FROM order_details AS od
	JOIN orders AS o
		USING(order_id)
)

--------------------------------------------------------------------------
-- BUSINESS QUESTIONS
--------------------------------------------------------------------------

-- 1.1 What was the total revenue in 1997.
SELECT SUM(order_value_wdisc)
FROM view_orders_values
WHERE EXTRACT(YEAR FROM order_date) = 1997;

-- 1.2 What was the monthly revenue growth in 1997, and what was the YTD (Year-To-Date) calculation?

-- 1.3 What was the top 10 best-selling products in terms of quantity and sales value?

-- 2.1 What is the total amount each customer has paid so far?
SELECT
	company_name,
	ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid
FROM view_orders_values AS vov
JOIN customers AS c
	USING(customer_id)
GROUP BY company_name
ORDER BY
	amount_paid DESC,
	company_name

-- 2.2 How can we segment customers into 5 groups based on the total amount paid?
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

-- 2.4 Which customers are in groups 3, 4 and 5 for targeted marketing campaigns?
SELECT
	company_name,
	customer_segmentation
FROM cte_customer_segmentation
WHERE customer_segmentation IN (3, 4, 5)
ORDER BY
	customer_segmentation,
	amount_paid DESC

-- 2.5 Which UK customers have paid more than $1000?
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