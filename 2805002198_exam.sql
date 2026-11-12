-- Student:Kulani Precious Chuma - 2805002198
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

--DROP is a DDL command that completely deletes the entire table and its data.

--SECTION B: Selecting, Filtering, Aliases

--B1
-- Return customer_id, age, and annual_income as income, Europe 40+
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

-- B5: Bachelors or Graduate Degree who are homeowners (1 = homeowner)
USE SunVolt;
GO
SELECT 
    customer_id,
    education_level,
    homeowner_status
FROM dbo.customers
WHERE education_level IN ('Bachelors', 'Graduate Degree')
AND homeowner_status = '1';
GO

-- B6: occupation starts with Man
USE SunVolt;
GO
SELECT 
    customer_id,
    occupation
FROM dbo.customers
WHERE occupation LIKE 'Man%';
GO

-- B7: single customers who own 2+ vehicles OR 3+ dependents
USE SunVolt;
GO
SELECT 
    customer_id,
    marital_status,
    vehicles_owned,
    household_dependents
FROM dbo.customers
WHERE marital_status = 'Single'
AND (vehicles_owned >= 2 OR household_dependents >= 3);
GO

---Section C:

-- C1: total customers, purchases, conversion %
USE SunVolt;
GO
SELECT 
    COUNT(*) AS customers,
    SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) AS purchases,
    CAST(ROUND(100.0 * SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS DECIMAL(5,1)) AS conversion_pct
FROM dbo.customers;
GO

-- C2: conversion by region, highest first
USE SunVolt;
GO
SELECT 
    region,
    COUNT(*) AS customers,
    SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) AS purchases,
    CAST(ROUND(100.0 * SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS DECIMAL(5,1)) AS conversion_pct
FROM dbo.customers
GROUP BY region
ORDER BY conversion_pct DESC;
GO

-- C3 
USE SunVolt;
GO
SELECT 
    education_level,
    COUNT(*) AS customers,
    ROUND(AVG(CAST(REPLACE(annual_income, ' ', '') AS FLOAT)), 0) AS avg_income
FROM dbo.customers
GROUP BY education_level
HAVING COUNT(*) >= 100
ORDER BY avg_income DESC;
GO

-- C4: age_group with >50 purchases
USE SunVolt;
GO
SELECT 
    age_group,
    COUNT(*) AS customers,
    SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) AS purchases
FROM dbo.customers
GROUP BY age_group
HAVING SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) > 50
ORDER BY purchases DESC;
GO
-- C5: youngest, oldest, avg_income per gender
USE SunVolt;
GO
SELECT 
    gender,
    MIN(age) AS youngest,
    MAX(age) AS oldest,
    ROUND(AVG(CAST(REPLACE(annual_income, ' ', '') AS FLOAT)), 0) AS avg_income
FROM dbo.customers
GROUP BY gender;
GO

--Section D: Joins and Subqueries

-- D1: join customers to distance_bands
USE SunVolt;
GO
SELECT 
    db.installer_distance_order,
    COUNT(*) AS customers,
    SUM(CASE WHEN c.purchase_flag = 1 THEN 1 ELSE 0 END) AS purchases
FROM dbo.customers AS c
JOIN dbo.distance_bands AS db
    ON c.distance_band = db.distance_band
GROUP BY db.installer_distance_order
ORDER BY db.installer_distance_order;
GO

-- D2: customers earning more than average income
-- Count: 533
USE SunVolt;
GO
SELECT 
    customer_id,
    annual_income
FROM dbo.customers
WHERE CAST(REPLACE(annual_income, ' ', '') AS FLOAT) > 
    (SELECT AVG(CAST(REPLACE(annual_income, ' ', '') AS FLOAT)) 
     FROM dbo.customers);
GO
--D3
USE SunVolt;
GO
SELECT region, AVG(CAST(purchase_flag AS FLOAT)) AS purchase_rate
FROM dbo.customers
GROUP BY region
HAVING AVG(CAST(purchase_flag AS FLOAT)) > 0.45;
GO

-- D4: LEFT JOIN from distance_bands to customers - include all bands
USE SunVolt;
GO
SELECT 
    db.distance_band,
    COUNT(c.customer_id) AS customers
FROM dbo.distance_bands AS db
LEFT JOIN dbo.customers AS c
    ON c.distance_band = db.distance_band
GROUP BY db.distance_band, db.installer_distance_order
ORDER BY db.installer_distance_order;
GO

--Section E: Data Quality and CASE
-- E1: group customers into age segments using CASE
USE SunVolt;
GO
SELECT 
    CASE 
        WHEN age < 40 THEN 'Under 40'
        WHEN age BETWEEN 40 AND 59 THEN '40-59'
        ELSE '60+'
    END AS age_segment,
    COUNT(*) AS customers,
    SUM(CASE WHEN purchase_flag = 1 THEN 1 ELSE 0 END) AS purchases,
    CAST(AVG(CAST(purchase_flag AS FLOAT)) * 100 AS DECIMAL(5,2)) AS conversion_pct
FROM dbo.customers
GROUP BY 
    CASE 
        WHEN age < 40 THEN 'Under 40'
        WHEN age BETWEEN 40 AND 59 THEN '40-59'
        ELSE '60+'
    END
ORDER BY age_segment;
GO

-- E2: find duplicate customer_id
USE SunVolt;
GO
SELECT 
    customer_id,
    COUNT(*) AS copies
FROM dbo.customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY customer_id;
GO

--E3: count where purchased_solar_system and purchased_flag disagree
USE SunVolt;
GO
SELECT 
COUNT(*) AS mismatches
FROM dbo.customers
WHERE (purchased_solar_system = 'Yes' AND purchase_flag = 0)
OR (purchased_solar_system = 'No' AND purchase_flag =1);
GO

--E4: count distinct customers who purchased
USE SunVolt;
GO
SELECT
COUNT(DISTINCT customer_id) AS unique_buyers
FROM dbo.customers
WHERE purchase_flag = 1;
GO




