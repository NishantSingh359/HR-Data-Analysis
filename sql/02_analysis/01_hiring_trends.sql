-- ==================================================
-- CHANGE-OVER-TIME TRENDS
-- ==================================================
-- Q1) Hired & Terminated Male & Female Employees by Year
-- Q2) Hired & Terminated Employees by Year & Month
-- Q3) Working Employees Upcoming Birthday
-- Q4) Male & Female Contribution in Total Salary by Year
-- Q5) Total Salary by Year & Month

-- ==================================================


-- --------------------------------------------------
-- Q1) Hired & Terminated Male & Female Employees by Year
-- --------------------------------------------------

SELECT
    table1.years,
    hired_male,
    hired_female,
    hired_employee,
    terminated_male,
    terminated_female,
    terminated_employee
FROM (
    SELECT
        YEAR(hiredate)                                                                  AS years,
        ROUND(COUNT(CASE WHEN gender = 'Male'   THEN 1 END) / COUNT(employee_id) * 100, 1) AS hired_male,
        ROUND(COUNT(CASE WHEN gender = 'Female' THEN 1 END) / COUNT(employee_id) * 100, 1) AS hired_female,
        COUNT(employee_id)                                                              AS hired_employee
    FROM hr_table
    GROUP BY years
) AS table1
JOIN (
    SELECT
        YEAR(termdate)                                                                  AS years,
        ROUND(COUNT(CASE WHEN gender = 'Male'   THEN 1 END) / COUNT(employee_id) * 100, 1) AS terminated_male,
        ROUND(COUNT(CASE WHEN gender = 'Female' THEN 1 END) / COUNT(employee_id) * 100, 1) AS terminated_female,
        COUNT(employee_id)                                                              AS terminated_employee
    FROM hr_table
    GROUP BY years
) AS table2
    ON table1.years = table2.years
ORDER BY table1.years ASC;


-- --------------------------------------------------
-- Q2) Hired & Terminated Employees by Year & Month
-- --------------------------------------------------

SELECT
    hire_year          AS years,
    hire_month         AS months,
    hired_employee,
    terminated_employee
FROM (
    SELECT
        YEAR(hiredate)     AS hire_year,
        MONTH(hiredate)    AS hire_month,
        COUNT(employee_id) AS hired_employee
    FROM hr_table
    GROUP BY hire_year, hire_month
) AS table1
LEFT JOIN (
    SELECT
        YEAR(termdate)     AS terminated_year,
        MONTH(termdate)    AS terminated_month,
        COUNT(employee_id) AS terminated_employee
    FROM hr_table
    GROUP BY terminated_year, terminated_month
) AS table2
    ON CONCAT(hire_year, hire_month) = CONCAT(terminated_year, terminated_month)
ORDER BY hire_year, hire_month;


-- --------------------------------------------------
-- Q3) Working Employees Upcoming Birthday
-- --------------------------------------------------

SELECT
    employee_id                           AS emp_id,
    CONCAT_WS(' ', first_name, last_name) AS name,
    DATE_FORMAT(birthdate, '%m-%d')       AS birthdate
FROM (
    SELECT *
    FROM hr_database.hr_table
    WHERE termdate IS NULL
) AS a
WHERE MONTH(birthdate) = MONTH(CURRENT_DATE())
ORDER BY birthdate;


-- --------------------------------------------------
-- Q4) Male & Female Contribution in Total Salary by Year
-- --------------------------------------------------

SELECT
    YEAR(hiredate)                                                          AS years,
    ROUND(100 * SUM(CASE WHEN gender = 'Male'   THEN salary END) / SUM(salary), 1) AS male,
    ROUND(100 * SUM(CASE WHEN gender = 'Female' THEN salary END) / SUM(salary), 1) AS female,
    FORMAT_NUMBER(SUM(salary))                                              AS total_salary
FROM hr_database.hr_table
GROUP BY years
ORDER BY years;






