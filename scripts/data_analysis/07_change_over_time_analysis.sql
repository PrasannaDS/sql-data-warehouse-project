/*
==============================================================================================
Change-Over-Time Analysis
==============================================================================================
"Answers Business Questions" : Using Complex Queries, Window Functions, CTE, Subquery, 
and Reports. Analyze how a measure evolves over the time. Helps track the trends and identify 
seasonality in the data.

Syntax ==> SUM/COUNT/AVG[MEASURE] By [DATE DIMENSION]

  - Analyze Sales Performance Over Time(Month By Month)
  - Analyze Sales Performance Over Time(Year By Year)
  - Analyze Sales Performance Over Time(Different Date format)
==============================================================================================
*/
-- Analyze Sales Performance Over Time
SELECT
DATETRUNC(month, order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- for year
SELECT
DATETRUNC(year, order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
ORDER BY DATETRUNC(year, order_date);

-- For different format
SELECT
FORMAT(order_date, 'yyyy-MMM') AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
