-- ==================================================
-- RANKING ANALYSIS
-- ==================================================


-- --------------------------------------------------
-- Top 10 Highest Paid Employees
-- --------------------------------------------------

SELECT
    CONCAT_WS(' ', first_name, last_name)  AS employee_name,
    FORMAT_NUMBER(salary)                  AS salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS rank
FROM hr_database.hr_table
LIMIT 10;


-- --------------------------------------------------
-- Rank Top Hiring Years
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        YEAR(hiredate)     AS year,
        COUNT(employee_id) AS hired_employees
    FROM hr_database.hr_table
    GROUP BY year
)
SELECT
    year,
    hired_employees,
    DENSE_RANK() OVER (ORDER BY hired_employees DESC) AS rank_year
FROM table1;


-- --------------------------------------------------
-- Rank Top Termination Years
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        YEAR(termdate)     AS year,
        COUNT(employee_id) AS fired_employees
    FROM hr_database.hr_table
    GROUP BY year
    HAVING year IS NOT NULL
)
SELECT
    year,
    fired_employees,
    DENSE_RANK() OVER (ORDER BY fired_employees DESC) AS rank_year
FROM table1;