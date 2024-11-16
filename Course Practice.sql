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












