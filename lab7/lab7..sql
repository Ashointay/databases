-- Part 1: Database Setup (Use Lab 6 Tables)
CREATE TABLE employees(
                          emp_id INT PRIMARY KEY,
                          emp_name VARCHAR(50),
                          dept_id INT,
                          salary DECIMAL(10, 2)
);
CREATE TABLE departments(
                            dept_id INT PRIMARY KEY,
                            dept_name VARCHAR(50),
                            location VARCHAR(50)
);
CREATE TABLE projects(
                         project_id INT PRIMARY KEY,
                         project_name VARCHAR(50),
                         dept_id INT,
                         budget DECIMAL(10, 2)
);

INSERT INTO  employees (emp_id, emp_name, dept_id, salary) VALUES
                                                               (101, 'IT', 'Building A'),
                                                               (102, 'HR', 'Building B'),
                                                               (103, 'Finance', 'Building C'),
                                                               (104, 'Marketing', 'Building D');
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
                                                                     (1, 'Website Redesign', 101, 100000),
                                                                     (2, 'Employee Training', 102, 50000),
                                                                     (3, 'Budget Analysis', 103, 75000),
                                                                     (4, 'Cloud Migration', 101, 150000),
                                                                     (5, 'AI Research', NULL, 200000);



-- Part 2: Creating Basic Views
CREATE VIEW employee_details AS
    SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
-- 4 rows, because his dept_id is NULL

CREATE VIEW dept_statistics AS
    SELECT d.dept_id, d.dept_name, COUNT(e.emp_id) AS employee_count,
           COALESCE(ROUND(AVG(e.salary)::numeric, 2), 0) AS avg_salary,
           COALESCE(MAX(e.salary), 0) AS max_salary,
           COALESCE(MIN(e.salary), 0) AS min_salary
    FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

CREATE OR REPLACE VIEW project_overview AS
       SELECT p.project_id, p.project_name, p.budget, d.dept_name, d.location
FROM projects p
    LEFT JOIN departments d ON p.dept_id = d.dept_id;

CREATE OR REPLACE VIEW high_earners AS
       SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM employees e
    LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;
-- Yes, you see only employees with salary > 55,000


-- Part 3: Modifying and Managing Views
CREATE OR REPLACE VIEW employee_details AS
       SELECT e.emp_id, e.emp_name, e.salary, d.dept_id, d.dept_name, d.location,
              CASE
                  WHEN e.salary > 60000 THEN 'High'
                  WHEN e.salary > 50000 THEN 'Medium'
                  ELSE 'Standard'
                  END AS salary_grade
FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id;

ALTER VIEW high_earners RENAME TO top_performers;

CREATE TEMP VIEW temp_view AS
       SELECT emp_id, emp_name, salary FROM employees WHERE salary < 50000;


-- Part 4: Updatable Views
CREATE OR REPLACE VIEW employee_salaries AS
       SELECT emp_id, emp_name, dept_id, salary FROM employees;

UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';
-- Yes, the employees table is updated because the view is directly updatable

INSERT INTO employee_salaries VALUES (6, 'Alice Johnson', 102, 58000);
-- Yes, the insert works because the view maps directly to the base table

CREATE OR REPLACE VIEW it_employees AS
       SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
    WITH LOCAL CHECK OPTION;
-- INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
-- VALUES (7, 'Bob Wilson', 103, 60000);
-- ERROR, because CHECK OPTION enforces that only dept_id=101 rows can be inserted

-- Part 5: Materialized Views
CREATE MATERIALIZED VIEW dept_summary_mv AS
    SELECT d.dept_id, d.dept_name, COUNT(e.emp_id) AS total_employees,
           COALESCE(SUM(e.salary),0) AS total_salaries,
           COALESCE((SELECT COUNT(*) FROM projects p WHERE p.dept_id = d.dept_id),0) AS total_projects,
           COALESCE((SELECT SUM(p.budget) FROM projects p WHERE p.dept_id = d.dept_id),0) AS total_project_budget
FROM departments d
    LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);
REFRESH MATERIALIZED VIEW dept_summary_mv;
-- Before refresh, materialized view shows old data. After refresh, it includes the new employee

CREATE UNIQUE INDEX dept_summary_idx ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- It allows queries to continue using the view while it is being refreshed

CREATE MATERIALIZED VIEW project_stats_mv AS
    SELECT p.project_id, p.project_name, p.budget, d.dept_name,
           (SELECT COUNT(*) FROM employees e WHERE e.dept_id = p.dept_id) AS assigned_employees
FROM projects p
    LEFT JOIN departments d ON p.dept_id = d.dept_id
WITH NO DATA;
-- SELECT * FROM project_stats_mv;
-- Returns an empty set of rows (no data)
-- To download the data, you need to do REFRESH MATERIALIZED VIEW project_stats_mv;

-- Part 6: Database Roles
CREATE ROLE analyst NOLOGIN;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user LOGIN PASSWORD 'report456';

CREATE ROLE db_creator LOGIN PASSWORD 'creator789' CREATEDB;
CREATE ROLE user_manager LOGIN PASSWORD 'manager101' CREATEROLE;
CREATE ROLE admin_user LOGIN PASSWORD 'admin999' SUPERUSER;

GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;
CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';
GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;



-- Part 7: Advanced Role Management
CREATE ROLE read_only;
CREATE SCHEMA IF NOT EXISTS public;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

CREATE ROLE temp_owner LOGIN PASSWORD 'temp123';
CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

CREATE OR REPLACE VIEW hr_employee_view AS
SELECT * FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee_view TO hr_team;
CREATE OR REPLACE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;


-- Part 8: Practical Scenarios
CREATE OR REPLACE VIEW dept_dashboard AS
    SELECT d.dept_id, d.dept_name, d.location, COUNT(e.emp_id) AS employee_count,
           ROUND(COALESCE(AVG(e.salary),0),2) AS avg_salary,
           COALESCE((SELECT COUNT(*) FROM projects p WHERE p.dept_id = d.dept_id),0) AS active_projects,
           COALESCE((SELECT SUM(p.budget) FROM projects p WHERE p.dept_id = d.dept_id),0) AS total_project_budget,
           ROUND(
                   CASE WHEN COUNT(e.emp_id)=0 THEN 0
                       ELSE COALESCE((SELECT SUM(p.budget) FROM projects p WHERE p.dept_id=d.dept_id),0)/COUNT(e.emp_id)
                       END,2) AS budget_per_employee
FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;

ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
CREATE OR REPLACE VIEW high_budget_projects AS
    SELECT p.project_id, p.project_name, p.budget, d.dept_name, p.created_date,
           CASE
               WHEN p.budget > 150000 THEN 'Critical Review Required'
               WHEN p.budget > 100000 THEN 'Management Approval Needed'
               ELSE 'Standard Process'
               END AS approval_status
FROM projects p
    LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

CREATE ROLE viewer_role NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role NOLOGIN;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role NOLOGIN;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role NOLOGIN;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE ROLE alice LOGIN PASSWORD 'alice123';
CREATE ROLE bob LOGIN PASSWORD 'bob123';
CREATE ROLE charlie LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;