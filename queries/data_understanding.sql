-- Find the tables in the schema
SELECT table_name
FROM information_schema.tables
WHERE 
	table_schema NOT IN ('information_schema', 'pg_catalog')
	AND table_type = 'BASE TABLE'
ORDER BY
	table_schema,
	table_name;

-- Check the column types for the tables of interest
SELECT 
	table_name,
	column_name,
	data_type,
	is_nullable,
	column_default
FROM information_schema.columns
WHERE 
	table_schema NOT IN ('information_schema', 'pg_catalog')
	AND table_name IN ('orders', 'order_details', 'products', 'customers')
ORDER BY 
	table_name,
	ordinal_position;