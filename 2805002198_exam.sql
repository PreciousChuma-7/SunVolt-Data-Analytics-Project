-- Student: Precious Chuma - 2805002198
-- SECTION A: Database and Table Creation

-- 2805002198 - SunVolt Exam
-- A1: Create database SunVolt
CREATE DATABASE SunVolt;
GO
USE SunVolt;
GO

-- A2: Create customers table with 16 columns from dictionary
DROP TABLE IF EXISTS dbo.customers;
GO
CREATE TABLE dbo.customers (
    customer_id INT,
    marital_status VARCHAR(20),
    gender VARCHAR(10),
    annual_income VARCHAR(20),
    household_dependents INT,
    education_level VARCHAR(50),
    occupation VARCHAR(50),
    homeowner_status VARCHAR(20),
    vehicles_owned INT,
    distance_band VARCHAR(50),
    region VARCHAR(20),
    age INT,
    purchased_solar_system VARCHAR(10),
    purchase_flag INT,
    age_group VARCHAR(20),
    income_band VARCHAR(20)
);
GO

-- A3: Create distance_bands table with 5 rows
DROP TABLE IF EXISTS dbo.distance_bands;
GO
CREATE TABLE dbo.distance_bands (
    installer_distance_order INT PRIMARY KEY,
    distance_band VARCHAR(50)
);
GO
INSERT INTO dbo.distance_bands (installer_distance_order, distance_band) VALUES
(1, '0-1 km'),
(2, '1-2 km'),
(3, '2-5 km'),
(4, '5-10 km'),
(5, '10+ km');
GO

-- A4: Import Excel data via SSMS Import Flat File
-- Imported into staging table SunVolt_Solar_Customer_DataCSV then inserted into customers
-- Mapped: Distance_from_Nearest_Installer -> distance_band
-- Excluded: Installer_Distance_Order (used in distance_bands)
INSERT INTO dbo.customers (
    customer_id, marital_status, gender, annual_income,
    household_dependents, education_level, occupation,
    homeowner_status, vehicles_owned, distance_band,
    region, age, purchased_solar_system, purchase_flag,
    age_group, income_band
)
SELECT 
    Customer_ID, Marital_Status, Gender, Annual_Income,
    Household_Dependents, Education_Level, Occupation,
    Homeowner_Status, Vehicles_Owned, Distance_from_Nearest_Installer,
    Region, Age, Purchased_Solar_System, Purchase_Flag,
    Age_Group, Income_Band
FROM dbo.SunVolt_Solar_Customer_DataCSV;
GO

-- A4 Check: customers should hold 1026 rows
SELECT COUNT(*) AS total_customers FROM dbo.customers;
SELECT TOP 5 * FROM dbo.customers;

--A5
DELETE is a DML command that removes specific rows(with WHERE) and can be rolled back
TRUNCATE is a DDL command that quickly deletes all rows but keeps the table structure, while-
DROP is a DDL command that completely deletes the entire table and its data.

--SECTION B: Selecting, Filtering, Aliases

--B1
 Return customer_id, age, and annual_income as income, Europe 40+
SELECT 
    customer_id,
    age,
    annual_income AS income
FROM dbo.customers
WHERE region = 'Europe' AND age >= 40;

-- B2: List distinct occupations sorted alphabetically
USE SunVolt;
GO
SELECT DISTINCT occupation
FROM dbo.customers
ORDER BY occupation ASC;

-- B3: customer_id and annual_income between 30k and 70k inclusive, high to low
USE SunVolt;
GO
SELECT 
    customer_id,
    annual_income
FROM dbo.customers
WHERE CAST(REPLACE(annual_income, ' ', '') AS INT) BETWEEN 30000 AND 70000
ORDER BY CAST(REPLACE(annual_income, ' ', '') AS INT) DESC;
GO

-- B4: total rows and unique customers
USE SunVolt;
GO
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM dbo.customers;
GO







