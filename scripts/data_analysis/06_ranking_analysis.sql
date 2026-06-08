/*
==============================================================================================
Ranking Analysis
==============================================================================================
Also called Top N - Bottom N Analysis;
    - Order the values of dimensions by measure.
    - Top N Performers | Bottom N Performers
    
Syntax ==> RANK[DIMENSION] By SUM/COUNT/AVG[MEASURE]
           Functions used - RANK(), DENSE_RANK(), ROW_NUMBER()

  - Which 5 products generate the highest revenue without using window function? 
  - Which 5 products generate the highest revenue using window function? 
  - Find the top 5 subcategories that generate highest revenue.
  - What are the 5 worst-performing products in-terms of sales without using window function?
  - What are the 5 worst-performing products in-terms of sales using window function?
  - Find the top 5 subcategories that shows worst-performance.
  - Find the top 10 customers who have generated the highest revenue
  - Find the 3 customers with fewest orders placed
==============================================================================================
*/
-- Which 5 products generate the highest revenue?

SELECT TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- Using window function
SELECT TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue,
ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name

-- For subcategory
SELECT TOP 5
p.subcategory,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC

-- What are the 5 worst-performing products in-terms of sales?

SELECT TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue

-- Using window function
SELECT TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue,
ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount)) AS rank_products
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name

-- For subcategory
SELECT TOP 5
p.subcategory,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY total_revenue

-- Find the top 10 customers who have generated the highest revenue

SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
            c.first_name,
            c.last_name
ORDER BY total_revenue DESC

-- Find the 3 customers with fewest orders placed

SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
            c.first_name,
            c.last_name
ORDER BY total_orders
