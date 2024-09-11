--------------------------------------------------------------------------
-- NUMBER OF RECORDS
--------------------------------------------------------------------------

-- Number of customers
SELECT COUNT(*)
FROM customers;

-- Number of products
SELECT COUNT(*)
FROM products;

-- Number of orders
SELECT COUNT(*)
FROM orders;

-- Number of records in order_details
SELECT COUNT(*)
FROM order_details;

-- Number of orders in order_details
SELECT COUNT(DISTINCT order_id)
FROM order_details;

--------------------------------------------------------------------------
-- MINIMUM AND MAXIMUM VALUES
--------------------------------------------------------------------------

SELECT *
FROM order_details
LIMIT 10;

-- Min and Max Orders Date
SELECT
	MIN(order_date) AS min_order_date,
	MAX(order_date) AS max_order_date
FROM orders;

-- Min and Max Quantity of Products Sold
SELECT
	MIN(quantity) AS min_quantity,
	MAX(quantity) AS max_quantity
FROM order_details;

-- Min and Max Unit Price of Products Sold
SELECT
	MIN(unit_price) AS min_unit_price,
	MAX(unit_price) AS max_unit_price
FROM order_details;

-- Min and Max Order Values
SELECT
	ROUND(MIN(quantity * unit_price)::numeric, 1) AS min_order_value,
	ROUND(MAX(quantity * unit_price)::numeric, 1) AS max_order_value
FROM order_details;

--------------------------------------------------------------------------
-- AGGREGATING VALUES
--------------------------------------------------------------------------

-- Temp View to group the orders values by order_id
CREATE TEMP VIEW tempview_grouped_order_values AS (
	SELECT
		order_id,
		SUM(quantity * unit_price) AS order_value,
		SUM(quantity * unit_price * (1- discount)) AS order_value_wdisc
	FROM order_details
	GROUP BY order_id
)

-- Sum and Average of the orders values
SELECT
	ROUND(SUM(order_value)::numeric, 2) AS sum_order_value,
	ROUND(AVG(order_value)::numeric, 2) AS avg_order_value
FROM tempview_grouped_order_values;

-- Sum and Average of the orders values with discounts applied
SELECT
	ROUND(SUM(order_value_wdisc)::numeric, 2) AS sum_order_value_wdisc,
	ROUND(AVG(order_value_wdisc)::numeric, 2) AS avg_order_value_wdisc
FROM tempview_grouped_order_values;