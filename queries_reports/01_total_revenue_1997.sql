SELECT SUM(order_value_wdisc)
FROM temp_table_orders_values
WHERE EXTRACT(YEAR FROM order_date) = 1997;