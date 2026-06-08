/*
=======================================================================
Database Exploration
=======================================================================
Getting database schema with their specifications and objects
  - Explore All Tables or Objects in the database
  - Explore All or Specific Columns in the Database 
=======================================================================
*/
-- Explore All Tables or Objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore All or Specific Columns in the Database 
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
