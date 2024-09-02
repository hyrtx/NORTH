# Using SQL to Analyze Northwind Traders Data

## Business Understading

![Andy Lee Trader Image Unsplash](assets/andy-li-trader-unsplash.jpg)

### Project Objectives
The main objective of this project is to **carry out an comprehensive analysis of the sales data of the fictitious company Northwind Traders using SQL queries**. The aim is to extract valuable information that can support strategic business decisions.

This analysis will follow the **CRISP-DM methodology** to ensure a structured and effective approach.

### Business Questions
The analysis will address the following specific questions:

1. **Revenue Reports**
    - What was the **total revenue in 1997?**
    - What was the **monthly revenue growth** in 1997, and what was the **YTD (Year-To-Date) calculation**?
    - What was the **top 10 best-selling products** in terms of quantity and sales value?
2. **Customer Segmentation**
    - What is the **total amount each customer has paid** so far?
    - How can we **segment customers into 5 groups** based on the total amount paid?
    - Which customers are in **groups 3, 4 and 5** for targeted marketing campaigns?
    - Which **UK customers** have paid **more than $1000**?

### Expected Benefits
- **Enhanced Market Understanding**: Gain insights into which products perform best and which customers contribute the most to total revenue.
- **Targeted Marketing Strategies**: Identify customer segments for personalized offers and increased retention.
- **Sales Optimization**: Detect growth patterns and seasonality for strategic planning.
- **Support for Decision-Making**: Provide concrete data to support management and operational decisions.

## Data Understanding
This stage involves getting to know the data, such as the tables and column names, primary and foreign keys, relationships between tables and the data types in each table.

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

### Table Structure
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

#### Identifying and eliminating possible duplicate records

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

#### Checking for for fields with missing or incomplete information.



#### Standardize the data

## Data Preparation
### Data Extraction and Loading
### Data Cleaning
### Data Transformation and Integration
## Modeling
### SQL Query Strategies
### Query Details
## Evaluation
### Result Validation
### Insights Analysis
## Deployment
### Presentation of Results
### Business Recomendations
## Conclusion
## Appendices
