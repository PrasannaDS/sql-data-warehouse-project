
-- Performance Analysis -> Current Measure - Target Measure

-- Analyze the yearly performance of products by comparing each product's sales
-- to both its average sales performance and the previous year's sales


WITH yearly_product_sales AS (
    SELECT
        p.product_name,
        YEAR(f.order_date) AS order_year,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)

SELECT
product_name,
order_year,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS average_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_current_to_avg_sales,
CASE 
    WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
    WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
    WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) = 0 THEN 'Avg'
    ELSE 'n/a'
END avg_change,
-- Year-Over-Year Analysis
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE 
    WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
    WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
    ELSE 'No Change'
END py_change
FROM yearly_product_sales