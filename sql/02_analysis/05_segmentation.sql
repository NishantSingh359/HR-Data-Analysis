-- ==================================================
-- DATA SEGMENTATION
-- ==================================================
-- Q1) Group Employees into Categories Based on Their Working Experience.
--     Intern       Intermediate   Mid Level     Senior Level
--     0-2 Years    2-4 Years      4-8 Years     8+ Years
--
-- Q2) Which Age Group of Employees Leave Company Most?
--     Youth        Young Professional        Middle Aged        Seniors         
--     15-25 Years  25-44 Years               45-64 Years        65+ Years        
--
-- Q3) Which Age Group of Employees Company have Most?
--
-- Q4) Group Salary by Categories.
--     Low Salary       Middle Salary      Upper Middle Salary    High Salary
--     $50,000-$70,000  $70,001-$100,000   $100,001-$130,000     $130,001-$150,000
--
-- Q5) Does Salary Affect Employee Attrition?
--
-- Q6) Employees Experience by Salary Category.
-- ==================================================


-- --------------------------------------------------
-- Q1) Group Working Employees into Categories Based on Their Working Experience.
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        employee_id,
        CASE
            WHEN YEAR(CURDATE()) - YEAR(hiredate) BETWEEN 0 AND 2 THEN 'Intern'
            WHEN YEAR(CURDATE()) - YEAR(hiredate) BETWEEN 2 AND 4 THEN 'Intermediate'
            WHEN YEAR(CURDATE()) - YEAR(hiredate) BETWEEN 4 AND 8 THEN 'Mid Level'
            WHEN YEAR(CURDATE()) - YEAR(hiredate) > 8             THEN 'Senior Level'
            ELSE YEAR(CURDATE()) - YEAR(hiredate)
        END AS working_experience
    FROM Human_Resource.Data
    WHERE termdate IS NULL
)
SELECT
    working_experience,
    CONCAT(ROUND(COUNT(employee_id) / (SELECT COUNT(employee_id) FROM Human_Resource.Data) * 100, 2), '%') AS employees
FROM table1
GROUP BY working_experience
ORDER BY COUNT(employee_id) DESC;

-- --------------------------------------------------
-- Q2) Which Age Group of Employees Leave Company Most?
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        employee_id,
        CASE
            WHEN YEAR(CURDATE()) - YEAR(birthdate) BETWEEN 15 AND 24 THEN 'Youth'
            WHEN YEAR(CURDATE()) - YEAR(birthdate) BETWEEN 25 AND 44 THEN 'Young Professional'
            WHEN YEAR(CURDATE()) - YEAR(birthdate) BETWEEN 45 AND 64 THEN 'Middle Aged'
            WHEN YEAR(CURDATE()) - YEAR(birthdate) > 64             THEN 'Seniors'
            ELSE YEAR(CURDATE()) - YEAR(birthdate)
        END AS working_experience
    FROM Human_Resource.Data
    WHERE termdate IS NOT NULL
)
SELECT
    working_experience,
    COUNT(employee_id) as employees
FROM table1
GROUP BY working_experience
ORDER BY COUNT(employee_id) DESC;

-- --------------------------------------------------
-- Q3) Which Age Group of Employees Company have Most?
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        employee_id,
        CASE
            WHEN YEAR(CURDATE()) - YEAR(birthdate) BETWEEN 15 AND 24 THEN 'Youth'
            WHEN YEAR(CURDATE()) - YEAR(birthdate) BETWEEN 25 AND 44 THEN 'Young Professional'
            WHEN YEAR(CURDATE()) - YEAR(birthdate) BETWEEN 45 AND 64 THEN 'Middle Aged'
            WHEN YEAR(CURDATE()) - YEAR(birthdate) > 64             THEN 'Seniors'
            ELSE YEAR(CURDATE()) - YEAR(birthdate)
        END AS working_experience
    FROM Human_Resource.Data
    WHERE termdate IS NULL
)
SELECT
    working_experience,
    COUNT(employee_id) as employees
FROM table1
GROUP BY working_experience
ORDER BY COUNT(employee_id) DESC;


-- --------------------------------------------------
-- Q4) Group Salary by Categories
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        employee_id,
        CASE
            WHEN salary BETWEEN  50000 AND  70000 THEN 'Low Salary'
            WHEN salary BETWEEN  70001 AND 100000 THEN 'Middle Salary'
            WHEN salary BETWEEN 100001 AND 130000 THEN 'Upper Middle Salary'
            WHEN salary BETWEEN 130001 AND 150000 THEN 'High Salary'
            ELSE salary
        END AS salary_category
    FROM Human_Resource.Data
    WHERE termdate IS NULL
)
SELECT
    salary_category,
    CONCAT(ROUND(COUNT(employee_id) / (SELECT COUNT(employee_id) FROM Human_Resource.Data) * 100, 2), '%') AS employees
FROM table1
GROUP BY salary_category
ORDER BY COUNT(employee_id) DESC;

--------------------------------------------------
-- Q5) Does salary affect employee attrition?
--------------------------------------------------
WITH table1 AS (
    SELECT
        employee_id,
        CASE
            WHEN salary BETWEEN  50000 AND  70000 THEN 'Low Salary'
            WHEN salary BETWEEN  70001 AND 100000 THEN 'Middle Salary'
            WHEN salary BETWEEN 100001 AND 130000 THEN 'Upper Middle Salary'
            WHEN salary BETWEEN 130001 AND 150000 THEN 'High Salary'
            ELSE salary
        END AS salary_category
    FROM Human_Resource.Data
    WHERE termdate IS NOT NULL
)
SELECT
    salary_category,
    COUNT(employee_id) AS employees
FROM table1
GROUP BY salary_category
ORDER BY employees DESC;

-- --------------------------------------------------
-- Q6) Employees Experience by Salary Category
-- --------------------------------------------------

WITH table1 AS (
    SELECT
        employee_id,
        CASE
            WHEN YEAR(CURDATE()) - YEAR(hiredate) BETWEEN 0 AND 2 THEN 'Intern'
            WHEN YEAR(CURDATE()) - YEAR(hiredate) BETWEEN 2 AND 4 THEN 'Intermediate'
            WHEN YEAR(CURDATE()) - YEAR(hiredate) BETWEEN 4 AND 8 THEN 'Mid Level'
            WHEN YEAR(CURDATE()) - YEAR(hiredate) > 8             THEN 'Senior Level'
            ELSE YEAR(CURDATE()) - YEAR(hiredate)
        END AS working_experience,
        CASE
            WHEN salary BETWEEN  50000 AND  70000 THEN 'Low Salary'
            WHEN salary BETWEEN  70001 AND 100000 THEN 'Middle Salary'
            WHEN salary BETWEEN 100001 AND 130000 THEN 'Upper Middle Salary'
            WHEN salary BETWEEN 130001 AND 150000 THEN 'High Salary'
            ELSE salary
        END AS salary_category
    FROM Human_Resource.Data
)
SELECT
    working_experience,
    CONCAT(ROUND(100 * COUNT(CASE WHEN salary_category = 'Low Salary'          THEN 1 END) / COUNT(*), 1), '%') AS low_salary,
    CONCAT(ROUND(100 * COUNT(CASE WHEN salary_category = 'Middle Salary'        THEN 1 END) / COUNT(*), 1), '%') AS middle_salary,
    CONCAT(ROUND(100 * COUNT(CASE WHEN salary_category = 'Upper Middle Salary'  THEN 1 END) / COUNT(*), 1), '%') AS upper_middle_salary,
    CONCAT(ROUND(100 * COUNT(CASE WHEN salary_category = 'High Salary'          THEN 1 END) / COUNT(*), 1), '%') AS high_salary
FROM table1
GROUP BY working_experience;