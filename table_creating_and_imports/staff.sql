CREATE DATABASE ChocoFactory;
USE Chocofactory;

CREATE TABLE HR
(
	EmpID VARCHAR(8) PRIMARY KEY,
    Name VARCHAR(30),
    Gender VARCHAR(7),
    Education_Qualification VARCHAR(20),
    Date_Of_Join VARCHAR(10),
    Job_Title VARCHAR(20),
    Salary INT,
    Age DECIMAL(3,1),
    Leave_Balance INT
);

LOAD DATA 
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hr-data.csv"
INTO TABLE hr
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;




    
    