/*
===============================================================================
Create DataWarehouse Database and Schemas
===============================================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking for its existence. 
    If the database already exists, it will be dropped along with all its contents before being recreated.
    Additionally, the script creates three schemas within the 'DataWarehouse' database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the 'DataWarehouse' database if it already exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have backups if necessary before executing this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create schemas: 'bronze', 'silver', and 'gold'
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
