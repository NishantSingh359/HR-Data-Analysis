-- ==================================================
-- MEASURES EXPLORATION
-- ==================================================

SELECT 'Total Hired Employees',      COUNT(DISTINCT employee_id) AS value FROM Human_Resource.Data
UNION
SELECT 'Total Working Employees',    COUNT(employee_id)          AS value FROM Human_Resource.Data WHERE termdate IS NULL
UNION
SELECT 'Total Terminated Employees', COUNT(employee_id)          AS value FROM Human_Resource.Data WHERE termdate IS NOT NULL
UNION
SELECT 'Maximum Salary',             MAX(salary)                 AS value FROM Human_Resource.Data
UNION
SELECT 'Minimum Salary',             MIN(salary)                 AS value FROM Human_Resource.Data;