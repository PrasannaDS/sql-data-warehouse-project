/*
==================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==================================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following steps for each table:
    1. Truncates the existing data in the table.
    2. Loads new data from the corresponding CSV file using 'BULK INSERT' command.

Parameters: 
    None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
==================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
    SET @batch_start_time = GETDATE();
        PRINT '                   ==============================================';
        PRINT '                                Loading Bronze layer             ';
        PRINT '                   ==============================================';

        PRINT '                   ----------------------------------------------';
        PRINT '                                 Loading CRM Tables              ';
        PRINT '                   ----------------------------------------------';
        
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '
        --> Loading data from CSV file as is without any changes.
        --> Specifying the FIRSTROW and FIELDTERMINATOR values while performing BULK INSERT.
        ';

        PRINT '>> Inserting data into Table: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        
        PRINT '
        --> Loading data from CSV file as is without any changes.
        --> Specifying the FIRSTROW and FIELDTERMINATOR values while performing BULK INSERT.
        ';

        PRINT '>> Inserting data into Table: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds'; 
        PRINT '==================================================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '
        --> Loading data from CSV file as is without any changes.
        --> Specifying the FIRSTROW and FIELDTERMINATOR values while performing BULK INSERT.
        ';

        PRINT '>> Inserting data into Table: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';

        PRINT '                   ----------------------------------------------';
        PRINT '                                 Loading ERP Tables              ';
        PRINT '                   ----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '
        --> Loading data from CSV file as is without any changes.
        --> Specifying the FIRSTROW and FIELDTERMINATOR values while performing BULK INSERT.
        ';

        PRINT '>> Inserting data into Table: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds'; 
        PRINT '==================================================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '
        --> Loading data from CSV file as is without any changes.
        --> Specifying the FIRSTROW and FIELDTERMINATOR values while performing BULK INSERT.
        ';
        
        PRINT '>> Inserting data into Table: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds'; 
        PRINT '==================================================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '
        --> Loading data from CSV file as is without any changes.
        --> Specifying the FIRSTROW and FIELDTERMINATOR values while performing BULK INSERT.
        ';

        PRINT '>> Inserting data into Table: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';
    
        SET @batch_end_time = GETDATE();
        PRINT '==================================================================================';
        PRINT '            LOADING DATA INTO BRONZE LAYER IS COMPLETED!                          ';
        PRINT '           - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==================================================================================';
    END TRY
    BEGIN CATCH
        PRINT'====================================================================================';   
        PRINT 'ERROR OCCURED WHILE LOADING BRONZE LAYER!'; 
        PRINT 'Error Message: ' + ERROR_MESSAGE();    
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT'====================================================================================';        
    END CATCH
    END;
