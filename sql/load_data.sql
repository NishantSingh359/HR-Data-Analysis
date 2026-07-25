-- Active: 1758763009265@@127.0.0.1@3306@hr_database

-- Create Database
------------------
DROP DATABASE IF EXISTS hr_database;
CREATE DATABASE hr_database;

-- Create Table
---------------
CREATE TABLE hr_database.hr_table(
    employee_id VARCHAR(70),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(20),
    state VARCHAR(50),
    city VARCHAR(50),
    education_level VARCHAR(50),
    birthdate DATE,
    hiredate DATE,
    termdate DATE,
    department VARCHAR(50),
    job_title VARCHAR(50),
    salary FLOAT,
    performance_rating VARCHAR(50)
);
SHOW VARIABLES LIKE "secure_file_priv";
-- Load Data
------------
TRUNCATE TABLE hr_database.hr_table;
LOAD DATA local INFILE 'C:/Users/TUF/OneDrive/Documents/Code/MY SQL/HR-Project/data/HumanResource.csv'
INTO TABLE hr_database.hr_table
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@employee_id, @first_name, @last_name, @gender, @state, @city, @education_level, @birthdate,@hiredate, @termdate, @department, @job_title, @salary, @performance_rating)
SET
employee_id = NULLIF(@employee_id,''),
first_name = NULLIF(@first_name,''),
last_name = NULLIF(@last_name,''),
gender = NULLIF(@gender,''),
state = NULLIF(@state,''),
city = NULLIF(@city,''),
education_level = NULLIF(@education_level,''),
birthdate = STR_TO_DATE(@birthdate,"%d/%m/%Y"),
hiredate = STR_TO_DATE(@hiredate,"%d/%m/%Y"),
termdate = STR_TO_DATE(NULLIF(@termdate,""),"%d/%m/%Y"),
department = NULLIF(@department,''),
job_title = NULLIF(@job_title,''),
salary = NULLIF(@salary,''),
performance_rating = REPLACE(NULLIF(@performance_rating,''),"\r","");
