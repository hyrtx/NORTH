# Using SQL to Create Northwind Traders Data Reports
## Business Understading

![Andy Lee Trader Image Unsplash](assets/andy-li-trader-unsplash.jpg)
*Photo by Andy Lee on [Unsplash](https://unsplash.com).*

### Project Objectives
The purpose of this project is to demonstrate the use of SQL to generate reports that address key business questions for Northwind Traders, a fictitious company. 

By leveraging SQL queries, valuable insights are extracted to assist with revenue tracking, customer segmentation, and sales optimization. The focus is on creating structured reports that support strategic decision-making, highlighting the essential role of SQL in solving business problems and efficiently organizing data.


The main objective of this project is to **create sales reports that answer the business questions of the fictitious company Northwind Traders using SQL queries**. The aim is to extract valuable information that can support strategic business decisions.

This analysis will follow an adaptation of the **CRISP-DM methodology** to ensure a structured and effective approach.

### Business Questions
The project will address the following specific questions:

1. **Revenue Reports**
    - What was the **total revenue in 1997?**
    - What was the **monthly revenue growth** in 1997, and what was the **YTD (Year-To-Date) calculation?**
    - What was the **top 10 best-selling products** in terms of sales value?
2. **Customer Segmentation**
    - What is the **total amount each customer has paid** so far?
    - How can we **segment customers into 5 groups** based on the total amount paid?
    - Which customers are in **groups 3, 4 and 5** for targeted marketing campaigns?
    - Which **UK customers** have paid **more than $1000?**

### Expected Benefits
- **Enhanced Market Understanding**: Gain insights into which products perform best and which customers contribute the most to total revenue.
- **Targeted Marketing Strategies**: Identify customer segments for personalized offers and increased retention.
- **Sales Optimization**: Detect growth patterns and seasonality for strategic planning.
- **Support for Decision-Making**: Provide concrete data to support management and operational decisions.

## Data Understanding
This stage involves getting to know the data, such as:
- Explaining how the data was loaded.
- Inspecting the names of the tables and columns, the primary and foreign keys.
- Understanding the relationships between the tables and the types of data in each table.

### Extraction And Loading
The tables were created in a local **PostgreSQL** database using an SQL Script used to replicate the Northwind Traders tables.

The connection to the database was made via a DBMS (pgAdmin 4).

### Dataset Description
The **Northwind Traders database** is a sample dataset simulating the operations of a food import and export company. The database covers various operational and commercial aspects of the company, including:

- **Suppliers**: Information about suppliers and vendors.
- **Customers**: Data on customers who make purchases from Northwind.
- **Employees**: Details about the company's employees.
- **Products**: Detailed information on the products sold.
- **Shippers**: Details about the companies responsible for shipping the products.
- **Orders and Order Details**: Records of sales transactions between customers and the company.

The database consists of **14 tables**, which are interrelated to provide a comprehensive view of business operations.

![Northwind Traders Tables Schema](assets/northwind-er-diagram.png)

### Data Inspection
Not all the data we have available in the Data Repository is important to the problem. At this stage, we check the tables, select the variables that are relevant to answer the business questions and understand the relationship between the tables that will be used in the analysis.

#### Selecting The Variables
We already have access to the database schema, but if we needed to see all the tables, we could list them using the following query:

```sql
SELECT table_name
FROM information_schema.tables
WHERE 
	table_schema NOT IN ('information_schema', 'pg_catalog')
	AND table_type = 'BASE TABLE'
ORDER BY
	table_schema,
	table_name;
```

Let's also check which columns are in each table of interest through the query:

```sql
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
```

By inspecting the tables and its columns, we can define the tables that we will use in the analysis:

1. **orders**
2. **order_details**
3. **products**
4. **customers**

#### Checking the Tables That Accepts `NULL` Values

The `is_nullable` column allows us to check which variables accept `NULL` values. From this, we were able to generate some valuable information about the tables of interest:

- **orders**
    - With the exception of `order_id`, all the other columns are nullable. This is dangerous, because it means that we can have an order without any information other than the id.
- **order_details**
    - There is no column that accepts `NULL` values in the table. 
- **products**
    - Neither `product_id` nor `product-name` accept `NULL` values.
    - The `unit_price` column can have `NULL` values, which is strange since this type of information it's usually mandatory.
- **customers**
    - All the columns except for `customer_id` and `company_name` accept `NULL` values.
    - Since the `country` column accepts `NULL` values, we have to be cautious because one of the business questions involves a geographical filter.

#### Checking The Relationship Between The Tables
To finish our data inspection, let's see how the tables work together. To do this, let's find find their **primary keys (PKs)** and **foreign keys (FKs)**.

```sql
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
```

All the tables have one PK and at least one FK. 

The table `order_details` has two columns with the PK constraint: `order_id` and `product_id`. This means that, the table has a **composite primary key**, which indicates that the unique identifier of the data is the **unique combination of two columns**.

In addition, the same primary keys in the `order_details` table are also foreign keys for the same table.

Finally, let's list all the parent and child tables and columns to check the shared column between the tables.

```sql
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
```

From the output, we check that:
- The `order_details` table is directly connected to both `orders` and `products` tables via the `order_id` and `product_id`, respectively.
- The `customers` table is connected to `orders` through the `customer_id`.

### Data Quality
Before proceeding with the analysis, an assessment of data quality will be conducted to identify and address potential issues.

#### Dealing With Duplicated Records
Let's identify possible duplicated records and deal with them if necessary.

```sql
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
```

During the inspection, no duplicated records were found.

## Exploratory Analysis
### Number of Records
Let's count the number of customers and products we have in the tables.

```sql
-- Number of customers
SELECT COUNT(*)
FROM customers;

-- Number of products
SELECT COUNT(*)
FROM products;
```

We have 91 customers and 77 products in the `customers` and `products` tables.

In the `products` table, we have products marked as inactive. Let's check how many active products we have.

```sql
SELECT COUNT(*)
FROM products
WHERE discontinued = 0;
```

**69 of 77 products are active**. Now let's check the number of orders.

```sql
-- Number of orders
SELECT COUNT(*)
FROM orders;

-- Number of records in order_details
SELECT COUNT(*)
FROM order_details;
```

The table `orders` has 830 and the `order_details` has 2155 records. Let's check if we have the same amount of **distinct orders** in the `order_details` table.

```sql
SELECT COUNT(DISTINCT order_id)
FROM order_details;
```

The `order_details` table has 830, the same amount of records of the `orders` table. 

### Minimum and Maximum Values
Let's check the the minimum and maximum values for the columns we're interested in, which will be used in the analysis.

```sql
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
```

The date range for which we have orders is **1996-07 to 1998-05**. Also, **the biggest order value is $15,810**  and we have orders with **quantities of 2 units to 263.5 units**.

Besides that, the **maximium unit_price in the orders is $263.5**.

### Aggregating Values
Finally, we will use aggregation functions on the orders value.

First, let's group the order values by `order_id` with a **temporary view**. 

This is necessary because the `order_values` table has `order_id` and `product_id` as primary keys.  **If we tried to calculate without grouping the orders first, the average would have an incorrect output.**

```sql
CREATE TEMP VIEW tempview_grouped_order_values AS (
	SELECT
		order_id,
		SUM(quantity * unit_price) AS order_value
	FROM order_details
	GROUP BY order_id
)
```

Now we can use some aggregation measures in the `order_value` to extract some insights:

```sql
SELECT
	ROUND(SUM(order_value)::numeric, 2) AS sum_order_value,
	ROUND(AVG(order_value)::numeric, 2) AS avg_order_value
FROM cte;
```

The total value of orders are $1.35M, and the average order value is $1.6K. 

And what is the value of these measurements with the discount applied? Let's see:

```sql
SELECT
	ROUND(SUM(order_value_wdisc)::numeric, 2) AS sum_order_value_wdisc,
	ROUND(AVG(order_value_wdisc)::numeric, 2) AS avg_order_value_wdisc
FROM tempview_grouped_order_values;
```

With the discounts applied, the total value of the orders is $1.26M, $88K less than the value of the orders without the discounts. The average order value with discounts is $1.52K.

## Development
This stage involves the development of structured SQL queries to extract and analyze the data according to the defined needs. The approach will include:

- **Model data by creating views**: This will reduce the time it takes to write queries by not having to join several tables and write calculations in several queries.
- **Breaking Down Questions into Sub-Queries**: Decomposing the questions into smaller, more manageable parts.

### Modelling
Before writing the queries to answer the business questions, let's create a temporary view with all the IDs involved in the order, the date of the order, the indicators and the calculation of the order value.

This is important to avoid spending time calculating the value order in several queries during the analysis.

```sql
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
```

### Reports
Now, let's address the business questions using SQL queries to create reports that answer them.

#### Total Revenue in 1997.
```sql
SELECT SUM(tod.order_value)
FROM temp_order_details AS tod
LEFT JOIN orders AS o
	USING(order_id)
WHERE EXTRACT(YEAR FROM o.order_date) = 1997;
```

#### Monthly revenue growth in 1997 and YTD.
```sql
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
```

#### Top 10 best-selling products in terms of sales value
```sql
SELECT 
	product_name,
	RANK() OVER (ORDER BY SUM(order_value) DESC) AS ranking,
	ROUND(SUM(order_value)::numeric, 2) AS sales_value
FROM temp_table_orders_values
JOIN products
	USING(product_id)
GROUP BY product_name
LIMIT 10;
```

### Customer Segmentation
#### Total amount each customer has paid so far
```sql
SELECT
	company_name,
	ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid
FROM temp_table_orders_values AS vov
JOIN customers AS c
	USING(customer_id)
GROUP BY company_name
ORDER BY
	amount_paid DESC,
	company_name
```

#### Segmenting customers into 5 groups based on the total amount paid
```sql
SELECT
    company_name,
    ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid,
    NTILE(5) OVER (ORDER BY SUM(order_value_wdisc) DESC) AS customer_segmentation
FROM temp_table_orders_values AS vov
JOIN customers
    USING(customer_id)
GROUP BY company_name
```

#### Customers in group 3, 4 and 5
```sql
-- CTE made for segment the customers into 5 groups by amount paid
WITH cte AS (
	SELECT
		company_name,
		ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid,
		NTILE(5) OVER (ORDER BY SUM(order_value_wdisc) DESC) AS customer_segmentation
	FROM temp_table_orders_values AS vov
	JOIN customers
		USING(customer_id)
	GROUP BY company_name
)

SELECT
	company_name,
	customer_segmentation
FROM cte
WHERE customer_segmentation IN (3, 4, 5)
ORDER BY
	customer_segmentation,
	amount_paid DESC
```

#### UK Customers who have paid more than $1,000
```sql
SELECT
	company_name,
	ROUND(SUM(order_value_wdisc)::numeric, 2) AS amount_paid,
	RANK() OVER (ORDER BY SUM(order_value_wdisc) DESC) AS ranking
FROM temp_table_orders_values AS vov
JOIN customers AS c
	USING(customer_id)
WHERE country = 'UK'
GROUP BY company_name
HAVING SUM(order_value_wdisc) > 1000;
```

## Concluding Remarks
In this project, I successfully created SQL queries that addressed critical business questions for Northwind Traders. The reports generated offer valuable insights into the company's revenue patterns, customer segmentation, and top-selling products. 

By structuring the database queries efficiently and modeling the data appropriately, the project highlights the importance of clear, actionable reports in supporting business decisions. While no additional data analysis was performed beyond the report creation, the project illustrates how well-constructed SQL queries can provide a foundation for decision-making and strategic planning.

## Replicate The Project
### Manually
Use the SQL file provided, `nortwhind.sql`, to populate your database.

### With Docker and Docker Compose
**Prerequisite**: Install Docker and Docker Compose.

* [Get Started With Docker](https://www.docker.com/get-started)
* [Install Docker Compose](https://docs.docker.com/compose/install/)

#### Installing
1. **Start Docker Compose**: run the command to upload the services:
```
docker-compose up
```

Wait for configuration messages, like:
```
Creating network "northwind_psql_db" with driver "bridge"
Creating volume "northwind_psql_db" with default driver
Creating volume "northwind_psql_pgadmin" with default driver
Creating pgadmin ... done
Creating db      ... done
```

2. **Connect PgAdmin**: Access PgAdmin via the URL [http://localhost:5050](http://localhost:5050), with the password `postgres`.

Set up a new server in PgAdmin:
* **General tab**:
	* Name: db
* **Connection tab**
	* Host name: db
	* User name: postgres
	* Password: postgres

Next, select the `northwind` database.

3. **Stopping Docker Compose**: stop the server started by `docker-compose up` using Ctrl-C and remove the containers with:
```
docker-compose down
```

4. **Files and Persistence**: Your modifications to the Postgres databases will be persisted on Docker volume postgresql_data and can be recovered by restarting Docker Compose with `docker-compose up`. To delete the data from the database, run:
```
docker-compose down -v
```

## References
1. [Luciano Galvão](https://github.com/lvgalvao), Instructor of the course *Jornada de Dados* - Provided the inspiration for the project.
2. Andy Lee on [Unsplash](https://unsplash.com) - Photo used in the project