-- ==================================================
-- MAGNITUDE ANALYSIS
-- ==================================================
-- Q1) Total Salary by Gender
-- Q2) Total Salary by Education Level
-- Q3) Total Salary by Performance Rating
-- Q4) Total Salary by Department
-- Q5) Total Salary by Job Title
-- Q6) Total Salary by City
-- Q7) Total Salary by State
-- ==================================================


-- --------------------------------------------------
-- Q1) Total Salary by Gender
-- --------------------------------------------------

SELECT
    gender,
    FORMAT_NUMBER(SUM(salary))                                         AS total_salary,
    ROUND(SUM(salary) / (SELECT SUM(salary) FROM hr_database.hr_table) * 100, 1) AS per_salary
FROM hr_database.hr_table
GROUP BY gender
ORDER BY per_salary DESC;


-- --------------------------------------------------
-- Q2) Total Salary by Education Level
-- --------------------------------------------------

SELECT
    education_level,
    FORMAT_NUMBER(SUM(salary))                                         AS total_salary,
    ROUND(SUM(salary) / (SELECT SUM(salary) FROM hr_database.hr_table) * 100, 1) AS per_salary
FROM hr_database.hr_table
GROUP BY education_level
ORDER BY per_salary DESC;


-- --------------------------------------------------
-- Q3) Total Salary by Performance Rating
-- --------------------------------------------------

SELECT
    performance_rating,
    FORMAT_NUMBER(SUM(salary))                                         AS total_salary,
    ROUND(SUM(salary) / (SELECT SUM(salary) FROM hr_database.hr_table) * 100, 1) AS per_salary
FROM hr_database.hr_table
GROUP BY performance_rating
ORDER BY per_salary DESC;


-- --------------------------------------------------
-- Q4) Total Salary by Department
-- --------------------------------------------------

SELECT
    department,
    FORMAT_NUMBER(SUM(salary))                                         AS total_salary,
    ROUND(SUM(salary) / (SELECT SUM(salary) FROM hr_database.hr_table) * 100, 1) AS per_salary
FROM hr_database.hr_table
GROUP BY department
ORDER BY per_salary DESC;


-- --------------------------------------------------
-- Q5) Total Salary by Job Title
-- --------------------------------------------------

SELECT
    job_title,
    FORMAT_NUMBER(SUM(salary))                                         AS total_salary,
    ROUND(SUM(salary) / (SELECT SUM(salary) FROM hr_database.hr_table) * 100, 2) AS per_salary
FROM hr_database.hr_table
GROUP BY job_title
ORDER BY per_salary DESC;


-- --------------------------------------------------
-- Q6) Total Salary by City
-- --------------------------------------------------

SELECT
    city,
    FORMAT_NUMBER(SUM(salary))                                         AS total_salary,
    ROUND(SUM(salary) / (SELECT SUM(salary) FROM hr_database.hr_table) * 100, 2) AS per_salary
FROM hr_database.hr_table
GROUP BY city
ORDER BY per_salary DESC;


-- --------------------------------------------------
-- Q7) Total Salary by State
-- --------------------------------------------------

SELECT
    state,
    FORMAT_NUMBER(SUM(salary))                                         AS total_salary,
    ROUND(SUM(salary) / (SELECT SUM(salary) FROM hr_database.hr_table) * 100, 2) AS per_salary
FROM hr_database.hr_table
GROUP BY state
ORDER BY per_salary DESC;