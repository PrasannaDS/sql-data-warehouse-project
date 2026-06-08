
/*
=====================================================================================
Product Report
=====================================================================================
Purpose:
     - This report consolidates key Product metrics and behaviours

Highlights:
     1. Gathers essential fields such as productnames, category, subcategory, and cost details.
     2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
     3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
     4. Calculates valuable KPIs:
        - Recency (Months since last sale)
        - Average order revenue (AOR)
        - Average monthly revenue
=====================================================================================
*/
DROP VIEW IF EXISTS gold.report_products
GO

CREATE VIEW gold.report_products AS
/*-----------------------------------------------------------------------------
1) Base Query:  Retrieves core columns from tables
------------------------------------------------------------------------------*/

WITH base_query AS 
(   
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        f.customer_key,
        p.category,
        p.subcategory,
        p.product_name,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
)
, product_aggregations AS (
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity, 0)),1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Compute average order revenue (AOR) = total_sales/total_orders
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales/total_orders
    END AS avg_order_revenue,
    -- Compute average monthly revenue = total_sales/lifespan (in months)
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales/lifespan
    END AS avg_monthly_revenue 
FROM product_aggregations