/*
==============================================================================================
Part-to-Whole / Proportional Analysis
==============================================================================================
Analyze how an individual part is performing compared to the overall, allowing us to
understand which category has the greatest impact on the business.

Syntax ==> {([MEASURE] / Total [MEASURE])* 100} By [DIMENSION] 
        e.g: {(Sales/Total Sales)*100} By Category

  - Which categories contribute the most to overall sales
==============================================================================================
*/

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
