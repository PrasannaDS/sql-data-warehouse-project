/*
==================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==================================================================================
Script Purpose:
    This stored procedure performs ETL (Extract, Transform, Load) process to load 
    data into the 'Silver' schema from Bronze layer.
    It performs the following steps for each table:
      1. Truncates the existing data in the table.
      2. Extracts data from Bronze, transform and clean that data before loading 
         it into Silver tables. 

Parameters: 
    None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
==================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
    SET @batch_start_time = GETDATE();
        PRINT '                        ==============================================';
        PRINT '                                     Loading Silver layer';
        PRINT '                        ==============================================';

        PRINT '                        ----------------------------------------------';
        PRINT '                                     Loading CRM Tables';
        PRINT '                        ----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '
        --> Handling unwanted spaces using TRIM().
        --> Normalizing Marital Status and Gender values to readable format using CASE WHEN statement.
        --> Retaining only the latest record for each Customer based on Create Date ROW_NUMBER() window function.
        --> Filtering Data by excluding records with NULLs for Customer ID column.
        ';

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id, 
            cst_key, 
            cst_firstname, 
            cst_lastname, 
            cst_marital_status, 
            cst_gndr, 
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE UPPER(TRIM(cst_marital_status))
                WHEN 'S' THEN 'Single'
                WHEN 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status, -- Normalize marital status values to readable format
            CASE UPPER(TRIM(cst_gndr))
                WHEN 'M' THEN 'Male'
                WHEN 'F' THEN 'Female'
                ELSE 'n/a'
            END AS cst_gndr, -- Normalize gender values to readable format
            cst_create_date
        FROM 
        (
        SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY cst_id Order by cst_create_date DESC) AS rowflag
        FROM bronze.crm_cust_info
        ) AS t WHERE t.rowflag = 1 AND cst_id IS NOT NULL; -- Retain only the latest record for each customer based on create date and remove records with Null customer ID
         

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';

        -- Data Cleansing for bronze.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        
        PRINT '
        --> Deriving columns of Category ID and Product Key from prd_key column using SUBSTRING()
        --> Normalizing and Standardizing Product line with user friendly format.
        --> Handling unwanted spaces for Product line column using TRIM().
        --> Retaining the data consistency of Category ID and Product Key columns using REPLACE().
        --> Converting to DATE format while Calculating end date as one day before the next start date to avoid invalid data using LEAD() window function.
        ';

        PRINT '>> Inserting Data Into: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id, 
            cat_id, 
            prd_key, 
            prd_nm, 
            prd_cost, 
            prd_line, 
            prd_start_dt, 
            prd_end_dt)
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-','_')AS cat_id, -- Extracting category ID from product key
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,      -- Extracting product key by removing category ID and hyphen
            prd_nm,
            COALESCE(prd_cost,0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line, -- Mapping product line codes to full names and handling nulls for consistency and standardization
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(
                DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) 
                AS DATE
                ) AS prd_end_dt -- Calculate end date as one day before the next start date
        FROM bronze.crm_prd_info;
          
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
          
        PRINT '
        --> Handling invalid dates by converting to NULL and changing data type to DATE for Order Date, Ship Date and Due date.
        --> Recalculating sales if there is NULL, negative, Zero or inconsistent with quantity and price: sales = quantity * price
        --> Deriving price if original value is invalid using Business Ruleo of Price = Sales / Quantity (Handling Nulls if any using NULLIF())
        ';

        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details(
            sls_ord_num,
            sls_prd_key,
            sls_cst_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cst_id,
            CASE 
                WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
                WHEN sls_order_dt > 20500101 OR sls_order_dt < 19000101 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR(10)) AS DATE)
            END AS sls_order_dt, -- Handling invalid dates by converting to NULL and changing data type to DATE
            CASE 
                WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                WHEN sls_ship_dt > 20500101 OR sls_ship_dt < 19000101 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR(10)) AS DATE)
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
                WHEN sls_due_dt > 20500101 OR sls_due_dt < 19000101 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR(10)) AS DATE)
            END AS sls_due_dt,
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales 
            END AS sls_sales, -- Recalculating sales if it's NULL, negative, zero or inconsistent with quantity and price
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity,0)
                ELSE sls_price
            END AS sls_price   -- Derive price if original value is invalid
        FROM bronze.crm_sales_details;
          
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';

        PRINT '                        ----------------------------------------------';
        PRINT '                                     Loading CRM Tables';
        PRINT '                        ----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '
        --> Removing NAS prefix if it exists to maintain consistency with customer info table using SUBSTRING().
        --> Setting invalid Birthdates to NULL using CASE WHEN and Boundaries of 1900-01-01 and GETDATE().
        --> Standardizing Gender values as per rules using CASE WHEN and TRIM() with UPPER() functions,
        ';  

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid, -- Removing 'NAS' prefix if it exists to maintain consistency with customer info table
            CASE
                WHEN bdate > GETDATE() OR bdate < '1900-01-01' THEN NULL
                ELSE bdate
            END AS bdate, -- Setting invalid birthdates to NULL
            CASE 
                WHEN UPPER(TRIM(gen)) LIKE 'M%' OR UPPER(TRIM(gen)) LIKE 'MALE%' THEN 'Male'
                WHEN UPPER(TRIM(gen)) LIKE 'F%' OR UPPER(TRIM(gen)) LIKE 'FEMALE%' THEN 'Female'
                ELSE 'n/a'
            END AS gen -- Standardizing gender values
        FROM bronze.erp_cust_az12;
          
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';
        
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
          
        PRINT '
        --> Using Default values instead of country codes as per business and handling NULLs using CASE WHEN statement.
        --> Standardising column value with respect to customer key from the customer info data.
        --> Removing extra charcters of CHAR(10) and CHAR(13) from the column of Country using SUBQUERY.
        ';  

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101(cid, cntry)
        SELECT
            cid,
            CASE
                WHEN cntry = 'DE' THEN 'Germany'
                WHEN cntry IN ('US', 'USA') THEN 'United States'
                WHEN cntry = 'UK' THEN 'United Kingdom'
                WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
                ELSE cntry
            END AS cntry -- Using Default values instead of country codes as per business rules
        FROM(
                SELECT
                    REPLACE(TRIM(cid), '-', '') AS cid, -- Standardising column value wrt customer key
                    TRIM(CHAR(13) + CHAR(10) FROM cntry) AS cntry
                FROM bronze.erp_loc_a101
            ) AS filtered_erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';
        
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
         
        PRINT '
        --> Removing extra spaces from the column.
        --> Removing extra charcters of CHAR(10) and CHAR(13) from the column of Country using SUBQUERY.
        ';  

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
        SELECT
            id,
            cat,
            subcat,
            TRIM(CHAR(13) + CHAR(10) FROM maintenance) AS maintenance -- Removing extra character at the end of each row
        FROM bronze.erp_px_cat_g1v2;
    
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';

    SET @batch_end_time = GETDATE();
        PRINT '====================================================================================';
        PRINT '                     LOADING DATA INTO SILVER LAYER IS COMPLETED                    ';
        PRINT '                  - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '====================================================================================';  
    END TRY
    BEGIN CATCH
        PRINT'=====================================================================================';   
        PRINT 'ERROR OCCURED WHILE LOADING SILVER LAYER!'; 
        PRINT 'Error Message: ' + ERROR_MESSAGE();    
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT'=====================================================================================';    
    END CATCH
END;
