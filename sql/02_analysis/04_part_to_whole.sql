-- ==================================================
-- PART-TO-WHOLE PROPORTIONAL
-- ==================================================

-- A part-to-whole ratio expresses the relationship between a part and the entire whole.

-- Q1) Number of Hired Employees (Male & Female) by City
-- Q2) Cities by Working Employees Performance
-- Q3) Cities by Hired Employees Education Level
-- ==================================================


-- --------------------------------------------------
-- Q1) Number of Hired Employees (Male & Female) by City
-- --------------------------------------------------

SELECT
    city,
    CONCAT(ROUND(100 * COUNT(CASE WHEN gender = 'Male'   THEN 1 END) / COUNT(*), 1), '%') AS male,
    CONCAT(ROUND(100 * COUNT(CASE WHEN gender = 'Female' THEN 1 END) / COUNT(*), 1), '%') AS female,
    COUNT(*) AS total_emp
FROM hr_database.hr_table
GROUP BY city
ORDER BY total_emp DESC;


-- --------------------------------------------------
-- Q2) Cities by Working Employees Performance
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        city,
        performance_rating
    FROM hr_database.hr_table
    WHERE termdate IS NULL
)
SELECT
    city,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Excellent'         THEN 1 END) / COUNT(*), 1), '%') AS excellent,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Good'              THEN 1 END) / COUNT(*), 1), '%') AS good,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Satisfactory'      THEN 1 END) / COUNT(*), 1), '%') AS satisfactory,
    CONCAT(ROUND(100 * COUNT(CASE WHEN performance_rating = 'Needs Improvement' THEN 1 END) / COUNT(*), 1), '%') AS needs_improvement,
    COUNT(*) AS total_emp
FROM table1
GROUP BY city
ORDER BY total_emp DESC;


-- --------------------------------------------------
-- Q3) Cities by Hired Employees Education Level
-- --------------------------------------------------

SELECT
    city,
    CONCAT(ROUND(100 * COUNT(CASE WHEN education_level = 'Master'      THEN 1 END) / COUNT(*), 1), '%') AS master,
    CONCAT(ROUND(100 * COUNT(CASE WHEN education_level = 'phD'         THEN 1 END) / COUNT(*), 1), '%') AS phd,
    CONCAT(ROUND(100 * COUNT(CASE WHEN education_level = 'Bachelor'    THEN 1 END) / COUNT(*), 1), '%') AS bachelor,
    CONCAT(ROUND(100 * COUNT(CASE WHEN education_level = 'High School' THEN 1 END) / COUNT(*), 1), '%') AS high_school,
    COUNT(*) AS total_emp
FROM hr_database.hr_table
GROUP BY city
ORDER BY total_emp DESC;