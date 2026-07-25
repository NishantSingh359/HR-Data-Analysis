-- ==================================================
-- PERFORMANCE ANALYSIS
-- ==================================================
-- Q1) Top 10 Highest Paid Employees Performance
-- Q2) Department by Employees Performance
-- Q3) Employees Performance by Education Level
-- Q4) Gender by Performance
-- Q5) Department by Highest Termination
-- ==================================================


-- --------------------------------------------------
-- Q1) Top 10 Highest Paid Employees Performance
-- --------------------------------------------------

SELECT
    employee_id,
    CONCAT_WS(' ', first_name, last_name) AS name,
    department,
    performance_rating,
    FORMAT_NUMBER(salary)                 AS salary
FROM hr_database.hr_table
ORDER BY salary DESC
LIMIT 10;


-- --------------------------------------------------
-- Q2) Department by Employees Performance
-- --------------------------------------------------

SELECT
    department,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Excellent'         THEN 1 END) / COUNT(*), 1), '%') AS excellent,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Good'              THEN 1 END) / COUNT(*), 1), '%') AS good,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Satisfactory'      THEN 1 END) / COUNT(*), 1), '%') AS satisfactory,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Needs Improvement' THEN 1 END) / COUNT(*), 1), '%') AS needs_improvement,
    COUNT(*) AS total_emp
FROM hr_database.hr_table
GROUP BY department;


-- --------------------------------------------------
-- Q3) Education Level by Employees Performance
-- --------------------------------------------------

SELECT
    education_level,
    ROUND(100 * COUNT(CASE WHEN performance_rating = 'Excellent'         THEN 1 END) / COUNT(*), 1) AS excellent,
    ROUND(100 * COUNT(CASE WHEN performance_rating = 'Good'              THEN 1 END) / COUNT(*), 1) AS good,
    ROUND(100 * COUNT(CASE WHEN performance_rating = 'Satisfactory'      THEN 1 END) / COUNT(*), 1) AS satisfactory,
    ROUND(100 * COUNT(CASE WHEN performance_rating = 'Needs Improvement' THEN 1 END) / COUNT(*), 1) AS needs_improvement,
    COUNT(*) AS total_emp
FROM hr_database.hr_table
GROUP BY education_level
ORDER BY excellent DESC;

-- --------------------------------------------------
-- Q4) Gender by Performance
-- --------------------------------------------------

SELECT
    gender,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Excellent'         THEN 1 END) / COUNT(*), 1), '%') AS excellent,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Good'              THEN 1 END) / COUNT(*), 1), '%') AS good,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Satisfactory'      THEN 1 END) / COUNT(*), 1), '%') AS satisfactory,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Needs Improvement' THEN 1 END) / COUNT(*), 1), '%') AS needs_improvement,
    COUNT(*) AS total_emp
FROM hr_database.hr_table
GROUP BY gender;


-- --------------------------------------------------
-- Q5) Which departments have the highest attrition
-- --------------------------------------------------

WITH table1 AS(
    SELECT *
    FROM hr_database.hr_table
    WHERE termdate IS NOT NULL
)
SELECT 
    department,
    COUNT(employee_id) as employees
FROM table1
GROUP BY department
ORDER BY employees DESC;



