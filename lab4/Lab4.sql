-- Part 1: Basic SELECT Queries

-- Task 1.1
SELECT 
    first_name || ' ' || last_name AS full_name,
    department,
    salary
FROM employees
ORDER BY department, salary DESC;

-- Task 1.2
SELECT DISTINCT department
FROM employees
ORDER BY department;

-- Task 1.3
SELECT 
    project_name,
    budget,
    CASE 
        WHEN budget > 150000 THEN 'Large'
        WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
        ELSE 'Small'
    END AS budget_category
FROM projects
ORDER BY budget DESC;

-- Task 1.4
SELECT 
    first_name || ' ' || last_name AS employee_name,
    COALESCE(email, 'No email provided') AS email_address
FROM employees
ORDER BY last_name, first_name;

-- Part 2: WHERE Clause and Comparison Operators

-- Task 2.1
SELECT *
FROM employees
WHERE hire_date > '2020-01-01'
ORDER BY hire_date;

-- Task 2.2
SELECT *
FROM employees
WHERE salary BETWEEN 60000 AND 70000
ORDER BY salary DESC;

-- Task 2.3
SELECT *
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%'
ORDER BY last_name, first_name;

-- Task 2.4
SELECT *
FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT'
ORDER BY salary DESC;

-- Part 3: String and Mathematical Functions

-- Task 3.1
SELECT 
    UPPER(first_name || ' ' || last_name) AS employee_name_upper,
    LENGTH(last_name) AS last_name_length,
    SUBSTRING(email FROM 1 FOR 3) AS email_prefix
FROM employees
ORDER BY last_name_length DESC;

-- Task 3.2
SELECT 
    first_name || ' ' || last_name AS employee_name,
    salary AS annual_salary,
    ROUND(salary / 12, 2) AS monthly_salary,
    salary * 0.10 AS raise_amount
FROM employees
ORDER BY annual_salary DESC;

-- Task 3.3
SELECT 
    FORMAT('Project: %s - Budget: $%s - Status: %s', project_name, budget, status) AS project_info
FROM projects
ORDER BY budget DESC;

-- Task 3.4
SELECT 
    first_name || ' ' || last_name AS employee_name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees
ORDER BY years_with_company DESC;

-- Part 4: Aggregate Functions and GROUP BY

-- Task 4.1
SELECT 
    department,  
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC;

-- Task 4.2
SELECT 
    p.project_name,
    SUM(a.hours_worked) AS total_hours_worked
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
ORDER BY total_hours_worked DESC;

-- Task 4.3
SELECT 
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1
ORDER BY employee_count DESC;

-- Task 4.4
SELECT 
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_payroll
FROM employees;

-- Part 5: Set Operations

-- Task 5.1
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary
FROM employees
WHERE salary > 65000

UNION

SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary
FROM employees
WHERE hire_date > '2020-01-01'
ORDER BY salary DESC;

-- Task 5.2
SELECT employee_id, first_name, last_name
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT employee_id, first_name, last_name
FROM employees
WHERE salary > 65000
ORDER BY last_name, first_name;

-- Task 5.3
SELECT employee_id, first_name, last_name
FROM employees

EXCEPT

SELECT DISTINCT e.employee_id, e.first_name, e.last_name
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id
ORDER BY last_name, first_name;

-- Part 6: Subqueries

-- Task 6.1
SELECT *
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.employee_id = e.employee_id
)
ORDER BY e.last_name, e.first_name;

-- Task 6.2
SELECT *
FROM employees
WHERE employee_id IN (
    SELECT DISTINCT a.employee_id
    FROM assignments a
    JOIN projects p ON a.project_id = p.project_id
    WHERE p.status = 'Active'
)
ORDER BY department, last_name;

-- Task 6.3
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
)
ORDER BY salary DESC;

-- Part 7: Complex Queries

-- Task 7.1
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    e.salary,
    ROUND(AVG(a.hours_worked), 2) AS avg_hours_worked,
    (SELECT COUNT(*) + 1 
     FROM employees e2 
     WHERE e2.department = e.department AND e2.salary > e.salary) AS salary_rank_in_dept
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, salary_rank_in_dept;

-- Task 7.2
SELECT 
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS number_of_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150
ORDER BY total_hours DESC;

-- Task 7.3
SELECT 
    e.department,
    COUNT(*) AS total_employees,
    ROUND(AVG(e.salary), 2) AS average_salary,
    (SELECT first_name || ' ' || last_name 
     FROM employees 
     WHERE department = e.department 
     ORDER BY salary DESC 
     LIMIT 1) AS highest_paid_employee,
    GREATEST(MAX(e.salary), 100000) AS adjusted_max_salary,
    LEAST(MIN(e.salary), 50000) AS adjusted_min_salary
FROM employees e
GROUP BY e.department
ORDER BY average_salary DESC;