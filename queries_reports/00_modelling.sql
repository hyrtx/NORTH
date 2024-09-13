-- Temporary Table with all the ids, order date and order value calculation
CREATE TEMP TABLE temp_table_orders_values AS (
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
);