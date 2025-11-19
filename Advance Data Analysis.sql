-- ==================================================
-- ============================ ADVANCE DATA ANALYSIS
-- ==================================================


-- --------------------------------------------------
-- ========================== CHANGE-OVER-TIME TRENDS
-- --------------------------------------------------

SELECT * FROM hr_database.hr_table;

-- Hire & Terminated Employee by Year

SELECT 
YEAR(hiredate) AS Hire_Year,
COUNT(employee_id) AS Hired_Employee
FROM hr_database.hr_table
GROUP BY Hire_year;


SELECT 
YEAR(termdate) AS Terminated_Year,
COUNT(employee_id) AS Terminated_Employee
FROM hr_database.hr_table
GROUP BY Terminated_Year
HAVING Terminated_Year IS NOT NULL;


-- Hired & Terminated Employee by Month

SELECT 
MONTH(hiredate) AS Hire_Month,
COUNT(employee_id) AS Hired_Employee
FROM hr_database.hr_table
GROUP BY Hire_Month
HAVING Hire_Month IS NOT NULL
ORDER BY Hire_Month ASC;


SELECT 
MONTH(termdate) AS Terminated_Month,
COUNT(employee_id) AS Terminated_Employee
FROM hr_database.hr_table
GROUP BY Terminated_Month
HAVING Terminated_ IS NOT NULL
ORDER BY Terminated_Month ASC;


-- Hired & Terminated Employee by Year & Month

SELECT 
YEAR(hiredate) AS Hire_Year,
MONTH(hiredate) AS Hire_Month,
COUNT(employee_id) AS Hired_Employee
FROM hr_database.hr_table
GROUP BY Hire_year, Hire_Month
ORDER BY Hire_Year, Hire_Month ASC;


SELECT 
YEAR(termdate) AS Terminated_Year,
MONTH(termdate) AS Terminated_Month,
COUNT(employee_id) AS Terminated_Employee
FROM hr_database.hr_table
GROUP BY Terminated_Year, Terminated_Month
HAVING Terminated_Year IS NOT NULL
ORDER BY Terminated_Year, Terminated_Month ASC;


-- Working Employee Birthday Year

WITH table1 AS (
    SELECT * FROM hr_database.hr_table
    WHERE termdate IS NOT NULL
)
SELECT YEAR(birthdate) AS Birthyear,
COUNT(employee_id) AS Working_Employee
FROM table1
GROUP BY Birthyear;


-- Working Employee Birthday Month
WITH table1 AS (
    SELECT * FROM hr_database.hr_table
    WHERE termdate IS NOT NULL
)
SELECT Month(birthdate) AS Birthmonth,
COUNT(employee_id) AS Working_Employee
FROM table1
GROUP BY Birthmonth
ORDER BY Birthmonth ASC;


-- Total Salary by Year







