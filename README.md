# Database Management Systems (DBMS) Lab

[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Status](https://img.shields.io/badge/Status-Completed%20(10%2F10)-success.svg)]()
[![Curriculum](https://img.shields.io/badge/Curriculum-CU%20Lucknow-orange.svg)]()

This repository contains the complete laboratory coursework and practical solutions for the **Database Management Systems (DBMS) Laboratory** course, covering **Experiments 01 through 10** aligned with Course Outcomes (**CO1 to CO5**).

---

## 📑 Master Index of Experiments

| Exp # | Experiment Title | Course Outcome | Documentation | SQL Source |
| :---: | :--- | :---: | :---: | :---: |
| **01** | Design an ER Diagram for Indian E-Commerce Platform | **CO1** | [experiment1.md](Experiment%2001/experiment1.md) | [ER Diagram](Experiment%2001/er_diagram.png) |
| **02** | Convert ER Diagram into Relational Schema | **CO2** | [experiment2.md](Experiment%2002/experiment2.md) | [schema.sql](Experiment%2002/schema.sql) |
| **03** | SQL Queries: Selection, Projection, Aggregation, GROUP BY, HAVING, CASE & JOINs | **CO3** | [experiment3.md](Experiment%2003/experiment3.md) | [queries.sql](Experiment%2003/queries.sql) |
| **04** | Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN | **CO3** | [experiment4.md](Experiment%2004/experiment4.md) | [queries.sql](Experiment%2004/queries.sql) |
| **05** | SQL Views, View Updatability, and Recursive CTEs for Hierarchy | **CO3** | [experiment5.md](Experiment%2005/experiment5.md) | [queries.sql](Experiment%2005/queries.sql) |
| **06** | Stored Procedures, Validation Triggers, and Audit Logging | **CO3** | [experiment6.md](Experiment%2006/experiment6.md) | [queries.sql](Experiment%2006/queries.sql) |
| **07** | Normalization (UNF to 3NF & BCNF), Lossless Join & Dependency Preservation | **CO4** | [experiment7.md](Experiment%2007/experiment7.md) | [queries.sql](Experiment%2007/queries.sql) |
| **08** | Banking Transactions (ACID), Savepoints, and Concurrency Isolation Anomalies | **CO4** | [experiment8.md](Experiment%2008/experiment8.md) | [queries.sql](Experiment%2008/queries.sql) |
| **09** | Railway Booking System Indexing & Query Benchmarking (5,000+ Records) | **CO5** | [experiment9.md](Experiment%2009/experiment9.md) | [queries.sql](Experiment%2009/queries.sql) |
| **10** | Query Performance Tuning, EXPLAIN Analysis, and Optimization (10,000+ Rows) | **CO5** | [experiment10.md](Experiment%2010/experiment10.md) | [queries.sql](Experiment%2010/queries.sql) |

---

## 🔬 Detailed Experiment Descriptions

### [Experiment 01: Design an ER Diagram for Indian E-Commerce Platform](Experiment%2001/experiment1.md)
- **Course Outcome**: `CO1`
- **Aim**: To design a comprehensive Entity-Relationship (ER) diagram for an Indian e-commerce platform incorporating real-world attributes and multi-entity relationships.
- **Key Entities**: Customer, Product, Order, OrderItem, Seller, Category, Payment, Delivery, Address.
- **Deliverables**: [experiment1.md](Experiment%2001/experiment1.md) and [er_diagram.png](Experiment%2001/er_diagram.png).

---

### [Experiment 02: Convert ER Diagram into Relational Schema](Experiment%2002/experiment2.md)
- **Course Outcome**: `CO2`
- **Aim**: To convert the conceptual ER diagram into a fully normalized relational schema, enforcing primary keys, foreign keys, cardinality rules, and check constraints in MySQL.
- **Deliverables**: [experiment2.md](Experiment%2002/experiment2.md) and [schema.sql](Experiment%2002/schema.sql).

---

### [Experiment 03: SQL Queries - Selection, Projection, Aggregations, GROUP BY, HAVING, CASE, and JOINs](Experiment%2003/experiment3.md)
- **Course Outcome**: `CO3`
- **Aim**: To create an Employee–Department–Project database (30 employees, 5 departments, 8 projects) and execute queries using Selection, Projection, Aggregate Functions (`COUNT`, `AVG`, `SUM`, `MIN`, `MAX`), `GROUP BY`, `HAVING`, conditional `CASE` expressions, and multi-table joins.
- **Deliverables**: [experiment3.md](Experiment%2003/experiment3.md) and [queries.sql](Experiment%2003/queries.sql).

---

### [Experiment 04: Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN](Experiment%2004/experiment4.md)
- **Course Outcome**: `CO3`
- **Aim**: To formulate advanced queries using `INNER JOIN`, `LEFT JOIN`, self-joins, 3-way joins, correlated subqueries, `EXISTS`, and simulated set operations (`INTERSECT` and `EXCEPT`). Query execution plans are analyzed and compared using `EXPLAIN`.
- **Deliverables**: [experiment4.md](Experiment%2004/experiment4.md) and [queries.sql](Experiment%2004/queries.sql).

---

### [Experiment 05: SQL Views and Recursive CTEs for Hierarchy](Experiment%2005/experiment5.md)
- **Course Outcome**: `CO3`
- **Aim**: To create SQL views for department salary summaries and employee reporting hierarchies, examine conditions governing view updatability, and implement a recursive Common Table Expression (CTE) to trace multi-level manager reporting chains.
- **Deliverables**: [experiment5.md](Experiment%2005/experiment5.md) and [queries.sql](Experiment%2005/queries.sql).

---

### [Experiment 06: Stored Procedures, Triggers, and Error Handling](Experiment%206/experiment6.md)
- **Course Outcome**: `CO3`
- **Aim**: To develop a stored procedure `transfer_employee(emp_id, new_dept_id)` with validation and transaction rollback, configure `BEFORE` triggers for salary validation (enforcing bounds ₹30,000–₹1,50,000), and `AFTER UPDATE` triggers for audit logging.
- **Deliverables**: [experiment6.md](Experiment%2006/experiment6.md) and [queries.sql](Experiment%2006/queries.sql).

---

### [Experiment 07: Normalization from UNF to 3NF and BCNF, Lossless Join & Dependency Preservation](Experiment%2007/experiment7.md)
- **Course Outcome**: `CO4`
- **Aim**: Given a denormalized retail Sales table, identify non-trivial functional dependencies and candidate keys, normalize step-by-step from UNF to 1NF, 2NF, 3NF, and BCNF, and verify both **Lossless Join** decomposition and **Dependency Preservation** using SQL verification queries.
- **Deliverables**: [experiment7.md](Experiment%2007/experiment7.md) and [queries.sql](Experiment%2007/queries.sql).

---

### [Experiment 08: Banking Transactions, Partial Failures, and Concurrency Control](Experiment%2008/experiment8.md)
- **Course Outcome**: `CO4`
- **Aim**: To implement banking transactions using `START TRANSACTION`, `COMMIT`, `ROLLBACK`, and `SAVEPOINT` for partial failure handling. Demonstrate transaction isolation levels (`READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`) and concurrency anomalies (**Dirty Read**, **Non-Repeatable Read**, **Phantom Read**, **Lost Update**) across two client sessions.
- **Deliverables**: [experiment8.md](Experiment%2008/experiment8.md) and [queries.sql](Experiment%2008/queries.sql).

---

### [Experiment 09: Railway Booking Indexing & Benchmarking (5,000+ Records)](Experiment%2009/experiment9.md)
- **Course Outcome**: `CO5`
- **Aim**: To design a Railway Ticket Booking system, populate at least 5,000 records via automated stored procedures, benchmark query execution plans using `EXPLAIN` before and after creating single and composite B-Tree indexes, and quantify execution speedup factors.
- **Deliverables**: [experiment9.md](Experiment%2009/experiment9.md) and [queries.sql](Experiment%2009/queries.sql).

---

### [Experiment 10: Query Optimization, EXPLAIN Analysis, and Performance Tuning (10,000+ Rows)](Experiment%2010/experiment10.md)
- **Course Outcome**: `CO5`
- **Aim**: To generate an e-commerce dataset containing over 10,000 records, write 5 representative slow queries representing database anti-patterns (non-SARGable predicates, leading wildcards, correlated scalar subqueries, deep offset pagination, unindexed multi-table joins), optimize each query through indexing and query rewriting, and compare execution times using `EXPLAIN`.
- **Deliverables**: [experiment10.md](Experiment%2010/experiment10.md) and [queries.sql](Experiment%2010/queries.sql).

---

## 🛠️ Environment & Prerequisites

- **RDBMS**: MySQL Server 8.0+
- **Interface**: MySQL Workbench / MySQL CLI Shell
- **Execution**:
  ```bash
  # Execute any experiment's SQL script
  mysql -u root -p < "Experiment 07/queries.sql"
  ```

---

## 📚 Textbooks & Reference Books

1. **Elmasri, R., & Navathe, S. B.** — *Fundamentals of Database Systems*, Pearson.
2. **Ramakrishnan, R., & Gehrke, J.** — *Database Management Systems*, McGraw-Hill.
3. **Date, C. J.** — *An Introduction to Database Systems*, Pearson.
4. **Garcia-Molina, H., Ullman, J. D., & Widom, J.** — *Database Systems: The Complete Book*, Pearson.
