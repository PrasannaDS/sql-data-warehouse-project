-- Database Exploration

-- Explore All Objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore All Columns in the Database 
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'