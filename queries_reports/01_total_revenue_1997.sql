SELECT SUM(order_value_wdisc)
FROM view_orders_values
WHERE EXTRACT(YEAR FROM order_date) = 1997;