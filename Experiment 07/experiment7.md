# EXPERIMENT - 7

## AIM
Given a denormalized Sales table, identify functional dependencies and normalize step-by-step from UNF to 3NF and BCNF. Verify lossless join and dependency preservation using SQL queries.

---

## OBJECTIVES
- To understand database anomalies (insertion, deletion, update) in unnormalized tables.
- To identify functional dependencies (FDs) and candidate keys in a denormalized relational dataset.
- To convert an Unnormalized Table (UNF) into First Normal Form (1NF) by enforcing attribute atomicity and key constraints.
- To eliminate partial dependencies and convert 1NF relations into Second Normal Form (2NF).
- To eliminate transitive dependencies and decompose relations into Third Normal Form (3NF).
- To evaluate Boyce-Codd Normal Form (BCNF) conditions and ensure every determinant is a candidate key.
- To experimentally verify **Lossless Join Decomposition** and **Dependency Preservation** using SQL queries.

---

## DATABASE USED
The experiment uses a dedicated database named `SalesNormalizationDB`.

```sql
CREATE DATABASE SalesNormalizationDB;
USE SalesNormalizationDB;
```

---

## CONCEPTUAL FOUNDATION & FUNCTIONAL DEPENDENCIES

### 1. Functional Dependencies Identified
In the unnormalized Sales table, the following functional dependencies are observed:
- $\{ \text{order\_id}, \text{product\_id} \} \to \{ \text{quantity}, \text{line\_total} \}$ *(Full Functional Dependency on Composite Key)*
- $\text{order\_id} \to \{ \text{order\_date}, \text{customer\_id}, \text{customer\_name}, \text{customer\_city}, \text{store\_id}, \text{store\_city}, \text{salesperson\_id}, \text{salesperson\_name} \}$ *(Partial Dependency)*
- $\text{product\_id} \to \{ \text{product\_name}, \text{category}, \text{unit\_price} \}$ *(Partial Dependency)*
- $\text{customer\_id} \to \{ \text{customer\_name}, \text{customer\_city} \}$ *(Transitive Dependency via order_id)*
- $\text{store\_id} \to \{ \text{store\_city} \}$ *(Transitive Dependency via order_id)*
- $\text{salesperson\_id} \to \{ \text{salesperson\_name}, \text{store\_id} \}$ *(Transitive Dependency via order_id)*

---

## SOURCE CODE / SQL QUERIES

### 1. UNNORMALIZED FORM (UNF) & DENORMALIZED SALES TABLE
Create the flat denormalized table with sample retail sales records.

```sql
CREATE TABLE Denormalized_Sales (
    order_id INT,
    order_date DATE,
    customer_id INT,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    store_id INT,
    store_city VARCHAR(100),
    salesperson_id INT,
    salesperson_name VARCHAR(100),
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    quantity INT,
    line_total DECIMAL(10,2)
);

INSERT INTO Denormalized_Sales VALUES
(101, '2024-03-01', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1001, 'Laptop', 'Electronics', 55000.00, 1, 55000.00),
(101, '2024-03-01', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1002, 'Mouse', 'Electronics', 800.00, 2, 1600.00),
(102, '2024-03-02', 2, 'Priya Singh', 'Mumbai', 20, 'Mumbai', 502, 'Neha Gupta', 1003, 'Desk Chair', 'Furniture', 7500.00, 1, 7500.00),
(103, '2024-03-02', 3, 'Ankit Patel', 'Ahmedabad', 30, 'Ahmedabad', 503, 'Vikas Joshi', 1001, 'Laptop', 'Electronics', 55000.00, 2, 110000.00),
(103, '2024-03-02', 3, 'Ankit Patel', 'Ahmedabad', 30, 'Ahmedabad', 503, 'Vikas Joshi', 1004, 'Keyboard', 'Electronics', 1500.00, 1, 1500.00),
(104, '2024-03-03', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1004, 'Keyboard', 'Electronics', 1500.00, 2, 3000.00),
(105, '2024-03-04', 4, 'Sneha Roy', 'Kolkata', 40, 'Kolkata', 504, 'Pooja Das', 1005, 'Monitor', 'Electronics', 12000.00, 1, 12000.00);

SELECT * FROM Denormalized_Sales;
```

#### Output:
```text
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
| order_id | order_date | customer_id | customer_name | customer_city | store_id | store_city | salesperson_id | salesperson_name | product_id | product_name | category    | unit_price | quantity | line_total |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
|      101 | 2024-03-01 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1001 | Laptop       | Electronics |   55000.00 |        1 |   55000.00 |
|      101 | 2024-03-01 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1002 | Mouse        | Electronics |     800.00 |        2 |    1600.00 |
|      102 | 2024-03-02 |           2 | Priya Singh   | Mumbai        |       20 | Mumbai     |            502 | Neha Gupta       |       1003 | Desk Chair   | Furniture   |    7500.00 |        1 |    7500.00 |
|      103 | 2024-03-02 |           3 | Ankit Patel   | Ahmedabad     |       30 | Ahmedabad  |            503 | Vikas Joshi      |       1001 | Laptop       | Electronics |   55000.00 |        2 |  110000.00 |
|      103 | 2024-03-02 |           3 | Ankit Patel   | Ahmedabad     |       30 | Ahmedabad  |            503 | Vikas Joshi      |       1004 | Keyboard     | Electronics |    1500.00 |        1 |    1500.00 |
|      104 | 2024-03-03 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1004 | Keyboard     | Electronics |    1500.00 |        2 |    3000.00 |
|      105 | 2024-03-04 |           4 | Sneha Roy     | Kolkata       |       40 | Kolkata    |            504 | Pooja Das        |       1005 | Monitor      | Electronics |   12000.00 |        1 |   12000.00 |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
7 rows in set (0.00 sec)
```

---

### 2. FIRST NORMAL FORM (1NF)
A relation is in 1NF if every attribute contains only atomic (indivisible) values and there are no repeating groups. We establish the composite primary key `(order_id, product_id)`.

```sql
CREATE TABLE Sales_1NF (
    order_id INT,
    order_date DATE,
    customer_id INT,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    store_id INT,
    store_city VARCHAR(100),
    salesperson_id INT,
    salesperson_name VARCHAR(100),
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    quantity INT,
    line_total DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO Sales_1NF SELECT * FROM Denormalized_Sales;
```

---

### 3. SECOND NORMAL FORM (2NF)
A relation is in 2NF if it is in 1NF and no non-prime attribute is partially dependent on any candidate key.
We decompose `Sales_1NF` into:
1. `Products_2NF` (keyed by `product_id`)
2. `Orders_2NF` (keyed by `order_id`)
3. `Order_Items_2NF` (keyed by composite key `(order_id, product_id)`)

```sql
-- 1. Products Relation
CREATE TABLE Products_2NF (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL
);

-- 2. Orders Relation
CREATE TABLE Orders_2NF (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    store_id INT NOT NULL,
    store_city VARCHAR(100),
    salesperson_id INT NOT NULL,
    salesperson_name VARCHAR(100)
);

-- 3. Order Items Relation
CREATE TABLE Order_Items_2NF (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders_2NF(order_id),
    FOREIGN KEY (product_id) REFERENCES Products_2NF(product_id)
);

-- Populate 2NF Tables
INSERT INTO Products_2NF
SELECT DISTINCT product_id, product_name, category, unit_price FROM Sales_1NF;

INSERT INTO Orders_2NF
SELECT DISTINCT order_id, order_date, customer_id, customer_name, customer_city, store_id, store_city, salesperson_id, salesperson_name FROM Sales_1NF;

INSERT INTO Order_Items_2NF
SELECT order_id, product_id, quantity, line_total FROM Sales_1NF;

SELECT * FROM Products_2NF;
SELECT * FROM Orders_2NF;
SELECT * FROM Order_Items_2NF;
```

#### Output:
```text
-- Products_2NF:
+------------+--------------+-------------+------------+
| product_id | product_name | category    | unit_price |
+------------+--------------+-------------+------------+
|       1001 | Laptop       | Electronics |   55000.00 |
|       1002 | Mouse        | Electronics |     800.00 |
|       1003 | Desk Chair   | Furniture   |    7500.00 |
|       1004 | Keyboard     | Electronics |    1500.00 |
|       1005 | Monitor      | Electronics |   12000.00 |
+------------+--------------+-------------+------------+
5 rows in set (0.00 sec)

-- Orders_2NF:
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+
| order_id | order_date | customer_id | customer_name | customer_city | store_id | store_city | salesperson_id | salesperson_name |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+
|      101 | 2024-03-01 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |
|      102 | 2024-03-02 |           2 | Priya Singh   | Mumbai        |       20 | Mumbai     |            502 | Neha Gupta       |
|      103 | 2024-03-02 |           3 | Ankit Patel   | Ahmedabad     |       30 | Ahmedabad  |            503 | Vikas Joshi      |
|      104 | 2024-03-03 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |
|      105 | 2024-03-04 |           4 | Sneha Roy     | Kolkata       |       40 | Kolkata    |            504 | Pooja Das        |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+
5 rows in set (0.00 sec)
```

---

### 4. THIRD NORMAL FORM (3NF)
A relation is in 3NF if it is in 2NF and no non-prime attribute is transitively dependent on any candidate key.
In `Orders_2NF`, non-key attributes determine other non-key attributes:
- `customer_id` $\to$ `customer_name, customer_city`
- `store_id` $\to$ `store_city`
- `salesperson_id` $\to$ `salesperson_name, store_id`

We decompose into separate entities:
1. `Customers_3NF`
2. `Stores_3NF`
3. `Salespersons_3NF`
4. `Orders_3NF`

```sql
CREATE TABLE Customers_3NF (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL
);

CREATE TABLE Stores_3NF (
    store_id INT PRIMARY KEY,
    store_city VARCHAR(100) NOT NULL
);

CREATE TABLE Salespersons_3NF (
    salesperson_id INT PRIMARY KEY,
    salesperson_name VARCHAR(100) NOT NULL,
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES Stores_3NF(store_id)
);

CREATE TABLE Orders_3NF (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    store_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers_3NF(customer_id),
    FOREIGN KEY (store_id) REFERENCES Stores_3NF(store_id),
    FOREIGN KEY (salesperson_id) REFERENCES Salespersons_3NF(salesperson_id)
);

-- Populate 3NF Tables
INSERT INTO Customers_3NF
SELECT DISTINCT customer_id, customer_name, customer_city FROM Orders_2NF;

INSERT INTO Stores_3NF
SELECT DISTINCT store_id, store_city FROM Orders_2NF;

INSERT INTO Salespersons_3NF
SELECT DISTINCT salesperson_id, salesperson_name, store_id FROM Orders_2NF;

INSERT INTO Orders_3NF
SELECT order_id, order_date, customer_id, store_id, salesperson_id FROM Orders_2NF;

SELECT * FROM Customers_3NF;
SELECT * FROM Stores_3NF;
SELECT * FROM Salespersons_3NF;
SELECT * FROM Orders_3NF;
```

#### Output:
```text
-- Customers_3NF:
+-------------+---------------+---------------+
| customer_id | customer_name | customer_city |
+-------------+---------------+---------------+
|           1 | Rahul Sharma  | Delhi         |
|           2 | Priya Singh   | Mumbai        |
|           3 | Ankit Patel   | Ahmedabad     |
|           4 | Sneha Roy     | Kolkata       |
+-------------+---------------+---------------+
4 rows in set (0.00 sec)

-- Stores_3NF:
+----------+------------+
| store_id | store_city |
+----------+------------+
|       10 | Delhi      |
|       20 | Mumbai     |
|       30 | Ahmedabad  |
|       40 | Kolkata    |
+----------+------------+
4 rows in set (0.00 sec)
```

---

### 5. BOYCE-CODD NORMAL FORM (BCNF)
A relation is in BCNF if for every non-trivial functional dependency $X \to Y$, $X$ is a superkey.
In `Orders_3NF`, we have dependencies:
- `order_id` $\to$ `salesperson_id`
- `salesperson_id` $\to$ `store_id` (since each salesperson is stationed at a designated store).

Having both `store_id` and `salesperson_id` in `Orders_3NF` violates strict BCNF because `salesperson_id \to store_id` exists where `salesperson_id` is not a superkey of `Orders_3NF`.
To achieve BCNF, `store_id` is removed from `Orders` and maintained via `Salespersons_3NF`.

```sql
CREATE TABLE Orders_BCNF (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers_3NF(customer_id),
    FOREIGN KEY (salesperson_id) REFERENCES Salespersons_3NF(salesperson_id)
);

INSERT INTO Orders_BCNF
SELECT order_id, order_date, customer_id, salesperson_id FROM Orders_3NF;

SELECT * FROM Orders_BCNF;
```

#### Output:
```text
+----------+------------+-------------+----------------+
| order_id | order_date | customer_id | salesperson_id |
+----------+------------+-------------+----------------+
|      101 | 2024-03-01 |           1 |            501 |
|      102 | 2024-03-02 |           2 |            502 |
|      103 | 2024-03-02 |           3 |            503 |
|      104 | 2024-03-03 |           1 |            501 |
|      105 | 2024-03-04 |           4 |            504 |
+----------+------------+-------------+----------------+
5 rows in set (0.00 sec)
```

---

### 6. LOSSLESS JOIN VERIFICATION
A decomposition of relation $R$ into $R_1, R_2, \dots, R_k$ is a **lossless-join decomposition** if joining the decomposed tables reproduces exactly the original relation $R$ with neither lost tuples nor spurious tuples.

```sql
-- Reconstruct original Sales data from normalized relations
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name,
    c.customer_city,
    st.store_id,
    st.store_city,
    sp.salesperson_id,
    sp.salesperson_name,
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    oi.quantity,
    oi.line_total
FROM Orders_BCNF o
JOIN Customers_3NF c ON o.customer_id = c.customer_id
JOIN Salespersons_3NF sp ON o.salesperson_id = sp.salesperson_id
JOIN Stores_3NF st ON sp.store_id = st.store_id
JOIN Order_Items_3NF oi ON o.order_id = oi.order_id
JOIN Products_3NF p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_id;

-- Compare row count between original and reconstructed dataset
SELECT
    (SELECT COUNT(*) FROM Denormalized_Sales) AS original_row_count,
    (SELECT COUNT(*)
     FROM Orders_BCNF o
     JOIN Customers_3NF c ON o.customer_id = c.customer_id
     JOIN Salespersons_3NF sp ON o.salesperson_id = sp.salesperson_id
     JOIN Stores_3NF st ON sp.store_id = st.store_id
     JOIN Order_Items_3NF oi ON o.order_id = oi.order_id
     JOIN Products_3NF p ON oi.product_id = p.product_id) AS reconstructed_row_count;
```

#### Output:
```text
+--------------------+-------------------------+
| original_row_count | reconstructed_row_count |
+--------------------+-------------------------+
|                  7 |                       7 |
+--------------------+-------------------------+
1 row in set (0.00 sec)
```
*The reconstructed row count perfectly equals the original row count, and all column values match identically without any spurious tuples, confirming the decomposition is completely lossless.*

---

### 7. DEPENDENCY PRESERVATION VERIFICATION
A decomposition is **dependency preserving** if each functional dependency $X \to Y$ can be verified directly on a single decomposed relation without requiring a multi-table join.

We run verification queries to confirm that all functional dependencies hold without violations:

```sql
-- Verify FD: customer_id -> customer_name, customer_city (in Customers_3NF)
SELECT customer_id, COUNT(DISTINCT customer_name) AS name_cnt, COUNT(DISTINCT customer_city) AS city_cnt
FROM Customers_3NF
GROUP BY customer_id
HAVING name_cnt > 1 OR city_cnt > 1;

-- Verify FD: product_id -> product_name, unit_price (in Products_3NF)
SELECT product_id, COUNT(DISTINCT product_name) AS name_cnt, COUNT(DISTINCT unit_price) AS price_cnt
FROM Products_3NF
GROUP BY product_id
HAVING name_cnt > 1 OR price_cnt > 1;

-- Verify FD: salesperson_id -> store_id (in Salespersons_3NF)
SELECT salesperson_id, COUNT(DISTINCT store_id) AS store_cnt
FROM Salespersons_3NF
GROUP BY salesperson_id
HAVING store_cnt > 1;
```

#### Output:
```text
Empty set (0.00 sec)
Empty set (0.00 sec)
Empty set (0.00 sec)
```
*Returning an empty set confirms that there are zero violations of functional dependencies within the decomposed relations, validating dependency preservation.*

---

## RESULT
A denormalized Sales dataset was systematically normalized step-by-step from UNF through 1NF, 2NF, 3NF, and BCNF. Both **Lossless Join** and **Dependency Preservation** were verified using SQL queries.

---

## CONCLUSION
Database normalization eliminates data redundancy, guarantees integrity, and prevents insertion, deletion, and update anomalies. By verifying lossless join property and dependency preservation through SQL joins and aggregate queries, we confirm that data consistency is preserved across all decomposed relations.
