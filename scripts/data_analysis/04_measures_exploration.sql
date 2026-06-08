/*
=======================================================================
Measures Exploration
=======================================================================
Calculate the key metrics of the business (Big Numbers).
- Highest Level of Aggregation | Lowest Level of Details:

Syntax ==> SUM/AVG/COUNT [DIMENSION]
  - Find The Total Sales 
  - Find how many items are sold 
  - Find the average selling price
  - Find the total number of Orders
  - Find the total number of products
  - Find the total number of customers
  - Find the total number of customers that has placed an order
  - Generate a Report that shows all key metrics of the business
=======================================================================
*/
-- Find The Total Sales 
SELECT 
SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Find how many items are sold 
SELECT
SUM(quantity) AS items_sold
FROM gold.fact_sales;

-- Find the average selling price
SELECT
AVG(price) AS avg_selling_price
FROM gold.fact_sales;

-- Find the total number of Orders
SELECT
COUNT(DISTINCT order_number) AS total_no_of_orders
FROM gold.fact_sales;

-- Find the total number of products
SELECT
COUNT(product_key) AS total_no_of_products
FROM gold.dim_products;
SELECT
COUNT(DISTINCT product_key) AS total_no_of_products
FROM gold.dim_products;

-- Find the total number of customers
SELECT
COUNT(customer_key) AS total_no_of_customers
FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT
COUNT(DISTINCT customer_key) AS total_customers_ordered
FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Ordered Customers' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales
