-- Checking duplicates (orders)
SELECT 
	order_id,
	COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Checking duplicates (order_details)
SELECT
	order_id,
	product_id,
	COUNT(*) AS occurrences
FROM order_details
GROUP BY
	order_id,
	product_id
HAVING COUNT(*) > 1;

-- Checking duplicates (products)
SELECT
	product_id,
	COUNT(*) AS occurrences
FROM products
GROUP BY
	product_id
HAVING COUNT(*) > 1;

-- Checking duplicates (customers)
SELECT 
	customer_id,
	COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Checking NULL values (products)
SELECT
	product_id,
	product_name
FROM products
WHERE
	product_name IS NULL
	OR product_name = '';