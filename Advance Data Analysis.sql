-- ==================================================
-- ============================ ADVANCE DATA ANALYSIS
-- ==================================================

-- USER DEFINE FUCNTION 
USE hr_database;
DELIMITER $$
CREATE FUNCTION TOMILLION(varia FLOAT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE variable VARCHAR(50);

    SET variable = IF(varia >= 1000000000, CONCAT(ROUND(varia/1000000000,2)," B"),
                   IF(varia >= 1000000, CONCAT(ROUND(varia/1000000,2)," M" ),
                   IF(varia >= 1000, CONCAT(ROUND(varia/1000,2)," K" ), ROUND(varia,2))));
    
    RETURN variable;
END$$
DELIMITER ;

-- --------------------------------------------------
-- ========================== CHANGE-OVER-TIME TRENDS
-- --------------------------------------------------

-- Q1) Hire & Terminated Male & Female Employee by Year
-- Q2) Hired & Terminated Employee by Month
-- Q3) Hired & Terminated Employee by Year & Month
-- Q4) Working Employee Birthday Year
-- Q5) Working Employee Birthday Month
-- Q6) Male & Female Contribution in Total Salary by Year
-- Q7) Male & Female Contribution in Total Salary by Month
-- Q8) Total Salary by Year & Month


SELECT * FROM hr_database.hr_table;

-- Q1) Hire & Terminated Male & Female Employee by Year

SELECT 
    Year,
    Hired_Male,
    Hired_Female,
    Hired_Employee,
    Terminated_Male,
    Terminated_Female,
    Terminated_Employee
FROM (
    -- ==== Hired Employee
    SELECT 
        Hire_Year AS Year,
        CONCAT(Round((Hired_Female/Hired_Employee* 100),1),"%") AS Hired_Female,
        CONCAT(Round((Hired_Male/Hired_Employee* 100),1),"%") AS Hired_Male,
        Hired_Employee
    FROM (
        SELECT 
            YEAR(hiredate) AS Hire_Year,
            COUNT(employee_id) AS Hired_Employee
        FROM hr_database.hr_table
        GROUP BY Hire_year
        ORDER BY Hire_Year
    ) AS table1
    LEFT JOIN (
        SELECT 
            YEAR(hiredate) AS Hire_Year1,
            gender,
            COUNT(employee_id) AS Hired_Female
        FROM hr_database.hr_table
        GROUP BY Hire_year1, gender
        HAVING gender = "Female"
        ORDER BY Hire_Year1
        ) AS table2
        ON table1.Hire_Year = table2.Hire_Year1
        LEFT JOIN (
        SELECT 
            YEAR(hiredate) AS Hire_Year2,
            gender,
            COUNT(employee_id) AS Hired_Male
        FROM hr_database.hr_table
        GROUP BY Hire_year2, gender
        HAVING gender = "Male"
        ORDER BY Hire_Year2
        ) AS table3
        ON table2.Hire_Year1 = table3.Hire_Year2
    ) table1
    -- ==== Terminated Employee
LEFT JOIN (
    SELECT 
        Terminated_Year AS Year1,
        CONCAT(Round((Terminated_Female/Terminated_Employee* 100),1),"%") AS Terminated_Female,
        CONCAT(Round((Terminated_Male/Terminated_Employee* 100),1),"%") AS Terminated_Male,
        Terminated_Employee
    FROM (
        SELECT 
            YEAR(termdate) AS Terminated_Year,
            COUNT(employee_id) AS Terminated_Employee
        FROM hr_database.hr_table
        GROUP BY Terminated_Year
        ORDER BY Terminated_Year
    ) AS table1
    LEFT JOIN (
        SELECT 
            YEAR(termdate) AS Terminated_Year1,
            gender,
            COUNT(employee_id) AS Terminated_Female
        FROM hr_database.hr_table
        GROUP BY Terminated_Year1, gender
        HAVING gender = "Female"
        ORDER BY Terminated_Year1
        ) AS table2
        ON table1.Terminated_Year = table2.Terminated_Year1
    LEFT JOIN (
        SELECT 
            YEAR(termdate) AS Terminated_Year2,
            gender,
            COUNT(employee_id) AS Terminated_Male
        FROM hr_database.hr_table
        GROUP BY Terminated_Year2, gender
        HAVING gender = "Male"
        ORDER BY Terminated_Year2
    ) AS table3
    ON table1.Terminated_Year = table3.Terminated_Year2
    WHERE Terminated_Year IS NOT NULL
    ) AS table2
ON table1.Year = table2.Year1;


-- Q2) Hired & Terminated Employee by Month

SELECT 
Hire_Month AS Month,
Hired_Employee,
Terminated_Employee
FROM (
SELECT 
MONTH(hiredate) AS Hire_Month,
COUNT(employee_id) AS Hired_Employee
FROM hr_database.hr_table
GROUP BY Hire_Month
HAVING Hire_Month IS NOT NULL
ORDER BY Hire_Month ASC) AS table1
LEFT JOIN (
SELECT 
MONTH(termdate) AS Terminated_Month,
COUNT(employee_id) AS Terminated_Employee
FROM hr_database.hr_table
GROUP BY Terminated_Month
HAVING Terminated_Month IS NOT NULL
ORDER BY Terminated_Month ASC) AS table2
ON table1.Hire_Month = table2.Terminated_Month


-- Q3) Hired & Terminated Employee by Year & Month

SELECT 
    Hire_Year,
    Hire_Month,
    Hire_Employee,
    Terminated_Employee
FROM (
    SELECT 
        CONCAT(Hire_Year, Hire_Month) AS Hire_id,
        Hire_Year,
        Hire_Month,
        Hire_Employee
    FROM (
        SELECT 
            YEAR(hiredate) AS Hire_Year,
            MONTH(hiredate) AS Hire_Month,
            COUNT(employee_id) AS Hire_Employee
        FROM hr_database.hr_table
        GROUP BY Hire_year, Hire_Month
        ORDER BY Hire_Year, Hire_Month ASC
    ) AS hire_table_one
) AS hire_table_two
LEFT JOIN (
    SELECT 
        CONCAT(Terminated_Year,Terminated_Month) AS Term_id,
        Terminated_Employee
    FROM (
        SELECT 
            YEAR(termdate) AS Terminated_Year,
            MONTH(termdate) AS Terminated_Month,
            COUNT(employee_id) AS Terminated_Employee
        FROM hr_database.hr_table
        GROUP BY Terminated_Year, Terminated_Month
        HAVING Terminated_Year IS NOT NULL
        ORDER BY Terminated_Year, Terminated_Month ASC
    ) AS term_table_one
) AS term_table_two
ON hire_table_two.Hire_id = term_table_two.Term_id


-- Q4) Working Employee Birthday Year

WITH table1 AS (
    SELECT * FROM hr_database.hr_table
    WHERE termdate IS NOT NULL
)
SELECT YEAR(birthdate) AS Birthyear,
COUNT(employee_id) AS Working_Employee
FROM table1
GROUP BY Birthyear;


-- Q5) Working Employee Birthday Month
WITH table1 AS (
    SELECT * FROM hr_database.hr_table
    WHERE termdate IS NOT NULL
)
SELECT Month(birthdate) AS Birthmonth,
COUNT(employee_id) AS Working_Employee
FROM table1
GROUP BY Birthmonth
ORDER BY Birthmonth ASC;


-- Q6) Male & Female Contribution in Total Salary by Year

USE hr_database;
SELECT 
Year,
CONCAT(Round((Male_Salary/Total_Salary* 100),2),"%") AS Male,
CONCAT(Round((Female_Salary/Total_Salary* 100),2),"%") AS Female,
TOMILLION(Total_Salary) AS Total_Salary
FROM (
SELECT 
    ROW_NUMBER() OVER(ORDER BY YEAR(hiredate)) AS num,
    YEAR(hiredate) AS Year,
    SUM(salary) AS Total_Salary
FROM hr_database.hr_table
GROUP BY Year) AS table1
LEFT JOIN (
SELECT 
    ROW_NUMBER() OVER(ORDER BY YEAR(hiredate)) AS num1,
    YEAR(hiredate) AS Year1,
    gender,
    SUM(salary) AS Male_Salary
FROM hr_database.hr_table
GROUP BY Year1, gender
HAVING gender = "Male") AS table2
ON table1.num = table2.num1
LEFT JOIN (
SELECT 
    ROW_NUMBER() OVER(ORDER BY YEAR(hiredate)) AS num2,
    YEAR(hiredate) AS Year2,
    gender,
    SUM(salary) AS Female_Salary
FROM hr_database.hr_table
GROUP BY Year2, gender
HAVING gender = "Female") AS table3
ON table2.num1 = table3.num2


-- Q7) Male & Female Contribution in Total Salary by Month
USE hr_database;
SELECT 
Month,
CONCAT(Round((Male_Salary/Total_Salary* 100),2),"%") AS Male,
CONCAT(Round((Female_Salary/Total_Salary* 100),2),"%") AS Female,
TOMILLION(Total_Salary) AS Total_Salary
FROM (
SELECT 
    ROW_NUMBER() OVER(ORDER BY MONTH(hiredate)) AS num,
    MONTH(hiredate) AS Month,
    SUM(salary) AS Total_Salary
FROM hr_database.hr_table
GROUP BY Month) AS table1
LEFT JOIN (
SELECT 
    ROW_NUMBER() OVER(ORDER BY MONTH(hiredate)) AS num1,
    MONTH(hiredate) AS Month1,
    gender,
    SUM(salary) AS Male_Salary
FROM hr_database.hr_table
GROUP BY Month1, gender
HAVING gender = "Male") AS table2
ON table1.num = table2.num1
LEFT JOIN (
SELECT 
    ROW_NUMBER() OVER(ORDER BY MONTH(hiredate)) AS num2,
    MONTH(hiredate) AS Month2,
    gender,
    SUM(salary) AS Female_Salary
FROM hr_database.hr_table
GROUP BY Month2, gender
HAVING gender = "Female") AS table3
ON table2.num1 = table3.num2;

SELECT * FROM hr_database.hr_table;

-- Q8) Total Salary by Year & Month
USE hr_database;
SELECT
YEAR(hiredate) AS Year,
 MONTH(hiredate) AS Month,
 TOMILLION(SUM(salary)) AS Total_Salary
FROM hr_database.hr_table
GROUP BY Year, Month
ORDER BY Year;





























