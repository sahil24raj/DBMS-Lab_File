-- ==========================================================
-- EXPERIMENT 7: Normalization (UNF to 3NF and BCNF)
--               Lossless Join & Dependency Preservation
-- ==========================================================

DROP DATABASE IF EXISTS SalesNormalizationDB;
CREATE DATABASE SalesNormalizationDB;
USE SalesNormalizationDB;

-- ==========================================================
-- 1. UNNORMALIZED FORM (UNF) / DENORMALIZED SALES TABLE
-- ==========================================================

DROP TABLE IF EXISTS Denormalized_Sales;
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

-- Insert sample denormalized data
INSERT INTO Denormalized_Sales VALUES
(101, '2024-03-01', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1001, 'Laptop', 'Electronics', 55000.00, 1, 55000.00),
(101, '2024-03-01', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1002, 'Mouse', 'Electronics', 800.00, 2, 1600.00),
(102, '2024-03-02', 2, 'Priya Singh', 'Mumbai', 20, 'Mumbai', 502, 'Neha Gupta', 1003, 'Desk Chair', 'Furniture', 7500.00, 1, 7500.00),
(103, '2024-03-02', 3, 'Ankit Patel', 'Ahmedabad', 30, 'Ahmedabad', 503, 'Vikas Joshi', 1001, 'Laptop', 'Electronics', 55000.00, 2, 110000.00),
(103, '2024-03-02', 3, 'Ankit Patel', 'Ahmedabad', 30, 'Ahmedabad', 503, 'Vikas Joshi', 1004, 'Keyboard', 'Electronics', 1500.00, 1, 1500.00),
(104, '2024-03-03', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1004, 'Keyboard', 'Electronics', 1500.00, 2, 3000.00),
(105, '2024-03-04', 4, 'Sneha Roy', 'Kolkata', 40, 'Kolkata', 504, 'Pooja Das', 1005, 'Monitor', 'Electronics', 12000.00, 1, 12000.00);

SELECT * FROM Denormalized_Sales;

-- ==========================================================
-- 2. FIRST NORMAL FORM (1NF)
-- Ensure all attributes are atomic, no repeating groups.
-- Primary Key: (order_id, product_id)
-- ==========================================================

DROP TABLE IF EXISTS Sales_1NF;
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

SELECT * FROM Sales_1NF;

-- ==========================================================
-- 3. SECOND NORMAL FORM (2NF)
-- Remove Partial Functional Dependencies:
-- order_id -> order_date, customer_id, customer_name, customer_city, store_id, store_city, salesperson_id, salesperson_name
-- product_id -> product_name, category, unit_price
-- ==========================================================

DROP TABLE IF EXISTS Order_Items_2NF;
DROP TABLE IF EXISTS Products_2NF;
DROP TABLE IF EXISTS Orders_2NF;

-- Products relation (eliminates partial dependency on composite key)
CREATE TABLE Products_2NF (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL
);

-- Orders relation
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

-- Order Items relation (fully dependent on composite key)
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
INSERT INTO Products_2NF (product_id, product_name, category, unit_price)
SELECT DISTINCT product_id, product_name, category, unit_price
FROM Sales_1NF;

INSERT INTO Orders_2NF (order_id, order_date, customer_id, customer_name, customer_city, store_id, store_city, salesperson_id, salesperson_name)
SELECT DISTINCT order_id, order_date, customer_id, customer_name, customer_city, store_id, store_city, salesperson_id, salesperson_name
FROM Sales_1NF;

INSERT INTO Order_Items_2NF (order_id, product_id, quantity, line_total)
SELECT order_id, product_id, quantity, line_total
FROM Sales_1NF;

SELECT * FROM Products_2NF;
SELECT * FROM Orders_2NF;
SELECT * FROM Order_Items_2NF;

-- ==========================================================
-- 4. THIRD NORMAL FORM (3NF)
-- Remove Transitive Functional Dependencies:
-- customer_id -> customer_name, customer_city (transitive via order_id)
-- store_id -> store_city (transitive via order_id)
-- salesperson_id -> salesperson_name (transitive via order_id)
-- ==========================================================

DROP TABLE IF EXISTS Order_Items_3NF;
DROP TABLE IF EXISTS Orders_3NF;
DROP TABLE IF EXISTS Salespersons_3NF;
DROP TABLE IF EXISTS Stores_3NF;
DROP TABLE IF EXISTS Customers_3NF;
DROP TABLE IF EXISTS Products_3NF;

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

CREATE TABLE Products_3NF (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL
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

CREATE TABLE Order_Items_3NF (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders_3NF(order_id),
    FOREIGN KEY (product_id) REFERENCES Products_3NF(product_id)
);

-- Populate 3NF Tables
INSERT INTO Customers_3NF
SELECT DISTINCT customer_id, customer_name, customer_city FROM Orders_2NF;

INSERT INTO Stores_3NF
SELECT DISTINCT store_id, store_city FROM Orders_2NF;

INSERT INTO Salespersons_3NF
SELECT DISTINCT salesperson_id, salesperson_name, store_id FROM Orders_2NF;

INSERT INTO Products_3NF
SELECT * FROM Products_2NF;

INSERT INTO Orders_3NF
SELECT order_id, order_date, customer_id, store_id, salesperson_id FROM Orders_2NF;

INSERT INTO Order_Items_3NF
SELECT * FROM Order_Items_2NF;

SELECT * FROM Customers_3NF;
SELECT * FROM Stores_3NF;
SELECT * FROM Salespersons_3NF;
SELECT * FROM Products_3NF;
SELECT * FROM Orders_3NF;
SELECT * FROM Order_Items_3NF;

-- ==========================================================
-- 5. BOYCE-CODD NORMAL FORM (BCNF)
-- Condition: For every non-trivial FD X -> Y, X must be a superkey.
-- Verify Salespersons determinant: salesperson_id -> store_id.
-- In Orders_3NF, salesperson_id determines store_id (since a salesperson belongs to one store).
-- To satisfy BCNF strictly, store_id is removed from Orders and referenced solely through Salespersons.
-- ==========================================================

DROP TABLE IF EXISTS Orders_BCNF;

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

-- ==========================================================
-- 6. LOSSLESS JOIN VERIFICATION
-- Reconstruct original Sales data by joining normalized relations
-- Verify that: (Decomposed Tables NATURAL/INNER JOIN) = Denormalized_Sales
-- ==========================================================

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

-- Check tuple count equality (Lossless test)
SELECT
    (SELECT COUNT(*) FROM Denormalized_Sales) AS original_row_count,
    (SELECT COUNT(*)
     FROM Orders_BCNF o
     JOIN Customers_3NF c ON o.customer_id = c.customer_id
     JOIN Salespersons_3NF sp ON o.salesperson_id = sp.salesperson_id
     JOIN Stores_3NF st ON sp.store_id = st.store_id
     JOIN Order_Items_3NF oi ON o.order_id = oi.order_id
     JOIN Products_3NF p ON oi.product_id = p.product_id) AS reconstructed_row_count;

-- ==========================================================
-- 7. DEPENDENCY PRESERVATION VERIFICATION
-- Ensure functional dependencies can be checked within individual tables
-- ==========================================================

-- Check FD: customer_id -> customer_name, customer_city
SELECT customer_id, COUNT(DISTINCT customer_name), COUNT(DISTINCT customer_city)
FROM Customers_3NF
GROUP BY customer_id
HAVING COUNT(DISTINCT customer_name) > 1 OR COUNT(DISTINCT customer_city) > 1;

-- Check FD: product_id -> product_name, unit_price
SELECT product_id, COUNT(DISTINCT product_name), COUNT(DISTINCT unit_price)
FROM Products_3NF
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1 OR COUNT(DISTINCT unit_price) > 1;

-- Check FD: salesperson_id -> store_id
SELECT salesperson_id, COUNT(DISTINCT store_id)
FROM Salespersons_3NF
GROUP BY salesperson_id
HAVING COUNT(DISTINCT store_id) > 1;
