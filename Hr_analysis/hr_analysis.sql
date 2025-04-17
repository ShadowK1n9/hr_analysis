-- hr analysis - table cleanup and transformation

-- date_of_Join field cleanup
SELECT 
	date_of_join,
    str_to_date(date_of_join, '%d-%b-%y') as Cleaned_Year
FROM hr;

SET SQL_SAFE_UPDATES = 0;

UPDATE hr
SET date_of_join = str_to_date(date_of_join, '%d-%b-%y');

-- Age field cleanup
SELECT age,
		ROUND(age,0) as cleaned_age
FROM hr;

UPDATE hr
SET age = ROUND(age,0);

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE hr
MODIFY Date_Of_Join DATE,
MODIFY Age INT;

-- checking for duplicate rows
WITH duplicate_rows as
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY empid, name, education_qualification, date_of_join, job_title, 
					salary, age, leave_balance ORDER BY empId) AS rn
FROM hr
)
SELECT count(*) FROM duplicate_rows WHERE rn > 1;

-- -----------------------------------------------------------------
-- Analysis
/*
1. How many are in each job?
2. Gender break-down of the staff.
3. Age Spread of the staff.
4. Which Jobs pay more.
5.Top 3 earners in each job.
6. Staff growth trend over time.
7. Leave balance analysis.
*/

-- Query 1 (How many are in each job?)
SELECT 
	job_title,
    COUNT(*) As headcount
FROM hr
GROUP BY job_title
ORDER BY headcount DESC;

-- Packaging associate had the highest number of employees
-- while marketing specialist and marketing manager both had the lowest number of employees
-- (10 in each department)

-- Query 2 (Gender breakdown of each staff)
-- General gender Breakdown
SELECT gender,
count(*) as Headcount,
Round(count(gender)/(SELECT count(*) FROM hr) * 100,2)as Percent
FROM hr
group by gender;

-- Census revealed more female staffs than male staffs overall

-- Gender breakdown by Job_title
SELECT Job_title,
gender,
Round(count(gender)/(SELECT count(*) FROM hr) * 100,2)as Percent
FROM hr
group by job_title, gender
ORDER BY job_title, gender;

-- Census reveled more female staffs in each job than male staff

-- Query 3 (Age Spread of Staff)
-- Checking the youngest and oldest age of our staff
SELECT max(age), min(age)
FROM hr;

SELECT
	CASE
			WHEN age BETWEEN 24 AND 34 THEN 'Youth (24-34)'
            WHEN age BETWEEN 35 AND 44 THEN 'Middle-Aged (35-44)'
            WHEN age BETWEEN 45 AND 54 THEN 'Adults (45-54)'
            ELSE 'Senior(>54)'
		END AS Age_Category,
        Count(*) As Headcount
FROM hr
GROUP BY Age_Category;

-- Query 4 (Which Job pays more?)
SELECT 
	job_title,
    COUNT(*) AS Headcount,
    AVG(salary) AS Average_Salary,
    Max(salary) AS Highest_Salary,
    Min(salary) AS lowest_Salary
FROM hr
GROUP BY 1
ORDER BY Average_Salary DESC;

-- Query 5 (5.Top 3 earners in each job.)
-- using a CTE
WITH ranked_salaries as
(
SELECT 
	empId, 
	name, 
	job_title, 
	salary,
    Dense_rank() OVER(PARTITION BY job_title ORDER BY salary DESC) AS Salary_Rank
FROM hr
)
SELECT * FROM ranked_salaries
WHERE salary_rank <= 3;

-- using a derived table
SELECT * 
FROM (SELECT 
		empId, 
		name, 
		job_title, 
		salary,
		Dense_rank() OVER(PARTITION BY job_title ORDER BY salary DESC) AS Salary_Rank
		FROM hr) as ranked_salaries
WHERE salary_rank <=3;

-- Query 6 (Staff growth trend over time.)
-- The query shows the staff growth of the company over the years broken down by each month for each year
SELECT 
	Year(date_of_join) AS Join_year,
    month(date_of_join) as Join_Month,
    Monthname(date_of_join) as Month_name,
    COUNT(*) as Headcount,
    SUM(COUNT(*)) OVER(ORDER BY Year(Date_Of_Join), month(date_of_join)) as Cummulative_Headcount
FROM hr
GROUP BY Join_year, Join_Month, Month_name
ORDER BY Join_year, join_month;

-- Query 7 (Leave Balance Analysis)
-- 1st Analysis: Average Leave balance for each job
-- 2nd Analysis: How many people in the organization have a leave balance > 20 (This shows the number
-- 				of staff that are being overworked in the company). This will be broken down by each job.

-- 1st Analysis:
SELECT 
	job_title, 
    ROUND(Avg(Leave_balance)) AS Average_Leave_Balance
FROM hr
GROUP BY job_title
ORDER BY Average_Leave_Balance DESC;

-- 2nd Analysis:
SELECT
	job_title,
    COUNT(*) AS HeadCount
FROM hr
WHERE leave_balance > 20
GROUP BY job_title
ORDER BY HeadCount DESC;
						

        

	
