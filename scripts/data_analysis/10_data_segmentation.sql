-- Data Segmentation -> Measure by Measure

-- Segment products into cost ranges and count how many products fall into each segment

WITH product_segments AS(
    SELECT
    product_key,
    product_name,
    cost,
    CASE
        WHEN cost < 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 499 THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
    END AS cost_range
    FROM gold.dim_products
)
SELECT DISTINCT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/*
Group Customers into three segments based on their spending behaviour:
    - VIP: at least 12 months of history and spending more than $5000
    - Regular: at least 12 months of history and spending $5000 or less
    - New: lifespan less than 12 months
And find the total number of customers by each group.
*/

WITH customer_spending_categories AS(
    SELECT
    c.customer_key,
    SUM(f.sales_amount) AS total_spending,
    DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
customer_category,
COUNT(customer_key) AS total_customers 
FROM (
    SELECT
    CASE
        WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_category,
    customer_key
    FROM customer_spending_categories) t
GROUP BY customer_category
ORDER BY total_customers DESC