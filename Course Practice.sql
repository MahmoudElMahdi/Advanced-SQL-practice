USE employees;

SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS row_num
FROM 
	salaries;
    


SELECT
	emp_no,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM 
	salaries
LIMIT 1;




SELECT
	emp_no,
    dept_no,
    ROW_NUMBER() OVER (ORDER BY emp_no) AS row_num
FROM
	dept_manager;
    


SELECT
	emp_no,
    first_name,
    last_name,
    ROW_NUMBER() OVER (PARTITION BY first_name ORDER BY last_name DESC) AS row_num
FROM employees;



SELECT 
	dm.emp_no, 
	salary, 
	ROW_NUMBER() OVER () AS row_num1,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS row_num2
FROM dept_manager dm JOIN salaries s ON s.emp_no = dm.emp_no
ORDER BY row_num1, emp_no, salary ASC;



SELECT

dm.emp_no,

    salary,

    ROW_NUMBER() OVER () AS row_num1,

    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS row_num2

FROM

dept_manager dm

    JOIN 

    salaries s ON dm.emp_no = s.emp_no

ORDER BY row_num1, emp_no, salary ASC;



SELECT 
	dm.emp_no, 
	salary,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary) AS row_num1,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS row_num2
FROM dept_manager dm JOIN salaries s ON s.emp_no = dm.emp_no;



SELECT emp_no, first_name, ROW_NUMBER() OVER w AS row_num
FROM employees
WINDOW w AS (PARTITION BY first_name ORDER BY emp_no ASC);


select 
	a.emp_no, 
	min(a.salary) as min_salary from 
	(
    select 
		emp_no, salary, row_number() over(w) as row_num
    from 
		salaries
    window w as (partition by emp_no ORDER BY salary)
    ) a 
    GROUP BY emp_no;

SELECT a.emp_no,

       MIN(salary) AS min_salary FROM (

SELECT

emp_no, salary, ROW_NUMBER() OVER w AS row_num

FROM

salaries

WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) a

GROUP BY emp_no;



SELECT 
	a.emp_no, 
    MIN(salary) as min_salary FROM 
    (SELECT 
		emp_no,
        salary
	from salaries
    ) a
    GROUP BY emp_no;

SELECT 
	a.emp_no,
    salary AS min_salary FROM
    (SELECT 
		emp_no,
        salary,
        ROW_NUMBER() OVER w AS row_num
	FROM salaries
    WINDOW w AS (PARTITION BY emp_no ORDER BY salary)
    ) a
WHERE a.row_num = 2;
-- -----------------------------------------------------------------------------------------------
# Create a query that will complete all the following subtasks at once:

# - Obtain data only about the managers from the "employees" database
# - Partition the relevant information by the department where the managers have worked in

# - Arrange the partitions by the managers' salary contract values in descending order

# - Rank the managers according to their salaries in a certain department (where you prefer to
# not lose track of the number of salary contracts signed within each department)

# - Display the start and end dates of each salary contract (call the relevant fields
# salary_from_date and salary_to_date, respectively)

# - Display the first and last date in which an employee has been a manager, according to the
# data provided in the dept_manager table (call the relevant fields
# dept_manager_from_date and dept_manager_to_date, respectively)

SELECT 
	dm.emp_no,
    d.dept_name,
    s.salary,
    RANK() OVER (PARTITION BY d.dept_no ORDER BY salary DESC) AS salary_rank,
    s.from_date AS Contract_from,
    s.to_date AS Contract_to,
    dm.from_date AS Manager_from,
    dm.to_date AS Manager_to
FROM
	dept_manager dm
		JOIN
    departments d ON d.dept_no = dm.dept_no
		join
    salaries s ON s.emp_no = dm.emp_no
		AND s.from_date BETWEEN dm.from_date AND dm.to_date
        AND s.to_date BETWEEN dm.from_date AND dm.to_date;
-- -----------------------------------------------------------------------------
# Write a query that ranks the salary values in descending order of
# the following contracts from the "employees" database:

# - contracts that have been signed by employees numbered
# between 10500 and 10600 inclusive.

# - contracts that have been signed at least 4 full-years after the
# date when the given employee was hired in the company for the
# first time.

# In addition, let equal salary values of a certain employee bear the
# same rank. Do not allow gaps in the ranks obtained for their
# subsequent rows.

# Use a join on the "employees" and "salaries" tables to obtain the
# desired result.

SELECT
    e.emp_no,
    DENSE_RANK() OVER w as employee_salary_ranking,
    s.salary,
    e.hire_date,
    s.from_date,
    (YEAR(s.from_date) - YEAR(e.hire_date)) AS years_from_start
FROM
	employees e
JOIN
    salaries s ON s.emp_no = e.emp_no
    AND YEAR(s.from_date) - YEAR(e.hire_date) >= 5
    AND e.emp_no BETWEEN 10500 AND 10600
WINDOW w as (PARTITION BY e.emp_no ORDER BY s.salary DESC);
-- ----------------------------------------------------------------------------------
# Write a query that can extract the following information from the
# "employees" database:

# - the salary values (in ascending order) of the contracts signed by
# all employees numbered between 10500 and 10600 inclusive

# - a column showing the previous salary from the given ordered list

# - a column showing the subsequent salary from the given ordered
# list

# - a column displaying the difference between the current salary of
# a certain employee and their previous salary

# - a column displaying the difference between the next salary of a
# certain employee and their current salary

# Limit the output to salary values higher than $80,000 only.

# Also, to obtain a meaningful result, partition the data by employee
# number.

SELECT
	emp_no,
    LAG(salary) OVER w AS salary_before,
    salary,
    LEAD(salary) OVER w AS salary_next,
    LEAD(salary,2) OVER w AS salary_subsequent_next,
    (salary - LAG(salary) OVER w) AS diff_current_before,
    (LEAD(salary) OVER w - salary) AS diff_current_next
FROM 
	salaries
WHERE (emp_no BETWEEN 10500 AND 10600)  AND (salary > 80000)
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);
-- ---------------------------------------------------------------------------------
# Create a query that upon execution returns a result set containing the employee numbers,
# contract salary values, start, and end dates of the first ever contracts that each employee
# signed for the company.

# To obtain the desired output, refer to the data stored in the "salaries" table.

SELECT s2.emp_no, s1.salary, s1.from_date, s1.to_date
FROM 
	salaries s1
		JOIN
	(SELECT emp_no, MIN(from_date) AS min_from_date FROM salaries GROUP BY emp_no) s2 ON s2.emp_no = s1.emp_no
WHERE s1.from_date = s2.min_from_date;
-- -----------------------------------------------------------------------------------
SELECT q1.emp_no, d.dept_name , q2.from_date, q2.to_date, q2.salary AS current_salary, AVG(q2.salary) OVER (PARTITION BY q1.dept_no) AS average_salary_per_department
FROM 
		(SELECT de1.emp_no, de1.dept_no, de1.from_date, de1.to_date
		 FROM dept_emp de1
				JOIN
			(SELECT de.emp_no, MAX(de.from_date) AS from_date
			 FROM dept_emp de
             WHERE de.to_date > SYSDATE()
             GROUP BY de.emp_no) de2 
				ON 
             de1.emp_no = de2.emp_no AND de1.from_date = de2.from_date) q1
				JOIN
		(SELECT s1.emp_no, s1.salary, s1.from_date, s1.to_date
		 FROM salaries s1
				JOIN
			(SELECT s.emp_no, s.salary, MAX(s.from_date) as from_date, s.to_date
			 FROM salaries s
             WHERE s.to_date > SYSDATE()
			 GROUP BY s.emp_no) s2 
				ON
             s1.emp_no = s2.emp_no AND s1.from_date = s2.from_date) q2 
				ON 
             q1.emp_no = q2.emp_no
				JOIN
					departments d 
				ON 
					q1.dept_no = d.dept_no
ORDER BY q1.emp_no;
-- GPT Version -----------------
SELECT 
    q1.emp_no, 
    d.dept_name,q2.from_date, q2.to_date, 
    q2.salary AS current_salary, 
    AVG(q2.salary) OVER (PARTITION BY q1.dept_no) AS average_salary_per_department
FROM 
    (SELECT 
         de1.emp_no, 
         de1.dept_no 
     FROM 
         dept_emp de1
     JOIN 
         (SELECT 
              emp_no, MAX(from_date) AS from_date 
          FROM 
              dept_emp 
          WHERE 
              to_date > SYSDATE() 
          GROUP BY 
              emp_no) de2 
     ON 
         de1.emp_no = de2.emp_no AND de1.from_date = de2.from_date) q1
JOIN 
    (SELECT 
         s1.emp_no, 
         s1.salary,
         s1.from_date,
         s1.to_date
     FROM 
         salaries s1
     JOIN 
         (SELECT 
              emp_no, MAX(from_date) AS from_date 
          FROM 
              salaries 
          WHERE 
              to_date > SYSDATE() 
          GROUP BY 
              emp_no) s2 
     ON 
         s1.emp_no = s2.emp_no AND s1.from_date = s2.from_date) q2 
ON 
    q1.emp_no = q2.emp_no
JOIN 
    departments d 
ON 
    q1.dept_no = d.dept_no
ORDER BY 
    q1.emp_no;

-- -----------------------------------------------------------------------------------
/* 
	contract after 1-1-2000 and terminated before 1-1-2002 (dept_emp Table)
    emp_no
    salary of the latest contract in this period
    department
    average salary paid in this department in this period
*/
SELECT 
	de.emp_no,
    d.dept_name,
    s.salary,
    AVG(s.salary) OVER W AS average_salary_per_department,
    s.to_date,
    s.from_date
FROM 
	salaries s
		JOIN
	dept_emp de ON de.emp_no = s.emp_no
		JOIN
	departments d ON d.dept_no = de.dept_no
		JOIN
	(SELECT
		emp_no,
        MAX(to_date) AS to_date
	 FROM salaries
     WHERE (to_date < '2000-1-1') AND (from_date > '2002-1-1')
     GROUP BY emp_no) s1 ON s1.emp_no = s.emp_no
WINDOW W AS (PARTITION BY de.dept_no);
-- ---------------------------------------------------------------------------------
SELECT de2.emp_no, d.dept_name, s2.salary, AVG(s2.salary) OVER w AS average_salary_per_department
FROM
						(SELECT de.emp_no, de.dept_no, de.from_date, de.to_date
						FROM dept_emp de
								JOIN
							(SELECT emp_no, MAX(from_date) AS from_date
							FROM dept_emp
							WHERE from_date > '2000-01-01' AND to_date < '2002-01-01'
							GROUP BY emp_no) de1 ON de.emp_no = de1.emp_no AND de.from_date = de1.from_date
						ORDER BY de.emp_no, de.dept_no) de2
                    
	JOIN
    
							(SELECT s1.emp_no, s.salary, s.from_date, s.to_date
							 FROM salaries s 
									JOIN
								(SELECT emp_no, MAX(from_date) AS from_date 
								 FROM salaries 	
								 GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
							     WHERE 
										s.to_date < '2002-01-01' 
									AND s.from_date > '2000-01-01'
									AND s.from_date = s1.from_date) s2 ON s2.emp_no = de2.emp_no
                                
			JOIN
            
						departments d ON d.dept_no = de2.dept_no
                        
GROUP BY de2.emp_no, d.dept_name
WINDOW w AS (PARTITION BY de2.dept_no)
ORDER BY de2.emp_no, salary;
-- ---------------------------------------------------------------------------------------------------
/*
Use a CTE (a Common Table Expression) and a SUM() function in the SELECT statement
in a query to find out how many male employees have never signed a contract with a
salary value higher than or equal to the all-time company salary average.
*/
WITH CTE AS (SELECT AVG(salary) AS avg_salary FROM salaries) 
SELECT SUM(CASE WHEN s.salary < c.avg_salary THEN 1 ELSE 0 END) AS no_salaries_below_avg, COUNT(s.emp_no) AS no_of_salary_contracts
FROM salaries s
	JOIN
    employees e ON e.emp_no = s.emp_no AND e.gender = 'm'
	JOIN CTE c;


-- 365 Solution
WITH cte AS (

SELECT AVG(salary) AS avg_salary FROM salaries

)

SELECT

SUM(CASE WHEN s.salary < c.avg_salary THEN 1 ELSE 0 END) AS no_salaries_below_avg,

COUNT(s.salary) AS no_of_salary_contracts

FROM salaries s JOIN employees e ON s.emp_no = e.emp_no AND e.gender = 'M' JOIN cte c;
-- ---------------------------------------------------------------------------------------
/*
Use a CTE (a Common Table Expression) and (at least one) COUNT() function in the
SELECT statement of a query to find out how many male employees have never signed a
contract with a salary value higher than or equal to the all-time company salary average.
*/
WITH CTE AS (SELECT AVG(salary) AS avg_salary FROM salaries) 
SELECT COUNT(CASE WHEN s.salary < c.avg_salary THEN s.salary ELSE NULL END) AS no_salaries_below_avg, COUNT(s.emp_no) AS no_of_salary_contracts
FROM salaries s
	JOIN
    employees e ON e.emp_no = s.emp_no AND e.gender = 'm'
	CROSS JOIN CTE c;
-- -------------------------------------------------------------------------------------------
/*
Use MySQL joins (and don't use a Common Table Expression) in a query to find out how
many male employees have never signed a contract with a salary value higher than or
equal to the all-time company salary average (i.e. to obtain the same result as in the
previous exercise).
*/
SELECT COUNT(CASE WHEN s.salary < c.avg_salary THEN s.salary ELSE NULL END) AS no_salaries_below_avg, COUNT(s.emp_no) AS no_of_salary_contracts
FROM salaries s
	JOIN
    employees e ON e.emp_no = s.emp_no AND e.gender = 'm'
	CROSS JOIN
    (SELECT AVG(salary) AS avg_salary FROM salaries) c;
-- --------------------------------------------------------------------------------------------
/*
Use a cross join in a query to find out how many male employees have never signed a
contract with a salary value higher than or equal to the all-time company salary average
(i.e. to obtain the same result as in the previous exercise).
*/
WITH CTE AS (SELECT AVG(salary) AS avg_salary FROM salaries) 
SELECT SUM(CASE WHEN s.salary < c.avg_salary THEN 1 ELSE 0 END) AS no_salaries_below_avg, COUNT(s.emp_no) AS no_of_salary_contracts
FROM salaries s
	JOIN
    employees e ON e.emp_no = s.emp_no AND e.gender = 'm'
	CROSS JOIN CTE c;
/*
Best Practice:

When working with single-row CTEs:

Prefer JOIN for clarity, readability, and potential performance gains. 
Use CROSS JOIN only if you want to explicitly show that all combinations are required (e.g., multi-row scenarios).
*/
-- --------------------------------------------------------------------------------------------
/*
Use two common table expressions and a SUM() function in the SELECT statement of a
query to obtain the number of male employees whose highest salaries have been below
the all-time average.
*/
WITH 
CTE1 AS (
SELECT AVG(salary) AS avg_salary 
FROM salaries
),
CTE2 AS (
SELECT s.emp_no, MAX(s.salary) AS highest_salary 
FROM salaries s 
	JOIN employees e ON s.emp_no = e.emp_no AND e.gender = "M" 
GROUP BY s.emp_no
)
SELECT SUM(CASE WHEN c2.highest_salary < c1.avg_salary THEN 1 ELSE 0 END) AS no_of_males_lower_than_avg,
COUNT(e.emp_no) no_of_total_employees
FROM employees e
	JOIN
	CTE2 c2 ON c2.emp_no = e.emp_no
    CROSS JOIN 
    CTE1 c1;
-- --------------------------------------------------------------------------------------------------------    
/*    
Use two common table expressions and a COUNT() function in the SELECT statement of
a query to obtain the number of male employees whose highest salaries have been below
the all-time average.
*/    
WITH 
CTE1 AS (
SELECT AVG(salary) AS avg_salary 
FROM salaries
),
CTE2 AS (
SELECT s.emp_no, MAX(s.salary) AS highest_salary 
FROM salaries s 
	JOIN employees e ON s.emp_no = e.emp_no AND e.gender = "M" 
GROUP BY s.emp_no
)
SELECT COUNT(CASE WHEN c2.highest_salary < c1.avg_salary THEN c2.highest_salary ELSE NULL END) AS no_of_males_lower_than_avg,
COUNT(e.emp_no) no_of_total_employees
FROM employees e
	JOIN
	CTE2 c2 ON c2.emp_no = e.emp_no
    CROSS JOIN 
    CTE1 c1;
-- -----------------------------------------------------------------------------------------------
/*
Does the result from the previous exercise change if you used the Common Table
Expression (CTE) for the male employees' highest salaries in a FROM clause, as opposed
to in a join?
*/
WITH 
CTE1 AS (
SELECT AVG(salary) AS avg_salary 
FROM salaries
),
CTE2 AS (
SELECT s.emp_no, MAX(s.salary) AS highest_salary 
FROM salaries s 
	JOIN employees e ON s.emp_no = e.emp_no AND e.gender = "M" 
GROUP BY s.emp_no
)
SELECT COUNT(CASE WHEN c2.highest_salary < c1.avg_salary THEN c2.highest_salary ELSE NULL END) AS no_of_males_lower_than_avg,
COUNT(c2.emp_no) no_of_total_employees
FROM CTE2 c2
    CROSS JOIN 
    CTE1 c1;
-- ------------------------------------------------------------------------------------------
SELECT a.emp_no, a.salary as min_salary 
FROM (SELECT emp_no, salary,ROW_NUMBER() OVER w AS row_num FROM salaries 
WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) a
WHERE a.row_num = 2;


SELECT s.salary, DENSE_RANK() OVER (PARTITION BY s.emp_no ORDER BY s.salary DESC) as rank_salary
FROM salaries s
WHERE s.emp_no = 10560;

SELECT emp_no,
 salary AS current_salary,
 LAG(salary) OVER w AS salary_before_current,
 LEAD(salary) OVER w AS salary_after_current,
 (salary - LAG(salary) OVER w) AS diff_w_before,
 (LEAD(salary) OVER w - salary) AS diff_w_after
FROM salaries 
WHERE emp_no = 110085
WINDOW w AS (PARTITION BY emp_no ORDER BY salary ASC);


WITH AllTimeAvg AS (
    SELECT AVG(salary) AS avg_salary
    FROM salaries
),
MaxSalaries AS (
    SELECT 
        s.emp_no,
        MAX(s.salary) AS max_salary
    FROM salaries s
    JOIN dept_manager dm ON s.emp_no = dm.emp_no
    WHERE dm.dept_no = 'd004'
    GROUP BY s.emp_no
)
SELECT 
    COUNT(ms.emp_no) AS production_mgrs_below_avg
FROM MaxSalaries ms
CROSS JOIN AllTimeAvg aa
WHERE ms.max_salary < aa.avg_salary;
-- -------------------------------------------------------
USE albums;

SELECT a.artist_id,
MIN(release_date) AS earliest_date FROM (
SELECT 
	artist_id, release_date, ROW_NUMBER() OVER w AS row_num
FROM
	albums
WINDOW w AS (PARTITION BY artist_id ORDER BY release_date)) a
GROUP BY release_date;

SELECT artist_first_name , 
LAG(record_label_contract_start_date)  OVER W AS lagg, 
LEAD(record_label_contract_start_date) OVER w AS leadd,
datediff(record_label_contract_start_date , LAG(record_label_contract_start_date) OVER W) AS diff_w_lagg,
datediff(LEAD(record_label_contract_start_date) OVER w , record_label_contract_start_date) AS diff_w_leadd
FROM artists 
WINDOW w AS (PARTITION BY artist_id);

WITH CTE1 AS (SELECT AVG(no_weeks_top_100) AS avg_t100 FROM artists)
SELECT a.artist_id, SUM(CASE WHEN a.no_weeks_top_100 < c1.avg_t100 THEN 1 ELSE 0 END) as sm
FROM artists a 
JOIN CTE1 c1;

select start_date_ind_artist
from artists;

SELECT AVG(no_weeks_top_100) AS avg_t100 FROM artists;



SELECT
artist_first_name,
artist_last_name,
record_label_contract_start_date,
LAG(record_label_contract_start_date) OVER w AS record_label_sd_before_current,
LEAD(record_label_contract_start_date) OVER w AS record_label_sd_after_current,
DATEDIFF(record_label_contract_start_date, LAG(record_label_contract_start_date) OVER w) AS diff_record_label_sd_before_current,
DATEDIFF(LEAD(record_label_contract_start_date) OVER w, record_label_contract_start_date) AS diff_record_label_sd_after_current
FROM
artists
WHERE start_date_ind_artist IS NULL
WINDOW W AS (ORDER BY record_label_contract_start_date);

SELECT artist_first_name, 
artist_last_name,
record_label_contract_start_date,
LAG(record_label_contract_start_date) OVER W AS lagg, 
LEAD(record_label_contract_start_date) OVER w AS leadd,
datediff(record_label_contract_start_date , LAG(record_label_contract_start_date) OVER W) AS diff_w_lagg,
datediff(LEAD(record_label_contract_start_date) OVER w , record_label_contract_start_date) AS diff_w_leadd
FROM artists 
WINDOW w AS (ORDER BY record_label_contract_start_date);




