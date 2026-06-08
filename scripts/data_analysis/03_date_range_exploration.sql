-- Date Exploration
-- Find the date of fist and last order
-- How many years of sales available

SELECT 
MIN(order_date) first_order_date,
MAX(order_date) last_order_date,
DATEDIFF(YEAR, MIN(order_date),(MAX(order_date))) order_range_years
FROM gold.fact_sales;

-- Find the youngest and oldest customer

SELECT 
MIN(birthdate) oldest_birthdate,
DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
MAX(birthdate) youngest_birthdate,
DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age 
FROM gold.dim_customers

select TOP 2 * FROM gold.fact_sales
where quantity = 0
