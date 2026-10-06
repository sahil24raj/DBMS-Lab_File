# DBMS Lab File

This repository contains the Database Management Systems (DBMS) Lab experiments.

## Experiments List

- **[Experiment 1: Design an ER Diagram for Indian E-Commerce Platform](Experiment%201/)** ([experiment1.md](experiment1.md))
- **[Experiment 2: Convert ER Diagram into Relational Schema](Experiment%202/)** ([experiment2.md](experiment2.md))
- **[Experiment 3: SQL Queries - Selection, Projection, Aggregations, GROUP BY, HAVING, CASE, and JOINs](Experiment%203/)** ([experiment3.md](experiment3.md))
- **[Experiment 4: Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN](Experiment%204/)** ([experiment4.md](experiment4.md))
- **[Experiment 5: SQL Views and Recursive CTEs for Hierarchy](Experiment%205/)** ([experiment5.md](experiment5.md))
- **[Experiment 6: Stored Procedures, Triggers, and Error Handling](Experiment%206/)** ([experiment6.md](experiment6.md))

---

### [Experiment 1: Design an ER Diagram for Indian E-Commerce Platform](Experiment%201/README.md)
- **Aim**: To design an ER (Entity-Relationship) diagram for an Indian e-commerce platform.
- **Key entities**: Customer, Product, Order, OrderItem, Seller, Category, Payment, Delivery, Address.
- **Output**: ER Diagram.

### [Experiment 2: Convert ER Diagram into Relational Schema](Experiment%202/README.md)
- **Aim**: To convert the designed ER diagram into a relational schema and implement it using MySQL.
- **Output**: SQL script with schema definitions, sample data insertions, referential integrity checks, and documentation of key constraints.

### [Experiment 3: SQL Queries - Selection, Projection, Aggregations, GROUP BY, HAVING, CASE, and JOINs](Experiment%203/README.md)
- **Aim**: To create an Employee–Department–Project relational database, insert at least 30 employees across 5 departments and 8 projects, and demonstrate SQL queries using Selection, Projection, Aggregate Functions, GROUP BY, HAVING, CASE expressions, and ORDER BY.
- **Output**: [experiment3.md](experiment3.md) and [Experiment 3/queries.sql](Experiment%203/queries.sql).

### [Experiment 4: Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN](Experiment%204/README.md)
- **Aim**: Using the Employee schema, write and execute SQL queries with INNER JOIN, LEFT JOIN, self-join, 3-way join, correlated subqueries, EXISTS, and simulated INTERSECT and EXCEPT. Compare the execution plans of selected queries using EXPLAIN.
- **Output**: [experiment4.md](experiment4.md) and [Experiment 4/queries.sql](Experiment%204/queries.sql).

### [Experiment 5: SQL Views and Recursive CTEs for Hierarchy](Experiment%205/README.md)
- **Aim**: To create SQL views for department salary summary and employee hierarchy, test the updatability of views, and implement a recursive CTE to display reporting chains.
- **Output**: [experiment5.md](experiment5.md) and [Experiment 5/queries.sql](Experiment%205/queries.sql).

### [Experiment 6: Stored Procedures, Triggers, and Error Handling](Experiment%206/README.md)
- **Aim**: To create a stored procedure transfer_employee(emp_id, new_dept_id) with validation and error handling, implement triggers for salary validation and audit logging, and test important edge cases.
- **Output**: [experiment6.md](experiment6.md) and [Experiment 6/queries.sql](Experiment%206/queries.sql).
