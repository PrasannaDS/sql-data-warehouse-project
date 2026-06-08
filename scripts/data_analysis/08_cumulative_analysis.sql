/*
==============================================================================================
Cumulative Analysis
==============================================================================================
Aggregate the data progressively over time. Helps to understand whether our business is 
growing or declining.

Syntax ==> [CUMULATIVE MEASURE] By [DATE DIMENSION] e.g: Running Total Sales By Year

Default Window Frame:
 BETWEEN UNBOUNDED PRECEEDING AND CURRENT ROW

  - Calculate the total sales per month. And calculate the running total of sales over time
  - Calculate Running sales total over year
  - Calculate the moving average of price over years
==============================================================================================
*/
 -- Calculate the total sales per month. And calculate the running total of sales over time
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_sales -- Default frame -> ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
FROM(
    SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t 

 -- Running sales total over year

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_sales -- Default frame -> ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
FROM(
    SELECT
    DATETRUNC(year, order_date) AS order_date,
    SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t 

-- Calculate the moving average of price over years

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_sales, -- Default frame -> ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
avg_price,
AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price,
STDEV(avg_price) OVER(ORDER BY order_date) AS standard_deviation_sales
FROM(
    SELECT
    DATETRUNC(year, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t 
