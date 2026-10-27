-- ==========================================================
-- EXPERIMENT 10: Query Optimization, EXPLAIN Analysis,
--                and Performance Tuning (10,000+ Rows)
-- ==========================================================

DROP DATABASE IF EXISTS EcommerceOptimizationDB;
CREATE DATABASE EcommerceOptimizationDB;
USE EcommerceOptimizationDB;

-- ==========================================================
-- 1. SCHEMA CREATION & BULK DATASET GENERATION (10,000+ ROWS)
-- ==========================================================

DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Procedure to generate 2,000 customers and 10,000 orders
DELIMITER //
CREATE PROCEDURE PopulateOptimizationData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_city VARCHAR(50);
    DECLARE v_status VARCHAR(20);
    DECLARE v_payment VARCHAR(20);
    DECLARE v_domain VARCHAR(20);
    
    SET autocommit = 0;

    -- 1. Insert 2,000 Customers
    WHILE i <= 2000 DO
        CASE (i % 5)
            WHEN 0 THEN SET v_city = 'Delhi';
            WHEN 1 THEN SET v_city = 'Mumbai';
            WHEN 2 THEN SET v_city = 'Bangalore';
            WHEN 3 THEN SET v_city = 'Hyderabad';
            ELSE SET v_city = 'Kolkata';
        END CASE;

        CASE (i % 4)
            WHEN 0 THEN SET v_domain = 'gmail.com';
            WHEN 1 THEN SET v_domain = 'yahoo.com';
            WHEN 2 THEN SET v_domain = 'outlook.com';
            ELSE SET v_domain = 'example.in';
        END CASE;

        INSERT INTO Customers (customer_name, email, city, signup_date)
        VALUES (
            CONCAT('Customer_', i),
            CONCAT('user', i, '@', v_domain),
            v_city,
            DATE_ADD('2022-01-01', INTERVAL (i % 700) DAY)
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;

    -- 2. Insert 10,000 Orders
    SET i = 1;
    WHILE i <= 10000 DO
        CASE (i % 4)
            WHEN 0 THEN SET v_status = 'DELIVERED';
            WHEN 1 THEN SET v_status = 'SHIPPED';
            WHEN 2 THEN SET v_status = 'PROCESSING';
            ELSE SET v_status = 'CANCELLED';
        END CASE;

        CASE (i % 3)
            WHEN 0 THEN SET v_payment = 'UPI';
            WHEN 1 THEN SET v_payment = 'Credit Card';
            ELSE SET v_payment = 'Net Banking';
        END CASE;

        INSERT INTO Orders (customer_id, order_date, order_status, payment_method, total_amount)
        VALUES (
            (i % 2000) + 1,
            DATE_ADD('2023-01-01', INTERVAL (i % 500) DAY),
            v_status,
            v_payment,
            ROUND(500 + (RAND() * 9500), 2)
        );

        IF (i % 1000 = 0) THEN
            COMMIT;
        END IF;

        SET i = i + 1;
    END WHILE;
    COMMIT;
    SET autocommit = 1;
END //
DELIMITER ;

CALL PopulateOptimizationData();

SELECT COUNT(*) AS total_customers FROM Customers;
SELECT COUNT(*) AS total_orders FROM Orders;

-- ==========================================================
-- 2. SLOW QUERY 1: NON-SARGABLE DATE FUNCTION
-- Problem: YEAR() and MONTH() prevent B-Tree index traversal.
-- ==========================================================

-- Slow Version:
EXPLAIN
SELECT order_id, customer_id, order_date, total_amount
FROM Orders
WHERE YEAR(order_date) = 2024 AND MONTH(order_date) = 5;

-- Optimization 1: Create B-Tree Index
CREATE INDEX idx_orders_date ON Orders(order_date);

-- Optimization 2: Rewrite to SARGable date range predicate
EXPLAIN
SELECT order_id, customer_id, order_date, total_amount
FROM Orders
WHERE order_date >= '2024-05-01' AND order_date < '2024-06-01';

-- ==========================================================
-- 3. SLOW QUERY 2: LEADING WILDCARD TEXT SEARCH
-- Problem: LIKE '%@gmail.com' cannot use standard B-Tree index.
-- ==========================================================

-- Slow Version:
EXPLAIN
SELECT customer_id, customer_name, email
FROM Customers
WHERE email LIKE '%@gmail.com';

-- Optimization: Add Stored Generated Column for Email Domain + Index
ALTER TABLE Customers
ADD COLUMN email_domain VARCHAR(50) AS (SUBSTRING_INDEX(email, '@', -1)) STORED;

CREATE INDEX idx_customers_domain ON Customers(email_domain);

-- Optimized Rewritten Query:
EXPLAIN
SELECT customer_id, customer_name, email
FROM Customers
WHERE email_domain = 'gmail.com';

-- ==========================================================
-- 4. SLOW QUERY 3: CORRELATED SCALAR SUBQUERY
-- Problem: Subquery re-executes for each of the 2,000 customers.
-- ==========================================================

-- Slow Version:
EXPLAIN
SELECT
    c.customer_id,
    c.customer_name,
    (SELECT COUNT(*) FROM Orders o WHERE o.customer_id = c.customer_id) AS total_orders,
    (SELECT SUM(total_amount) FROM Orders o WHERE o.customer_id = c.customer_id) AS total_spent
FROM Customers c;

-- Optimization: Rewrite using LEFT JOIN with derived pre-aggregated table
-- + Composite Index on Orders(customer_id, total_amount)
CREATE INDEX idx_orders_customer_amount ON Orders(customer_id, total_amount);

EXPLAIN
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(agg.total_orders, 0) AS total_orders,
    COALESCE(agg.total_spent, 0.00) AS total_spent
FROM Customers c
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS total_orders, SUM(total_amount) AS total_spent
    FROM Orders
    GROUP BY customer_id
) agg ON c.customer_id = agg.customer_id;

-- ==========================================================
-- 5. SLOW QUERY 4: DEEP OFFSET PAGINATION
-- Problem: Scanning and discarding 9,500 rows to return 20.
-- ==========================================================

-- Slow Version:
EXPLAIN
SELECT order_id, customer_id, order_date, total_amount
FROM Orders
ORDER BY order_id
LIMIT 20 OFFSET 9500;

-- Optimization: Keyset Pagination (Seek Method) using Clustered Index
EXPLAIN
SELECT order_id, customer_id, order_date, total_amount
FROM Orders
WHERE order_id > 9500
ORDER BY order_id
LIMIT 20;

-- ==========================================================
-- 6. SLOW QUERY 5: UNINDEXED MULTI-TABLE JOIN + AGGREGATION
-- Problem: Nested-loop join with temporary table & filesort.
-- ==========================================================

-- Slow Version:
EXPLAIN
SELECT c.city, o.order_status, COUNT(o.order_id) AS order_count, SUM(o.total_amount) AS total_revenue
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'DELIVERED'
GROUP BY c.city, o.order_status
ORDER BY total_revenue DESC;

-- Optimization: Add Composite Index on Orders(order_status, customer_id, total_amount)
CREATE INDEX idx_orders_status_cust_amt ON Orders(order_status, customer_id, total_amount);
CREATE INDEX idx_customers_cust_city ON Customers(customer_id, city);

-- Optimized Plan check:
EXPLAIN
SELECT c.city, o.order_status, COUNT(o.order_id) AS order_count, SUM(o.total_amount) AS total_revenue
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'DELIVERED'
GROUP BY c.city, o.order_status
ORDER BY total_revenue DESC;
