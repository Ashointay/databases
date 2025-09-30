-- Part A: Database and Table Setup

-- Create table 'employees'
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

-- Create table 'departments'
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

-- Create table 'projects'
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

-- Part B: Advanced INSERT Operations 

-- 2. INSERT with column specification
INSERT INTO employees (first_name, last_name, department)
VALUES ('John', 'Doe', 'IT');

-- 3. INSERT with DEFAULT values
INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Jane', 'Smith', 'HR', DEFAULT, DEFAULT);

-- 4. INSERT multiple rows in single statement
INSERT INTO departments (dept_name, budget, manager_id)
VALUES 
    ('IT', 100000, 1),
    ('HR', 80000, 2),
    ('Finance', 120000, 3);

-- 5. INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Mike', 'Johnson', 'IT', 50000 * 1.1, CURRENT_DATE);

-- 6. INSERT from SELECT (subquery)
CREATE TABLE temp_employees AS 
SELECT * FROM employees WHERE department = 'IT';

-- Part C: Complex UPDATE Operations

-- 7. UPDATE with arithmetic expressions
UPDATE employees SET salary = salary * 1.10;

-- 8. UPDATE with WHERE clause and multiple conditions
UPDATE employees 
SET status = 'Senior' 
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression
UPDATE employees 
SET department = CASE 
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- 10. UPDATE with DEFAULT
UPDATE employees 
SET department = DEFAULT 
WHERE status = 'Inactive';

-- 11. UPDATE with subquery
UPDATE departments 
SET budget = (
    SELECT AVG(salary) * 1.20 
    FROM employees 
    WHERE employees.department = departments.dept_name
);

-- 12. UPDATE multiple columns
UPDATE employees 
SET salary = salary * 1.15, 
    status = 'Promoted' 
WHERE department = 'Sales';

-- Part D: Advanced DELETE Operations

-- 13. DELETE with simple WHERE condition
DELETE FROM employees WHERE status = 'Terminated';

-- Check: verify employees with status 'Terminated' are deleted
SELECT * FROM employees WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause
DELETE FROM employees WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

-- Check: verify specific rows are deleted
SELECT * FROM employees WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

-- 15. DELETE with subquery
DELETE FROM departments WHERE dept_id NOT IN (SELECT DISTINCT dept_id FROM employees WHERE dept_id IS NOT NULL);

-- Check: see which departments remain
SELECT * FROM departments;

-- 16. DELETE with RETURNING clause
DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

-- Part E: Operations with NULL Values

-- 17. INSERT with NULL values
INSERT INTO employees (first_name, last_name, salary, department) 
VALUES ('Anna', 'Brown', NULL, NULL);

-- Check: view employee with NULL values
SELECT * FROM employees WHERE first_name = 'Anna' AND last_name = 'Brown';

-- 18. UPDATE NULL handling
UPDATE employees SET department = 'Unassigned' WHERE department IS NULL;

-- Check: verify NULL departments are updated
SELECT * FROM employees WHERE department = 'Unassigned';

-- 19. DELETE with NULL conditions
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

-- Check: verify rows with NULL are deleted
SELECT * FROM employees WHERE salary IS NULL OR department IS NULL;

-- Part F: RETURNING Clause Operations

-- 20. INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary) 
VALUES ('Michael', 'Davis', 'IT', 75000)
RETURNING emp_id, CONCAT(first_name, ' ', last_name) AS full_name;

-- Check: verify the inserted employee
SELECT * FROM employees WHERE first_name = 'Michael' AND last_name = 'Davis';

-- 21. UPDATE with RETURNING
UPDATE employees 
SET salary = salary + 5000 
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- Check: verify IT department salaries were updated
SELECT emp_id, first_name, department, salary FROM employees WHERE department = 'IT';

-- 22. DELETE with RETURNING all columns
DELETE FROM employees 
WHERE hire_date < '2020-01-01'
RETURNING *;

-- Check: verify employees hired before 2020 are deleted
SELECT * FROM employees WHERE hire_date < '2020-01-01';

-- Part G: Advanced DML Patterns

-- 23. Conditional INSERT
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Robert', 'Wilson', 'IT', 55000
WHERE NOT EXISTS (
    SELECT 1 FROM employees 
    WHERE first_name = 'Robert' AND last_name = 'Wilson'
);

-- Check: verify conditional insert worked
SELECT * FROM employees WHERE first_name = 'Robert' AND last_name = 'Wilson';

-- 24. UPDATE with JOIN logic using subqueries
UPDATE employees 
SET salary = CASE 
    WHEN department IN (
        SELECT dept_name FROM departments WHERE budget > 100000
    ) THEN salary * 1.10
    ELSE salary * 1.05
END;

-- Check: verify salary updates
SELECT emp_id, first_name, department, salary FROM employees;

-- 25. Bulk operations
-- Insert 5 employees in single statement
INSERT INTO employees (first_name, last_name, department, salary) VALUES
('Sarah', 'Miller', 'HR', 48000),
('David', 'Lee', 'IT', 62000),
('Emily', 'Chen', 'Finance', 58000),
('James', 'Taylor', 'IT', 67000),
('Lisa', 'Wang', 'HR', 52000);

-- Update all their salaries to be 10% higher
UPDATE employees SET salary = salary * 1.10 
WHERE first_name IN ('Sarah', 'David', 'Emily', 'James', 'Lisa');

-- Check: verify bulk operations
SELECT * FROM employees WHERE first_name IN ('Sarah', 'David', 'Emily', 'James', 'Lisa');

-- 26. Data migration simulation
-- Create employee_archive table
CREATE TABLE employee_archive AS TABLE employees WITH NO DATA;

-- Move inactive employees to archive
INSERT INTO employee_archive 
SELECT * FROM employees WHERE status = 'Inactive';

-- Delete them from original table
DELETE FROM employees WHERE status = 'Inactive';

-- Check: verify migration
SELECT * FROM employee_archive;
SELECT * FROM employees WHERE status = 'Inactive';

-- 27. Complex business logic
UPDATE projects 
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000 AND dept_id IN (
    SELECT dept_id FROM departments WHERE dept_id IN (
        SELECT dept_id FROM employees 
        GROUP BY dept_id 
        HAVING COUNT(*) > 3
    )
);

-- Check: verify project updates
SELECT * FROM projects;
