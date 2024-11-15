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












