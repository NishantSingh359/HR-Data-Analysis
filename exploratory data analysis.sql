
-- ==================================================
-- ======================== EXPLORATORY DATA ANALYSIS
-- ==================================================

-- Explore, Understand and Cover Inside of the Data

-- Project Steps

-- 1) Database & Table Explotation
-- 2) Dimension Exploration
-- 3) Date Exploration
-- 4) Measures Exploration
-- 5) Magnitude Analysis
-- 6) Ranking Analysis


-- --------------------------------------------------
-- ===================== DATABASE & TABLE EXPLORATION
-- --------------------------------------------------

-- ============== DATABASE EXPLORATION

-- List All Database
SHOW DATABASES;

-- Show Current Database in Use
SELECT DATABASE();

-- ================= TABLE EXPLORATION

-- Return Tables From Selected Database
SHOW TABLES;

-- Show Table Structure
DESCRIBE hr_database.hr_table;
SHOW COLUMNS FROM hr_database.hr_table


-- --------------------------------------------------
-- ============================ DIMENSION EXPLORATION
-- --------------------------------------------------

-- ======== LOW CARDINALITY DIMENSIONS

WITH g AS (
    SELECT ROW_NUMBER() OVER() AS rn, gender
    FROM (SELECT DISTINCT gender FROM hr_database.hr_table) t1
),
p AS (
    SELECT ROW_NUMBER() OVER() AS rn, performance_rating
    FROM (SELECT DISTINCT performance_rating FROM hr_database.hr_table) t2
),
e AS (
    SELECT ROW_NUMBER() OVER() AS rn, education_lavel
    FROM (SELECT DISTINCT education_lavel FROM hr_database.hr_table) t3
),
d AS (
    SELECT ROW_NUMBER() OVER() AS rn, department
    FROM (SELECT DISTINCT department FROM hr_database.hr_table) t4
)
SELECT 
    department,
    performance_rating,
    education_lavel,
    gender
FROM d
LEFT JOIN e
ON d.rn = e.rn
LEFT JOIN p
ON d.rn = p.rn
LEFT JOIN g
ON d.rn = g.rn;


-- ===== Column with Sub-column

-- State's with City's

SELECT 
state,
GROUP_CONCAT(DISTINCT city)
FROM hr_database.hr_table
GROUP BY state;

-- Department with Job title

SELECT 
department,
GROUP_CONCAT(DISTINCT job_title)
FROM hr_database.hr_table
GROUP BY department;


-- ======= HIGH CARDINALITY DIMENSIONS

SELECT 
    employee_id,
    CONCAT_WS(' ', first_name, last_name) as name
FROM hr_database.hr_table;


-- --------------------------------------------------
-- ============================= MEASURES EXPLORATION
-- --------------------------------------------------

SELECT COUNT(*) AS value, "Total Rows"
FROM hr_database.hr_table
UNION
SELECT SUM(salary) AS value, "Total Salary"
FROM hr_database.hr_table
UNION
SELECT ROUND(AVG(salary),2) AS value, "Avg Salary"
FROM hr_database.hr_table
UNION
SELECT MAX(salary) AS value, "Maximum Salary"
FROM hr_database.hr_table
UNION
SELECT MIN(salary) AS value, "Minimum Salary"
FROM hr_database.hr_table
UNION
SELECT ROUND(STD(salary),2) AS value, "STD"
FROM hr_database.hr_table;


-- --------------------------------------------------
-- ================================= DATE EXPLORATION
-- --------------------------------------------------

-- Find the First and Last birthdate, hiredate , termdate and gaps of an Employee

SELECT "-- Birthdate" AS value, " " AS column_name
UNION
SELECT
    MAX(birthdate) AS value, "Yongest Employee" AS column_name
FROM hr_database.hr_table
UNION
SELECT
    MIN(birthdate) AS value, "Oldest Employee" AS column_name
FROM hr_database.hr_table
UNION
SELECT
    CONCAT_WS(" ",ROUND(DATEDIFF(MAX(birthdate), MIN(birthdate))/365),"years") AS value, "Age Gap" AS column_name
FROM hr_database.hr_table
UNION
SELECT "-- Hiredate" AS value, " " AS column_name
UNION
SELECT
    MIN(hiredate) AS value, "First Hiredate" AS column_name
FROM hr_database.hr_table
UNION
SELECT
    MAX(hiredate) AS value, "Last Hiredate" AS column_name
FROM hr_database.hr_table
UNION
SELECT
    CONCAT_WS(" ",ROUND(DATEDIFF(MAX(hiredate), MIN(hiredate))/365),"years") AS value, "Company Experience Gap" AS column_name
FROM hr_database.hr_table
UNION
SELECT "-- Terminated date" AS value, " " AS column_name
UNION
SELECT
    MIN(termdate) AS value, "First Terminated Employee" AS column_name
FROM hr_database.hr_table
UNION
SELECT
    MAX(termdate) AS value, "Last Terminated Employee" AS column_name
FROM hr_database.hr_table


-- --------------------------------------------------
-- =============================== MAGNITUDE ANALYSIS
-- --------------------------------------------------

-- Total Salary by Gender

SELECT 
    IFNULL(gender,"Total Salary") AS gender,
    SUM(salary) AS Total_Salary,
    CONCAT(ROUND((SUM(salary)/ (SELECT SUM(salary) FROM hr_database.hr_table))*100),"%") AS Per_Salary
FROM hr_database.hr_table
GROUP BY gender
WITH ROLLUP
ORDER BY Total_Salary DESC;


-- Total Salary by Education lavel

SELECT 
    IFNULL(education_lavel,"Total Salary") AS Education_Lavel,
    SUM(salary) AS Total_Salary,
    CONCAT(ROUND(SUM(salary)/ (SELECT SUM(salary) FROM hr_database.hr_table),2)*100,"%") AS Per_Salary
FROM hr_database.hr_table
GROUP BY education_lavel
WITH ROLLUP
ORDER BY Total_Salary DESC;


-- Total Salary by Performance Rating

SELECT 
    IFNULL(performance_rating,"Total Salary") AS performance_rating,
    SUM(salary) AS Total_Salary,
    CONCAT(ROUND((SUM(salary)/ (SELECT SUM(salary) FROM hr_database.hr_table))*100),"%") AS Per_Salary
FROM hr_database.hr_table
GROUP BY performance_rating
WITH ROLLUP
ORDER BY Total_Salary DESC;


-- Total Salary by Dipartment

SELECT 
    IFNULL(department,"Total Salary") AS Department,
    SUM(salary) AS Total_Salary,
    CONCAT(ROUND((SUM(salary)/ (SELECT SUM(salary) FROM hr_database.hr_table))*100),"%") AS Per_Salary
FROM hr_database.hr_table
GROUP BY department
WITH ROLLUP
ORDER BY Total_Salary DESC;


-- Total Salary by Job Title

SELECT 
    IFNULL(job_title,"Total Salary") AS job_title,
    SUM(salary) AS Total_Salary,
    CONCAT(ROUND((SUM(salary)/ (SELECT SUM(salary) FROM hr_database.hr_table))*100,2),"%") AS Per_Salary
FROM hr_database.hr_table
GROUP BY job_title
WITH ROLLUP
ORDER BY Total_Salary DESC;


-- Total Salary by State

SELECT 
    IFNULL(state,"Total Salary") AS State,
    SUM(salary) AS Total_Salary,
    CONCAT(ROUND((SUM(salary)/ (SELECT SUM(salary) FROM hr_database.hr_table))*100,2),"%") AS Per_Salary
FROM hr_database.hr_table
GROUP BY State
WITH ROLLUP
ORDER BY Total_Salary DESC;


-- Total Salary by City

SELECT 
    IFNULL(city,"Total Salary") AS City,
    SUM(salary) AS Total_Salary,
    CONCAT(ROUND((SUM(salary)/ (SELECT SUM(salary) FROM hr_database.hr_table))*100,2),"%") AS Per_Salary
FROM hr_database.hr_table
GROUP BY City
WITH ROLLUP
ORDER BY Total_Salary DESC;


-- --------------------------------------------------
-- ================================= RANKING ANALYSIS
-- --------------------------------------------------

-- Top 10 High Payed Employess

WITH table1 AS (
SELECT 
    CONCAT_WS(" ", first_name, last_name) AS Employess_Name,
    SUM(salary) AS Salary
FROM hr_database.hr_table
GROUP BY Employess_Name
)
SELECT 
    Employess_Name,
    Salary,
    DENSE_RANK() OVER(ORDER BY Salary DESC) AS Ranks
FROM table1
LIMIT 10;


-- Bottom 10 High Payed Employess

WITH table1 AS (
SELECT 
    CONCAT_WS(" ", first_name, last_name) AS Employess_Name,
    SUM(salary) AS Salary
FROM hr_database.hr_table
GROUP BY Employess_Name
)
SELECT 
    Employess_Name,
    Salary,
    DENSE_RANK() OVER(ORDER BY Salary ASC) AS Ranks
FROM table1
LIMIT 10;


-- Rank Top Hiring Year's

WITH table1 AS (
    SELECT 
        YEAR(hiredate) AS year,
        COUNT(employee_id) AS Hired_Employees
    FROM hr_database.hr_table
    GROUP BY year
)
SELECT 
    year,
    Hired_Employees,
    DENSE_RANK() OVER(ORDER BY Hired_Employees DESC) AS Rank_Year
FROM table1;


-- Rank Top Firing Year's

WITH table1 AS (
    SELECT 
        YEAR(termdate) AS year,
        COUNT(employee_id) AS Fired_Employees
    FROM hr_database.hr_table
    GROUP BY year
    HAVING year IS NOT NULL
)
SELECT 
    year,
    Fired_Employees,
    DENSE_RANK() OVER(ORDER BY fired_employees DESC) AS Rank_Year
FROM table1;




















