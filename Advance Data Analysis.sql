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

-- --------------------------------------------------
-- ============================== CUMULATIVE ANALYSIS
-- --------------------------------------------------

SELECT * FROM hr_database.hr_table;

-- Q1) Cumulative Hired & Terminated Employee by Year
-- Q2) Cumulative Hire & Terminated Employee by Year & Month


-- Q1) Cumulative Hired & Terminated Employee by Year

SELECT 
    Hire_Year AS Year,
    Hire_Employee,
    Cumulative_Hire_Emp,
    Terminated_Employee,
    Cumulative_Terminated_Emp
FROM (
    SELECT 
    Hire_Year,
    Hire_Employee,
    SUM(Hire_Employee) OVER(ORDER BY Hire_Year) AS Cumulative_Hire_Emp
    FROM (
        SELECT 
            YEAR(hiredate) AS Hire_Year,
            COUNT(employee_id)  AS Hire_Employee
        FROM hr_database.hr_table
        GROUP BY Hire_Year
        ORDER BY Hire_Year
    ) hire_table_one
) hire_table_two
LEFT JOIN (
    SELECT 
    Terminated_Year,
    Terminated_Employee,
    SUM(Terminated_Employee) OVER(ORDER BY Terminated_Year) AS Cumulative_Terminated_Emp
    FROM (
        SELECT 
            YEAR(termdate) AS Terminated_Year,
            COUNT(employee_id)  AS Terminated_Employee
        FROM hr_database.hr_table
        GROUP BY Terminated_Year
        HAVING Terminated_Year IS NOT NULL
        ORDER BY Terminated_Year
    ) term_table_one
) term_table_two
ON hire_table_two.Hire_Year = term_table_two.Terminated_Year


-- Q2) Cumulative Hire & Terminated Employee by Year & Month

SELECT 
    Hire_Year,
    Hire_Month,
    Hire_Employee,
    Cumulative_Hire_Emp,
    Terminated_Employee,
    Cumulative_Terminated_Emp
FROM (
    SELECT 
        CONCAT(Hire_Year, Hire_Month) AS Hire_Id,
        Hire_Year,
        Hire_Month,
        Hire_Employee,
        SUM(Hire_Employee) OVER(ORDER BY Hire_Year, Hire_Month) AS Cumulative_Hire_Emp
    FROM (
    SELECT 
        YEAR(hiredate) AS Hire_Year,
        MONTH(hiredate) AS Hire_Month,
        COUNT(employee_id)  AS Hire_Employee
    FROM hr_database.hr_table
    GROUP BY Hire_Year, Hire_Month
    ORDER BY Hire_Year
    ) hire_table_one
) AS hire_table_two
LEFT JOIN (
    SELECT 
        CONCAT(Terminated_Year, Terminated_Month) AS Terminated_Id,
        Terminated_Year,
        Terminated_Month,
        Terminated_Employee,
        SUM(Terminated_Employee) OVER(ORDER BY Terminated_Year, Terminated_Month) AS Cumulative_Terminated_Emp
    FROM (
    SELECT 
        YEAR(termdate) AS Terminated_Year,
        MONTH(termdate) AS Terminated_Month,
        COUNT(employee_id)  AS Terminated_Employee
    FROM hr_database.hr_table
    GROUP BY Terminated_Year, Terminated_Month
    HAVING Terminated_Year IS NOT NULL
    ORDER BY Terminated_Year
    ) terminated_table_one
) AS terminated_table_two
ON hire_table_two.Hire_Id = terminated_table_two.Terminated_Id


-- --------------------------------------------------
-- ============================= PERFORMANCE ANALYSIS
-- --------------------------------------------------


-- Q1) Top Highest Payed Employes Performance
-- Q2) Department with Employes Performance
-- Q3) Employes Performance with Education Lavel
-- Q4) Gender with Performance


-- Q1) Top Highest Payed Employes Performance

-- Top 10

WITH highest_payed AS (
    SELECT 
        employee_id,
        performance_rating
    FROM hr_database.hr_table
    ORDER BY salary DESC
    LIMIT 10
)
SELECT 
performance_rating AS Performance,
COUNT(employee_id) AS Employee
FROM highest_payed 
GROUP BY performance_rating
ORDER BY Employee DESC;

-- Top 50
WITH highest_payed AS (
    SELECT 
        employee_id,
        performance_rating
    FROM hr_database.hr_table
    ORDER BY salary DESC
    LIMIT 50
)
SELECT 
performance_rating AS Performance,
COUNT(employee_id) AS Employee
FROM highest_payed 
GROUP BY performance_rating
ORDER BY Employee DESC;


-- Q2) Department with Employes Performance

SELECT 
    Ex_Department AS Department,
    CONCAT(ROUND(Excellent_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Excellent_Emp,
    CONCAT(ROUND(Good_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp) *100,1),"%") AS Good_Emp,
    CONCAT(ROUND(Satisfactory_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Satisfactory_Emp,
    CONCAT(ROUND(Needs_Improvement_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Needs_Improvement_Emp,
    (Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp) AS Total_Emp
FROM (
    SELECT 
        department AS Ex_Department,
        performance_rating AS Excellent,
        COUNT(employee_id) AS Excellent_Emp
    FROM hr_database.hr_table
    GROUP BY department, performance_rating
    HAVING performance_rating = "Excellent\r"
    ORDER BY department ASC
) ex_table
LEFT JOIN (
    SELECT 
        department AS Go_Department,
        performance_rating AS Good,
        COUNT(employee_id) AS Good_Emp
    FROM hr_database.hr_table
    GROUP BY department, performance_rating
    HAVING performance_rating = "Good\r"
    ORDER BY department ASC
) go_table
ON ex_table.Ex_department = go_table.Go_Department
LEFT JOIN (
    SELECT 
        department AS Sa_Department,
        performance_rating AS Satisfactory,
    COUNT(employee_id) AS Satisfactory_Emp
    FROM hr_database.hr_table
    GROUP BY department, performance_rating
    HAVING performance_rating = "Satisfactory\r"
    ORDER BY department ASC
) sa_table
ON ex_table.Ex_department = sa_table.Sa_Department
LEFT JOIN (
    SELECT 
        department AS Ni_Department,
        performance_rating AS Needs_Improvement,
        COUNT(employee_id) AS Needs_Improvement_Emp
    FROM hr_database.hr_table
    GROUP BY department, performance_rating
    HAVING performance_rating = "Needs Improvement\r"
    ORDER BY department ASC
) ni_table
ON ex_table.Ex_Department = ni_table.Ni_Department
UNION
SELECT 
    'Total_Emp' AS Department,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Excellent\r") AS Excellent_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Good\r") AS Good_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Satisfactory\r") AS Satisfactory_Emp ,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Needs Improvement\r") AS Needs_Improvement_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table) AS Total_Emp
    

-- Q3) Education Lavel with Employes Performance

SELECT 
    Ex_Education AS Education,
    CONCAT(ROUND(Excellent_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Excellent_Emp,
    CONCAT(ROUND(Good_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp) *100,1),"%") AS Good_Emp,
    CONCAT(ROUND(Satisfactory_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Satisfactory_Emp,
    CONCAT(ROUND(Needs_Improvement_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Needs_Improvement_Emp,
    (Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp) AS Total_Emp
FROM (
    SELECT 
        education_lavel AS Ex_Education,
        performance_rating AS Excellent,
        COUNT(employee_id) AS Excellent_Emp
    FROM hr_database.hr_table
    GROUP BY education_lavel, performance_rating
    HAVING performance_rating = "Excellent\r"
    ORDER BY education_lavel ASC
) ex_table
LEFT JOIN (
    SELECT 
        education_lavel AS Go_Education,
        performance_rating AS Good,
        COUNT(employee_id) AS Good_Emp
    FROM hr_database.hr_table
    GROUP BY education_lavel, performance_rating
    HAVING performance_rating = "Good\r"
    ORDER BY education_lavel ASC
) go_table
ON ex_table.Ex_Education = go_table.Go_Education
LEFT JOIN (
    SELECT 
        education_lavel AS Sa_Education,
        performance_rating AS Satisfactory,
        COUNT(employee_id) AS Satisfactory_Emp
    FROM hr_database.hr_table
    GROUP BY education_lavel, performance_rating
    HAVING performance_rating = "Satisfactory\r"
    ORDER BY education_lavel ASC
) sa_table
ON ex_table.Ex_Education = sa_table.Sa_Education
LEFT JOIN (
    SELECT 
        education_lavel AS Ni_Education,
        performance_rating AS Needs_Improvement,
        COUNT(employee_id) AS Needs_Improvement_Emp
    FROM hr_database.hr_table
    GROUP BY education_lavel, performance_rating
    HAVING performance_rating = "Needs Improvement\r"
    ORDER BY education_lavel ASC
) ni_table
ON ex_table.Ex_Education = ni_table.Ni_Education
UNION
SELECT 
    'Total_Emp' AS Education,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Excellent\r") AS Excellent_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Good\r") AS Good_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Satisfactory\r") AS Satisfactory_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Needs Improvement\r") AS Needs_Improvement_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table) AS Total_Emp;


-- Q4) Gender with Performance 

SELECT 
    Ex_Gender AS Gender,
    CONCAT(ROUND(Excellent_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Excellent_Emp,
    CONCAT(ROUND(Good_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp) *100,1),"%") AS Good_Emp,
    CONCAT(ROUND(Satisfactory_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Satisfactory_Emp,
    CONCAT(ROUND(Needs_Improvement_Emp/(Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp)*100,1),"%") AS Needs_Improvement_Emp,
    (Excellent_Emp + Good_Emp + Satisfactory_Emp + Needs_Improvement_Emp) AS Total_Emp
FROM (
    SELECT 
        gender AS Ex_Gender,
        performance_rating AS Excellent,
        COUNT(employee_id) AS Excellent_Emp
    FROM hr_database.hr_table
    GROUP BY gender, performance_rating
    HAVING performance_rating = "Excellent\r"
    ORDER BY gender ASC
) ex_table
LEFT JOIN (
    SELECT 
        gender AS Go_Gender,
        performance_rating AS Good,
        COUNT(employee_id) AS Good_Emp
    FROM hr_database.hr_table
    GROUP BY gender, performance_rating
    HAVING performance_rating = "Good\r"
    ORDER BY gender ASC
) go_table
ON ex_table.Ex_Gender = go_table.Go_Gender
LEFT JOIN (
    SELECT 
        gender AS Sa_Gender,
        performance_rating AS Satisfactory,
        COUNT(employee_id) AS Satisfactory_Emp
    FROM hr_database.hr_table
    GROUP BY gender, performance_rating
    HAVING performance_rating = "Satisfactory\r"
    ORDER BY gender ASC
) sa_table
ON ex_table.Ex_Gender = sa_table.Sa_Gender
LEFT JOIN (
    SELECT 
        gender AS Ni_Gender,
        performance_rating AS Needs_Improvement,
        COUNT(employee_id) AS Needs_Improvement_Emp
    FROM hr_database.hr_table
    GROUP BY gender, performance_rating
    HAVING performance_rating = "Needs Improvement\r"
    ORDER BY gender ASC
) ni_table
ON ex_table.Ex_Gender = ni_table.Ni_Gender
UNION
SELECT 
    'Total_Emp' AS Gender,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Excellent\r") AS Excellent_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Good\r") AS Good_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Satisfactory\r") AS Satisfactory_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE performance_rating = "Needs Improvement\r") AS Needs_Improvement_Emp,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table) AS Total_Emp;


-- --------------------------------------------------
-- ==================================== PART-TO-WHOLE
-- --------------------------------------------------