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

-- Q1) Cumulative Hired & Terminated Employee by Year
-- Q2) Cumulative Hire & Terminated Employee by Year & Month


SELECT * FROM hr_database.hr_table;
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
-- Q5) Gender with Education Lavel

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


-- Q5) Gender with Education Lavel.
SELECT 
    Ex_Gender AS Gender,
    CONCAT(ROUND(HS_Emp/(HS_Emp + BA_Emp + MS_Emp + PHD_Emp)*100,1),"%") AS High_School,
    CONCAT(ROUND(BA_Emp/(HS_Emp + BA_Emp + MS_Emp + PHD_Emp)*100,1),"%") AS Bachelor,
    CONCAT(ROUND(MS_Emp/(HS_Emp + BA_Emp + MS_Emp + PHD_Emp)*100,1),"%") AS Master,
    CONCAT(ROUND(PHD_Emp/(HS_Emp + BA_Emp + MS_Emp + PHD_Emp)*100,1),"%") AS Phd,
    (HS_Emp + BA_Emp + MS_Emp + PHD_Emp) AS Total_Emp
FROM (
    SELECT 
        gender AS Ex_Gender,
        education_lavel AS HS_Education,
        COUNT(employee_id) AS HS_Emp
    FROM hr_database.hr_table
    GROUP BY gender, education_lavel
    HAVING HS_Education = "High School"
    ORDER BY gender ASC
) hs_table
LEFT JOIN (
    SELECT 
        gender AS BA_Gender,
        education_lavel AS BA_Education,
        COUNT(employee_id) AS BA_Emp
    FROM hr_database.hr_table
    GROUP BY gender, education_lavel
    HAVING BA_Education = "Bachelor"
    ORDER BY gender ASC
) ba_table
ON hs_table.Ex_Gender = ba_table.BA_Gender
LEFT JOIN (
    SELECT 
        gender AS MS_Gender,
        education_lavel AS MS_Education,
        COUNT(employee_id) AS MS_Emp
    FROM hr_database.hr_table
    GROUP BY gender, education_lavel
    HAVING MS_Education = "Master"
    ORDER BY gender ASC
) ms_table
ON hs_table.Ex_Gender = ms_table.MS_Gender
LEFT JOIN (
    SELECT 
        gender AS PHD_Gender,
        education_lavel AS PHD_Education,
        COUNT(employee_id) AS PHD_Emp
    FROM hr_database.hr_table
    GROUP BY gender, education_lavel
    HAVING PHD_Education = "Phd"
    ORDER BY gender ASC
) phd_table
ON hs_table.Ex_Gender = phd_table.PHD_Gender
UNION
SELECT 
    'Total_Emp' AS Gender,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE education_lavel = "High School") AS High_School,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE education_lavel = "Bachelor") AS Bachelor,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE education_lavel = "Master") AS Master,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table WHERE education_lavel = "Phd") AS Phd,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table) AS Total_Emp;


-- --------------------------------------------------
-- ======================= PART-TO-WHOLE PROPORTIONAL
-- --------------------------------------------------
-- A part-to-whole ratio is a way of expressing the relationship between a part of something and the entire whole.

-- Q1) Number of Hired Employee (Male & Female) by City.
-- Q2) Citys with Hired Employee Performance.
-- Q3) Citys with Hired Employee Education Lavel.


-- Q1) Number of Hired Employee (Male & Female) by City.

SELECT 
    m_city AS City,
    m_employee AS Male_Employee,
    f_employee AS Female_Employee,
    m_employee + f_employee AS Total_Employee
FROM (
    SELECT 
        city AS m_city,
        gender AS m_gender,
        COUNT(employee_id) AS m_employee
    FROM hr_database.hr_table
    GROUP BY m_city, m_gender
    HAVING m_gender = "Male"
    ORDER BY m_city
) male_table
LEFT JOIN (
    SELECT 
        city AS f_city,
        gender AS f_gender,
        COUNT(employee_id) AS f_employee
    FROM hr_database.hr_table
    GROUP BY f_city, f_gender
    HAVING f_gender = "Female"
    ORDER BY f_city
) female_table
ON male_table.m_city = female_table.f_city
ORDER BY Male_Employee DESC;


-- Q2) Citys with Hired Employee Performance.

SELECT
    e_city AS City,
    CONCAT(ROUND(e_employee/(e_employee + g_employee + s_employee + n_employee)*100,1),"%") AS Excellent,
    CONCAT(ROUND(g_employee/(e_employee + g_employee + s_employee + n_employee)*100,1),"%") AS Good,
    CONCAT(ROUND(s_employee/(e_employee + g_employee + s_employee + n_employee)*100,1),"%") AS Satisfaction,
    CONCAT(ROUND(n_employee/(e_employee + g_employee + s_employee + n_employee)*100,1),"%") AS Needs_Improvement,
    (e_employee + g_employee + s_employee + n_employee) AS Total_Emp
FROM (
    SELECT 
        city AS e_city,
        performance_rating AS e_performance,
        COUNT(employee_id) AS e_employee
    FROM hr_database.hr_table
    GROUP BY city, performance_rating
    HAVING performance_rating = "Excellent\r"
    ORDER BY city
) exce_table
LEFT JOIN (
    SELECT 
        city AS g_city,
        performance_rating AS g_performance,
        COUNT(employee_id) AS g_employee
    FROM hr_database.hr_table
    GROUP BY city, performance_rating
    HAVING performance_rating = "Good\r"
    ORDER BY city
) good_table
ON exce_table.e_city = good_table.g_city
LEFT JOIN (
    SELECT 
        city AS s_city,
        performance_rating AS s_performance,
        COUNT(employee_id) AS s_employee
    FROM hr_database.hr_table
    GROUP BY city, performance_rating
    HAVING performance_rating = "Satisfactory\r"
    ORDER BY city
) sati_table
ON exce_table.e_city = sati_table.s_city
LEFT JOIN (
    SELECT 
        city AS n_city,
        performance_rating AS n_performance,
        COUNT(employee_id) AS n_employee
    FROM hr_database.hr_table
    GROUP BY city, performance_rating
    HAVING performance_rating = "Needs Improvement\r"
    ORDER BY city
) need_table
ON exce_table.e_city = need_table.n_city
ORDER BY Total_Emp DESC


-- Q3) Citys with Hired Employee Education Lavel.

SELECT
    hs_city AS City,
    CONCAT(ROUND(hs_employee/(hs_employee + ba_employee + ms_employee + phd_employee)*100,1),"%") AS High_School,
    CONCAT(ROUND(ba_employee/(hs_employee + ba_employee + ms_employee + phd_employee)*100,1),"%") AS Bachelor,
    CONCAT(ROUND(ms_employee/(hs_employee + ba_employee + ms_employee + phd_employee)*100,1),"%") AS Master,
    CONCAT(ROUND(phd_employee/(hs_employee + ba_employee + ms_employee + phd_employee)*100,1),"%") AS Phd,
    (hs_employee + ba_employee + ms_employee + phd_employee) AS Total_Emp
FROM (
    SELECT 
        city AS hs_city,
        education_lavel AS hs_education,
        COUNT(employee_id) AS hs_employee
    FROM hr_database.hr_table
    GROUP BY city, education_lavel
    HAVING hs_education = "High School"
    ORDER BY city
) hs_table
LEFT JOIN (
    SELECT 
        city AS ba_city,
        education_lavel AS ba_education,
        COUNT(employee_id) AS ba_employee
    FROM hr_database.hr_table
    GROUP BY city, education_lavel
    HAVING ba_education = "Bachelor"
    ORDER BY city
) ba_table
ON hs_table.hs_city = ba_table.ba_city
LEFT JOIN (
    SELECT 
        city AS ms_city,
        education_lavel AS ms_education,
        COUNT(employee_id) AS ms_employee
    FROM hr_database.hr_table
    GROUP BY city, education_lavel
    HAVING ms_education = "Master"
    ORDER BY city
) ms_table
ON hs_table.hs_city = ms_table.ms_city
LEFT JOIN (
    SELECT 
        city AS phd_city,
        education_lavel AS phd_education,
        COUNT(employee_id) AS phd_employee
    FROM hr_database.hr_table
    GROUP BY city, education_lavel
    HAVING phd_education = "Phd"
    ORDER BY city
) phd_table
ON hs_table.hs_city = phd_table.phd_city
ORDER BY Total_Emp DESC


-- --------------------------------------------------
-- ================================ DATA SEGMENTATION
-- --------------------------------------------------


-- 1) Group Employee into Categories Based on Their Working Eperience. 
-- Employee Experience 
-- Intern     Intermediate  Mid_lavel  Senior_lavel
-- 1-2 years  2-4 years     4-8 years  8-10+ years

-- Q2) Group Salary into Categories.
-- Salary Categories
-- Low Salary,      Middle Salary,     Upper-Middle Salary  High Salary
-- $50,000-$70,000  $70,001-$100,000  $1,00,001-$1,30,000  $1,30,001-$1,50,000

-- Q3) Employee Experience with Salary Category.


-- 1) Group Employee into Categories on Their Working Eperience. 

WITH table1 AS (
    SELECT *,
        CASE
        WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) BETWEEN 0 AND 2 THEN "Intern"
        WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) BETWEEN 2 AND 4 THEN "Intermediate"
        WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) BETWEEN 4 AND 8 THEN "Mid Lavel"
        WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) > 8 THEN "Senior Lavel"
        ELSE (YEAR(CURDATE())-1) - YEAR(hiredate)
        END AS Working_Experience 
    FROM hr_database.hr_table
),
table2 AS (
    SELECT 
        Working_Experience,
        CONCAT(ROUND(COUNT(employee_id)/(SELECT COUNT(employee_id) FROM hr_database.hr_table)*100,2),"%") AS Employees
    FROM table1
    GROUP BY Working_Experience
    ORDER BY COUNT(employee_id) DESC
)
SELECT * FROM table2
UNION
SELECT
    "Total Employees" AS Working_Experience,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table) AS Employees;


-- Q2) Group Salary into Categories.

WITH table1 AS(
    SELECT *,
        CASE
        WHEN salary BETWEEN 50000 AND 70000 THEN "Low Salary"
        WHEN salary BETWEEN 70001 AND 100000 THEN "Middle Salary"
        WHEN salary BETWEEN 100001 AND 130000 THEN "Upper Middle Salary"
        WHEN salary BETWEEN 130001 AND 150000 THEN "High Salary"
        ELSE salary
        END AS salary_category
    FROM hr_database.hr_table
),
table2 AS ( 
    SELECT 
        IFNULL(salary_category, "Total Employee") AS Salary_Category,
        CONCAT(ROUND(COUNT(employee_id)/(SELECT COUNT(employee_id) FROM hr_database.hr_table)*100,2),"%") AS Employees
    FROM table1
    GROUP BY salary_category
    ORDER BY COUNT(employee_id) DESC
)
SELECT * FROM table2
UNION
SELECT
    "Total Employees" AS Salary_Category,
    (SELECT COUNT(employee_id) FROM hr_database.hr_table) AS Employees;


-- Q3) Employee Experience with Salary Category.

DROP VIEW IF EXISTS emp_exp_slry;
CREATE VIEW  emp_exp_slry AS (
    WITH table1 AS (
        SELECT *,
            CASE
            WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) BETWEEN 0 AND 2 THEN "Intern"
            WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) BETWEEN 2 AND 4 THEN "Intermediate"
            WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) BETWEEN 4 AND 8 THEN "Mid Lavel"
            WHEN (YEAR(CURDATE())-1) - YEAR(hiredate) > 8 THEN "Senior Lavel"
            ELSE (YEAR(CURDATE())-1) - YEAR(hiredate)
            END AS working_experience,
            CASE
            WHEN salary BETWEEN 50000 AND 70000 THEN "Low Salary"
            WHEN salary BETWEEN 70001 AND 100000 THEN "Middle Salary"
            WHEN salary BETWEEN 100001 AND 130000 THEN "Upper Middle Salary"
            WHEN salary BETWEEN 130001 AND 150000 THEN "High Salary"
            ELSE salary
            END AS salary_category 
        FROM hr_database.hr_table
    )
    SELECT * FROM table1
);

SELECT 
    l_working_experience AS Working_Experience,
    l_employees AS Low_Salary,
    m_employees AS Middle_Salary,
    u_employees AS Upper_Middle_Salary,
    h_employees AS High_Salary,
    (l_employees + m_employees + u_employees + IFNULL(h_employees,0)) AS Total_Employees
FROM (
    SELECT 
        working_experience AS l_working_experience,
        salary_category AS l_salary_category,
        COUNT(employee_id) AS l_employees
    FROM emp_exp_slry
    GROUP BY working_experience, salary_category
    HAVING l_salary_category = "Low Salary"
) low_salary_table
LEFT JOIN (
    SELECT 
        working_experience AS m_working_experience,
        salary_category AS m_salary_category,
        COUNT(employee_id) AS m_employees
    FROM emp_exp_slry
    GROUP BY working_experience, salary_category
    HAVING m_salary_category = "Middle Salary"
) middle_salary_table
ON low_salary_table.l_working_experience = middle_salary_table.m_working_experience
LEFT JOIN (
    SELECT 
        working_experience AS u_working_experience,
        salary_category AS u_salary_category,
        COUNT(employee_id) AS u_employees
    FROM emp_exp_slry
    GROUP BY working_experience, salary_category
    HAVING u_salary_category = "Upper Middle Salary"
) upper_salary_table
ON low_salary_table.l_working_experience = upper_salary_table.u_working_experience
LEFT JOIN (
    SELECT 
        working_experience AS h_working_experience,
        salary_category AS h_salary_category,
        COUNT(employee_id) AS h_employees
    FROM emp_exp_slry
    GROUP BY working_experience, salary_category
    HAVING h_salary_category = "High Salary"
) high_salary_table
ON low_salary_table.l_working_experience = high_salary_table.h_working_experience
UNION
SELECT 
"Total Employees" AS Working_Experience,
(SELECT COUNT(employee_id) FROM emp_exp_slry WHERE salary_category = "Low Salary") AS Low_Salary,
(SELECT COUNT(employee_id) FROM emp_exp_slry WHERE salary_category = "Middle Salary") AS Middle_Salary,
(SELECT COUNT(employee_id) FROM emp_exp_slry WHERE salary_category = "Upper Middle Salary") AS Upper_Middle_Salary,
(SELECT COUNT(employee_id) FROM emp_exp_slry WHERE salary_category = "High Salary") AS High_Salary,
(SELECT COUNT(employee_id) FROM emp_exp_slry) AS Total_Employees;
























