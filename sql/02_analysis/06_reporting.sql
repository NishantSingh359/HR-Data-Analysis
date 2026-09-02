-- ==================================================
-- REPORTING
-- ==================================================
-- Q1) Create Working Employees Report
-- Q2) Create Terminated Employees Report
-- ==================================================


-- --------------------------------------------------
-- Q1) Create Working Employees Report
-- --------------------------------------------------

SELECT
    employee_id                                          AS employee_id,
    CONCAT_WS(' ', first_name, last_name)                AS name,
    gender                                               AS gender,
    CONCAT_WS(' ', (YEAR(CURDATE()) - 1) - YEAR(birthdate), 'Years') AS age,
    birthdate                                            AS birth_date,
    education_level                                      AS education,
    city                                                 AS city,
    state                                                AS state,
    hiredate                                             AS hire_date,
    job_title                                            AS job,
    department                                           AS department,
    CASE
        WHEN (YEAR(CURDATE()) - YEAR(hiredate)) = 0
            THEN CONCAT_WS(' ', MONTH(CURDATE()) - MONTH(hiredate), 'Months')
        ELSE CONCAT_WS(' ', YEAR(CURDATE()) - YEAR(hiredate), 'Years')
    END                                                  AS experience,
    performance_rating                                   AS performance,
    CASE
        WHEN salary BETWEEN  50000 AND  70000 THEN 'Low Salary'
        WHEN salary BETWEEN  70001 AND 100000 THEN 'Middle Salary'
        WHEN salary BETWEEN 100001 AND 130000 THEN 'Upper Middle Salary'
        WHEN salary BETWEEN 130001 AND 150000 THEN 'High Salary'
        ELSE salary
    END                                                  AS salary_category,
    salary                                               AS salary
FROM Human_Resource.Data
WHERE termdate IS NULL;


-- --------------------------------------------------
-- Q2) Create Terminated Employees Report
-- --------------------------------------------------

SELECT
    employee_id                                          AS employee_id,
    CONCAT_WS(' ', first_name, last_name)                AS name,
    gender                                               AS gender,
    CONCAT_WS(' ', (YEAR(CURDATE()) - 1) - YEAR(birthdate), 'Years') AS current_age,
    birthdate                                            AS birth_date,
    education_level                                      AS education,
    city                                                 AS city,
    state                                                AS state,
    hiredate                                             AS hire_date,
    termdate                                             AS terminated_date,
    CONCAT_WS(' ', YEAR(termdate) - YEAR(birthdate), 'Years') AS terminated_age,
    job_title                                            AS job,
    department                                           AS department,
    CASE
        WHEN (YEAR(termdate) - YEAR(hiredate)) = 0
            THEN CONCAT_WS(' ', MONTH(termdate) - MONTH(hiredate), 'Months')
        ELSE CONCAT_WS(' ', YEAR(termdate) - YEAR(hiredate), 'Years')
    END                                                  AS experience,
    performance_rating                                   AS performance,
    CASE
        WHEN salary BETWEEN  50000 AND  70000 THEN 'Low Salary'
        WHEN salary BETWEEN  70001 AND 100000 THEN 'Middle Salary'
        WHEN salary BETWEEN 100001 AND 130000 THEN 'Upper Middle Salary'
        WHEN salary BETWEEN 130001 AND 150000 THEN 'High Salary'
        ELSE salary
    END                                                  AS salary_category,
    salary                                               AS salary
FROM Human_Resource.Data
WHERE termdate IS NOT NULL;