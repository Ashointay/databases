-- Part 1: Database Setup
-- Step 1.1: Create Sample Tables
-- Create table: employees
CREATE TABLE employees(
                          emp_id INT PRIMARY KEY,
                          emp_name VARCHAR(50),
                          dept_id INT,
                          salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments(
                            dept_id INT PRIMARY KEY,
                            dept_name VARCHAR(50),
                            location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects(
                         project_id INT PRIMARY KEY,
                         project_name VARCHAR(50),
                         dept_id INT,
                         budget DECIMAL(10, 2)
);

-- Step 1.2: Insert Sample Data
-- Insert data into employees
INSERT INTO  employees (emp_id, emp_name, dept_id, salary) VALUES
                                                               (101, 'IT', 'Building A'),
                                                               (102, 'HR', 'Building B'),
                                                               (103, 'Finance', 'Building C'),
                                                               (104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
                                                                     (1, 'Website Redesign', 101, 100000),
                                                                     (2, 'Employee Training', 102, 50000),
                                                                     (3, 'Budget Analysis', 103, 75000),
                                                                     (4, 'Cloud Migration', 101, 150000),
                                                                     (5, 'AI Research', NULL, 200000);

-- Part 2: CROSS JOIN Exercises;
-- Exercise 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- Exercise 2.2: Alternative CROSS JOIN Syntax
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;
-- Exercise 2.3: Practical CROSS JOIN
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p ORDER BY e.emp_name, p.project_name;

-- Part 3: INNER JOIN Exercises;
-- Exercise 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;
-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees INNER JOIN departments USING (dept_id);
-- Exercise 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees NATURAL INNER JOIN departments;
-- Exercise 3.4: Multi-table INNER JOIN
SELECT  e.emp_name, d.dept_name, p.project_name
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id
                 INNER JOIN projects p ON d.dept_id = p.dept_id;

-- Part 4: LEFT JOIN Exercises;
-- Exercise 4.1: Basic LEFT JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Exercise 4.2: LEFT JOIN with USING
SELECT e.emp_name, d.dept_name
FROM employees e LEFT JOIN departments d USING (dept_id);
-- Exercise 4.3: Find Unmatched Records
SELECT e.emp_name, e.dept_id
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
-- Exercise 4.4: LEFT JOIN with Aggregation
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- Part 5: RIGHT JOIN Exercises;
-- Exercise 5.1: Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- Exercise 5.2: Convert to LEFT JOIN
SELECT e.emp_name, d.dept_name
FROM departments d
         RIGHT JOIN employees e ON d.dept_id = e.dept_id;
-- Exercise 5.3: Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- Part 6: FULL JOIN Exercises;
-- Exercise 6.1: Basic FULL JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id;
-- Exercise 6.2: FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
         FULL JOIN projects p ON d.dept_id = p.dept_id;
-- Exercise 6.3: Find Orphaned Records
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
        END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

-- Part 7: ON vs WHERE Clause
-- Exercise 7.1: Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
-- Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Exercise 7.3: ON vs WHERE with INNER JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Part 8: Complex JOIN Scenarios
-- Exercise 8.1: Multiple Joins with Different Types
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;
-- Exercise 8.2: Self Join
ALTER TABLE employees ADD COLUMN manager_id INT;
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id;
-- Exercise 8.3: Join with Subquery
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING  AVG(e.salary) > 50000;

-- Lab Questions in word