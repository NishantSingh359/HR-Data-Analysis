-- ==================================================
-- CUMULATIVE ANALYSIS
-- ==================================================
-- Q1) Cumulative Hired & Terminated Employees by Year
-- Q2) Cumulative Hired & Terminated Employees by Year & Month
-- ==================================================


-- --------------------------------------------------
-- Q1) Cumulative Hired & Terminated Employees by Year
-- --------------------------------------------------

SELECT
    hired_years,
    SUM(hired_employees)      OVER (ORDER BY hired_years ASC)      AS cumulative_hired_emp,
    SUM(terminated_employees) OVER (ORDER BY terminated_years ASC) AS cumulative_terminated_emp
FROM (
    SELECT
        YEAR(hiredate)       AS hired_years,
        COUNT(employee_id)   AS hired_employees
    FROM Human_Resource.Data
    GROUP BY hired_years
) AS table1
LEFT JOIN (
    SELECT
        YEAR(termdate)       AS terminated_years,
        COUNT(employee_id)   AS terminated_employees
    FROM Human_Resource.Data
    GROUP BY terminated_years
) AS table2
    ON hired_years = terminated_years;


-- --------------------------------------------------
-- Q2) Cumulative Hired & Terminated Employees by Year & Month
-- --------------------------------------------------

SELECT
    hire_year,
    hire_month,
    SUM(hire_emp) OVER (ORDER BY hire_year, hire_month ASC) AS cumulative_hired_emp,
    SUM(term_emp) OVER (ORDER BY term_year, term_month ASC) AS cumulative_term_emp
FROM (
    SELECT
        YEAR(hiredate)     AS hire_year,
        MONTH(hiredate)    AS hire_month,
        COUNT(employee_id) AS hire_emp
    FROM Human_Resource.Data
    GROUP BY hire_year, hire_month
) AS table1
LEFT JOIN (
    SELECT
        YEAR(termdate)     AS term_year,
        MONTH(termdate)    AS term_month,
        COUNT(employee_id) AS term_emp
    FROM Human_Resource.Data
    GROUP BY term_year, term_month
) AS table2
    ON CONCAT(hire_year, hire_month) = CONCAT(term_year, term_month)
ORDER BY hire_year, hire_month;