-- ==========================================================
-- EXPERIMENT 5: Views and Recursive CTEs
-- ==========================================================

USE CompanyDB;

-- 1. DEPARTMENT SALARY SUMMARY VIEW
CREATE OR REPLACE VIEW department_salary_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary,
    SUM(e.salary) AS total_salary
FROM Department d
JOIN Employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM department_salary_summary;

-- 2. EMPLOYEE HIERARCHY VIEW
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.dept_id,
    d.dept_name,
    e.salary
FROM Employee e
JOIN Department d
ON e.dept_id = d.dept_id;

SELECT * FROM employee_hierarchy;

-- 3. TEST UPDATABILITY OF VIEWS
UPDATE Employee
SET salary = salary + 1000
WHERE emp_id = 6;

SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 6;

SELECT
    dept_id,
    AVG(salary) AS average_salary
FROM Employee
WHERE dept_id = 1
GROUP BY dept_id;

-- 4. RECURSIVE CTE – REPORTING CHAIN
WITH RECURSIVE reporting_chain AS (
    SELECT
        emp_id,
        emp_name,
        dept_id,
        1 AS level,
        CAST(emp_name AS CHAR(500)) AS reporting_path
    FROM Employee
    WHERE dept_id = 1
    UNION ALL
    SELECT
        e.emp_id,
        e.emp_name,
        e.dept_id,
        rc.level + 1,
        CONCAT(rc.reporting_path, ' -> ', e.emp_name)
    FROM Employee e
    JOIN reporting_chain rc
    ON e.dept_id = rc.dept_id
    WHERE e.emp_id > rc.emp_id
)
SELECT
    emp_id,
    emp_name,
    dept_id,
    level,
    reporting_path
FROM reporting_chain
ORDER BY level, emp_id;
