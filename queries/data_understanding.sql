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
WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY 
	table_name,
	ordinal_position;

-- See the PKs and FKs
SELECT 
	kcu.table_name, 
	kcu.column_name,
	tc.constraint_type
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
	ON kcu.constraint_name = tc.constraint_name
	AND kcu.constraint_schema = tc.constraint_schema
WHERE 
	tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
	AND kcu.table_name IN ('orders', 'order_details', 'products', 'customers')
ORDER BY 
	kcu.table_name ASC,
	tc.constraint_type DESC;

-- List the child tables and columns
SELECT 
	ccu.table_name AS parent_table,
	ccu.column_name AS parent_column,
	kcu.table_name AS child_table,
	kcu.column_name AS child_column     
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
	ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
	ON ccu.constraint_name = tc.constraint_name
WHERE 
	tc.constraint_type = 'FOREIGN KEY'
	AND ccu.table_name IN ('orders', 'order_details', 'products', 'customers')
	AND kcu.table_name IN ('orders', 'order_details', 'products', 'customers')
ORDER BY kcu.table_name;