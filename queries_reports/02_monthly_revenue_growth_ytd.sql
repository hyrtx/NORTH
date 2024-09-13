-- The cte_1 filter the most recent year and its max month
WITH cte_1 AS (
	SELECT
		EXTRACT(YEAR FROM order_date) AS year,
		MAX(EXTRACT(MONTH FROM order_date)) AS max_month
	FROM temp_table_orders_values
	GROUP BY EXTRACT(YEAR FROM order_date)
	ORDER BY year DESC
	LIMIT 1
),

-- The cte_2 groups sales by year and month and converts the monthly_sales type to numeric, so we can round up later
cte_2 AS (
	SELECT
		EXTRACT(YEAR FROM order_date) AS year,
		EXTRACT(MONTH FROM order_date) AS month,
		SUM(order_value_wdisc)::numeric as monthly_sales
	FROM temp_table_orders_values
	GROUP BY
		year,
		month
	ORDER BY
		year,
		month
),

-- The cte_3 filters the results by the years that have the same months as the recent year,
-- and creates the measure with the last month's sales to make comparisons.
cte_3 AS (
	SELECT
		cte_2.year,
		cte_2.month,
		cte_2.monthly_sales,
		LAG(cte_2.monthly_sales, 1) OVER (PARTITION BY cte_2.year ORDER BY cte_2.month) AS last_month_sales
	FROM cte_2
	JOIN cte_1
		ON cte_2.month <= cte_1.max_month
)

SELECT
	year,
	month,
	ROUND(monthly_sales, 2) AS monthly_sales,
	ROUND(SUM(monthly_sales) OVER (PARTITION BY year ORDER BY month), 2) AS ytd_sales,
	ROUND(monthly_sales - last_month_sales, 2) AS variation_abs,
	ROUND((monthly_sales / last_month_sales - 1) * 100, 2) AS variation_perc
FROM cte_3
ORDER BY
	year DESC,
	month