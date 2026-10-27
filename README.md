# DBMS Lab File

This repository contains the Database Management Systems (DBMS) Lab experiments.

## Experiments List

- **[Experiment 1: Design an ER Diagram for Indian E-Commerce Platform](Experiment%201/experiment1.md)**
- **[Experiment 2: Convert ER Diagram into Relational Schema](Experiment%202/experiment2.md)**
- **[Experiment 3: SQL Queries - Selection, Projection, Aggregations, GROUP BY, HAVING, CASE, and JOINs](Experiment%203/experiment3.md)**
- **[Experiment 4: Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN](Experiment%204/experiment4.md)**
- **[Experiment 5: SQL Views and Recursive CTEs for Hierarchy](Experiment%205/experiment5.md)**
- **[Experiment 6: Stored Procedures, Triggers, and Error Handling](Experiment%206/experiment6.md)**
- **[Experiment 7: Normalization from UNF to 3NF and BCNF, Lossless Join & Dependency Preservation](Experiment%207/experiment7.md)**
- **[Experiment 8: Banking Transactions, Partial Failures, and Concurrency Control](Experiment%208/experiment8.md)**
- **[Experiment 9: Railway Booking Indexing & Benchmarking (5,000+ Records)](Experiment%209/experiment9.md)**
- **[Experiment 10: Query Optimization, EXPLAIN Analysis, and Performance Tuning (10,000+ Rows)](Experiment%2010/experiment10.md)**

---

### [Experiment 1: Design an ER Diagram for Indian E-Commerce Platform](Experiment%201/experiment1.md)
- **Aim**: To design an ER (Entity-Relationship) diagram for an Indian e-commerce platform.
- **Key entities**: Customer, Product, Order, OrderItem, Seller, Category, Payment, Delivery, Address.
- **Output**: [experiment1.md](Experiment%201/experiment1.md) and [er_diagram.png](Experiment%201/er_diagram.png).

### [Experiment 2: Convert ER Diagram into Relational Schema](Experiment%202/experiment2.md)
- **Aim**: To convert the designed ER diagram into a relational schema and implement it using MySQL.
- **Output**: [experiment2.md](Experiment%202/experiment2.md) and [schema.sql](Experiment%202/schema.sql).

### [Experiment 3: SQL Queries - Selection, Projection, Aggregations, GROUP BY, HAVING, CASE, and JOINs](Experiment%203/experiment3.md)
- **Aim**: To create an Employee–Department–Project relational database, insert at least 30 employees across 5 departments and 8 projects, and demonstrate SQL queries using Selection, Projection, Aggregate Functions, GROUP BY, HAVING, CASE expressions, and ORDER BY.
- **Output**: [experiment3.md](Experiment%203/experiment3.md) and [queries.sql](Experiment%203/queries.sql).

### [Experiment 4: Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN](Experiment%204/experiment4.md)
- **Aim**: Using the Employee schema, write and execute SQL queries with INNER JOIN, LEFT JOIN, self-join, 3-way join, correlated subqueries, EXISTS, and simulated INTERSECT and EXCEPT. Compare the execution plans of selected queries using EXPLAIN.
- **Output**: [experiment4.md](Experiment%204/experiment4.md) and [queries.sql](Experiment%204/queries.sql).

### [Experiment 5: SQL Views and Recursive CTEs for Hierarchy](Experiment%205/experiment5.md)
- **Aim**: To create SQL views for department salary summary and employee hierarchy, test the updatability of views, and implement a recursive CTE to display reporting chains.
- **Output**: [experiment5.md](Experiment%205/experiment5.md) and [queries.sql](Experiment%205/queries.sql).

### [Experiment 6: Stored Procedures, Triggers, and Error Handling](Experiment%206/experiment6.md)
- **Aim**: To create a stored procedure transfer_employee(emp_id, new_dept_id) with validation and error handling, implement triggers for salary validation and audit logging, and test important edge cases.
- **Output**: [experiment6.md](Experiment%206/experiment6.md) and [queries.sql](Experiment%206/queries.sql).

### [Experiment 7: Normalization from UNF to 3NF and BCNF, Lossless Join & Dependency Preservation](Experiment%207/experiment7.md)
- **Aim**: Given a denormalized Sales table, identify functional dependencies and normalize step-by-step from UNF to 3NF and BCNF. Verify lossless join and dependency preservation using SQL queries.
- **Output**: [experiment7.md](Experiment%207/experiment7.md) and [queries.sql](Experiment%207/queries.sql).

### [Experiment 8: Banking Transactions, Partial Failures, and Concurrency Control](Experiment%208/experiment8.md)
- **Aim**: Implement banking-style transactions using BEGIN, COMMIT, ROLLBACK, and SAVEPOINT. Simulate partial failures. Demonstrate isolation levels and concurrency anomalies using two sessions.
- **Output**: [experiment8.md](Experiment%208/experiment8.md) and [queries.sql](Experiment%208/queries.sql).

### [Experiment 9: Railway Booking Indexing & Benchmarking (5,000+ Records)](Experiment%209/experiment9.md)
- **Aim**: Create a Railway Booking table with at least 5,000 records. Benchmark query performance before and after creating single and composite indexes. Use EXPLAIN to compare execution plans.
- **Output**: [experiment9.md](Experiment%209/experiment9.md) and [queries.sql](Experiment%209/queries.sql).

### [Experiment 10: Query Optimization, EXPLAIN Analysis, and Performance Tuning (10,000+ Rows)](Experiment%2010/experiment10.md)
- **Aim**: Generate a dataset with at least 10,000 rows. Write five slow queries, analyze using EXPLAIN, optimize using indexing and query rewriting, and compare execution time before and after optimization.
- **Output**: [experiment10.md](Experiment%2010/experiment10.md) and [queries.sql](Experiment%2010/queries.sql).
