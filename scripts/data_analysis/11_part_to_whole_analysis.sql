-- Part-to-Whole Proportional Analysis -> (Measure/Total Measure)*100 BY Dimension

-- Which categories contribute the most to overall sales

SELECT 
category,
total_sales,
SUM(total_sales) OVER() overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER())*100,2),'%')AS percentage_of_total_sales
FROM (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    GROUP BY p.category) t
ORDER BY total_sales DESC;
