# Use already existing employees_mod db and tables

USE employees_mod;

# Lets check the employee count on a yearly basis since 1990, differentitated by gender
# This will be used for the first visualization in the dashboard

SELECT
YEAR(de.from_date) AS calendar_year, e.gender, COUNT(e.emp_no) AS num_of_employees
FROM t_employees e 
JOIN t_dept_emp de ON e.emp_no = de.emp_no
GROUP BY YEAR(de.from_date), e.gender
HAVING calendar_year >= '1990';

# Now lets understand how the department managers staffing increase on a yearly basis since 1990, again differentiate by gender
# This will be used to create the second visualizaiton for the dashboard

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    (CASE
        WHEN e.calendar_year >= YEAR(dm.from_date) AND YEAR(dm.to_date) >= e.calendar_year THEN 1
        ELSE 0
    END) AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
        GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON d.dept_no = dm.dept_no
        JOIN
    t_employees ee ON ee.emp_no = dm.emp_no
ORDER BY dm.emp_no, e.calendar_year;

# Lets see how employees salaries vary based on departments, gender and year
# This will be used to create the third visualization for our dashboard

SELECT e.gender, d.dept_name, ROUND(AVG(s.salary),2) AS salary, YEAR(de.from_date) AS calendar_year
FROM t_salaries s
JOIN t_employees e ON e.emp_no = s.emp_no
JOIN t_dept_emp de ON de.emp_no = e.emp_no
JOIN t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;

# Finally lets create a stored procedure to view avg salaries across departments and genders, with two parameters to select a range to include salaries from within
# This will be used as the final visualizaiton for the dashboard

DELIMITER $$
CREATE PROCEDURE salary_input (IN low_range FLOAT, IN high_range FLOAT)
BEGIN
SELECT
e.gender, d.dept_name, ROUND(AVG(s.salary),2) AS avg_salary 
FROM
t_salaries s
JOIN t_employees e ON e.emp_no = s.emp_no
JOIN t_dept_emp dm ON dm.emp_no = e.emp_no
JOIN t_departments d ON d.dept_no = dm.dept_no 
WHERE s.salary BETWEEN low_range AND high_range
GROUP BY d.dept_no, e.gender;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS salary_input;

CALL salary_input(50000,90000);

