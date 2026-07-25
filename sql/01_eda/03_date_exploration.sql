-- ==================================================
-- DATE EXPLORATION
-- ==================================================


-- --------------------------------------------------
-- First and Last Hire Date
-- --------------------------------------------------

SELECT
    MIN(hiredate)                                        AS first_hire_date,
    MAX(hiredate)                                        AS last_hire_date,
    TIMESTAMPDIFF(YEAR, MIN(hiredate), MAX(hiredate))    AS time_span  -- years
FROM hr_database.hr_table;


-- --------------------------------------------------
-- First and Last Term Date
-- --------------------------------------------------

SELECT
    MIN(termdate)                                        AS first_term_date,
    MAX(termdate)                                        AS last_term_date,
    TIMESTAMPDIFF(YEAR, MIN(termdate), MAX(termdate))    AS time_span  -- years
FROM hr_database.hr_table;


-- --------------------------------------------------
-- Youngest and Oldest Employee
-- --------------------------------------------------

SELECT
    MIN(birthdate)                                       AS oldest_birthdate,
    MAX(birthdate)                                       AS youngest_birthdate,
    TIMESTAMPDIFF(YEAR, MIN(birthdate), MAX(birthdate))  AS age_gap    -- years
FROM hr_database.hr_table;