/*
Script Purpose:
  All the quality check queries for each table are over here.
  It is especially provides data correctness checks for silver
  schema after loading the data from bronze schema.
*/
-- ===========================================================
-- Checking 'silver.crm_cust_info'
-- ===========================================================

-- Check for Nulls or Duplicates in Primary Key Column
-- Expectation: No Nulls or Duplicates

SELECT 
  cst_id,
  COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 
OR cst_id IS NULL;

-- Check for unwanted spaces in customer marital status column
-- Expectation: No Unwanted Spaces

SELECT * 
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Check for unwanted spaces in customer gender column
-- Expectation: No Unwanted Spaces

SELECT * 
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check Standardization & consistency
-- For Gender
SELECT DISTINCT 
    cst_gndr 
FROM bronze.crm_cust_info;

-- For marital status
SELECT DISTINCT 
    cst_marital_status
FROM bronze.crm_cust_info;

--  Check for customer create date column for any NULLs and future dates
-- Expectation: No NULLs or Future Dates

SELECT * 
FROM bronze.crm_cust_info
WHERE cst_create_date IS NULL 
OR cst_create_date > GETDATE();

-- ===========================================================
-- Checking 'silver.crm_prd_info'
-- ===========================================================

--  Check for Nulls or Duplicates in Primary Key Column
-- Expectation: No Nulls or Duplicates

SELECT 
  prd_id,COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 
OR prd_id IS NULL;


--  Check for Nulls in Product Key Column
-- Expectation: No Nulls

SELECT 
  prd_key,
COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1 
OR prd_key IS NULL;

-- Check for unwanted spaces in product name
-- Expectation: No Unwanted Spaces

SELECT * 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for unwanted spaces in product key column
-- Expectation: No Unwanted Spaces

SELECT * 
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key);

-- Check for cardinality and consistency in product line column
-- Expectation: Cardinality should be less than 10 and values should be consistent with the product line in the sales details table

SELECT DISTINCT 
  prd_line 
FROM silver.crm_prd_info;

-- Check for Nulls or Negative numbers in Product Cost Column
-- Expectation: No Nulls or Negative Numbers

SELECT *
FROM silver.crm_prd_info
WHERE prd_cost IS NULL 
OR prd_cost < 0;

-- Check for invalid dates in product start and end date columns
-- Expectation: No Invalid Dates and End Date should be greater than Start Date

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ===========================================================
-- Checking 'silver.crm_sales_details'
-- ===========================================================

-- Check for NULLs and Duplicates in sales order number column
-- Expectation: No NULLs or Duplicates

SELECT
  sls_ord_num, 
  COUNT(*) AS cnt
FROM silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 
OR sls_ord_num IS NULL;

-- Check for unwanted spaces in sales order number column
-- Expectation: No Unwanted Spaces

SELECT
*
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Checking the Integrity of product keys in sales details table with product keys in product info table
-- Expectation: All product keys in sales details should have a matching product key in product info

SELECT DISTINCT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (
  SELECT 
    prd_key 
  FROM silver.crm_prd_info);

-- Checking the Integrity of Customer IDs in sales details table with customer IDs in customer info table
-- Expectation: All customer IDs in sales details should have a matching customer ID in customer info

SELECT DISTINCT sls_cst_id
FROM silver.crm_sales_details
WHERE sls_cst_id NOT IN (
  SELECT 
    cst_id 
  FROM silver.crm_cust_info);

-- Check for Invalid dates

SELECT 
  sls_ord_num,
  sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101 
OR sls_order_dt < 19000101  -- Assuming date is in YYYYMMDD format and should be a positive integer of length 8


-- Similar checks can be done for sls_ship_dt and sls_due_dt columns as well
-- Check for Invalid dates
SELECT 
  sls_ord_num,
  sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101  -- Assuming date is in YYYYMMDD

SELECT 
  sls_ord_num,
  sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101  -- Assuming date is in YYYYMMDD

-- Checking the dates consistency - Ship date should not be before order date and due date should not be before order date

SELECT
  sls_ord_num,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt

-- Check Data Consistency between Sales, Quantity and Price columns
-- >> Sales = Quantity * Price
-- >> Values must not be negative, NULL or zero

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= CAST(0 AS INT)
OR sls_quantity <= CAST(0 AS INT)
OR sls_price <= CAST(0 AS INT)
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
ORDER BY  sls_sales, sls_quantity, sls_price;

-- ===========================================================
-- Checking 'silver.erp_cust_az12'
-- ===========================================================

-- Check for Nulls or Duplicates in Primary Key Column and consistency of customer IDs with customer info table
-- Expectation: No Nulls or Duplicates and all customer IDs should be consistent with customer info table

SELECT 
*
FROM silver.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

-- Check for invalid dates in birthdate column
-- Expectation: No Invalid Dates and Birthdate should not be in the future

SELECT
bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE() OR bdate < '1900-01-01' -- Assuming birthdate should be between 1900 and current date

-- Check for data standardization and consistency

SELECT DISTINCT gen
FROM silver.erp_cust_az12

-- ===========================================================
-- Checking 'silver.erp_loc_a101'
-- ===========================================================

-- Check for Nulls or Duplicates in Primary Key Column and consistency of customer IDs with customer info table
-- Expectation: No Nulls or Duplicates and all customer IDs should be consistent with customer info table

SELECT 
  cid, 
  COUNT(*) AS cnt
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 
OR cid IS NULL

-- Data consistency check for cid - Check if the cid are consistent with the ids in the customer table
-- Expectation: All cid in location table should have a matching cst_key in customer info table
SELECT 
  cid 
FROM silver.erp_loc_a101 
WHERE cid NOT IN (
  SELECT 
    cst_key 
  FROM silver.crm_cust_info)

-- Check the country names Consistency and standardization
-- Expectation: Country names should be consistent and standardized (e.g., USA, United States, US should be standardized to one value)

SELECT DISTINCT 
  cntry
FROM silver.erp_loc_a101;

-- ===========================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ===========================================================

-- Check the id for nulls and duplicates from category table
-- Expectation: No Nulls and Duplicates

SELECT id, COUNT(*) cnt
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING id IS NULL OR COUNT(*)>1;

-- Data Consistency of category id with the cat_id from product info table 
-- Expectation: Data is consistant with given condition

SELECT
    id,
    cat,
    subcat,
    TRIM(CHAR(13) + CHAR(10) FROM maintenance) AS maintenance
FROM silver.erp_px_cat_g1v2
WHERE id NOT IN (
  SELECT 
    cat_id 
  FROM silver.crm_prd_info);

-- Check the Category column for Invalid Values like NULLs and Empty Strings
-- Expectation:  No NULLs or Empty strings

SELECT DISTINCT
  cat 
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT
  subcat 
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT
  maintenance 
FROM silver.erp_px_cat_g1v2

-- Check for any unwanted spaces
-- Expectation: No extra spaces

SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance)
