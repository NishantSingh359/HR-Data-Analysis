-- ==================================================
-- MEASURES EXPLORATION
-- ==================================================

SELECT 'Total Hired Employees',      COUNT(DISTINCT employee_id) AS value FROM hr_database.hr_table
UNION
SELECT 'Total Working Employees',    COUNT(employee_id)          AS value FROM hr_database.hr_table WHERE termdate IS NULL
UNION
SELECT 'Total Terminated Employees', COUNT(employee_id)          AS value FROM hr_database.hr_table WHERE termdate IS NOT NULL
UNION
SELECT 'Maximum Salary',             MAX(salary)                 AS value FROM hr_database.hr_table
UNION
SELECT 'Minimum Salary',             MIN(salary)                 AS value FROM hr_database.hr_table;