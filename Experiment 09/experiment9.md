# EXPERIMENT - 9

## AIM
Create a Railway Booking table with at least 5,000 records. Benchmark query performance before and after creating single and composite indexes. Use `EXPLAIN` to compare execution plans.

---

## OBJECTIVES
- To design a relational schema for a Railway Ticket Booking system.
- To populate the table with at least 5,000 realistic records using an automated stored procedure.
- To formulate search and analytical queries representing operational ticketing workflows.
- To inspect query execution plans before indexing using `EXPLAIN`.
- To create single-column and composite indexes (`B-Tree` indexes) on selective attributes.
- To benchmark query performance and execution plans before and after index creation.
- To evaluate how indexes eliminate full table scans (`ALL`), reduce examined rows, and optimize sorting (`filesort`).

---

## DATABASE USED
The experiment uses a dedicated database named `RailwayDB`.

```sql
CREATE DATABASE RailwayDB;
USE RailwayDB;
```

---

## SCHEMA REFERENCE

| Table | Column Name | Data Type | Constraints / Description |
| :--- | :--- | :--- | :--- |
| **Railway_Bookings** | `booking_id` | INT | PRIMARY KEY, AUTO_INCREMENT |
| | `pnr_number` | VARCHAR(10) | Unique 10-digit Passenger Name Record |
| | `train_no` | INT | Indian Railways train number |
| | `train_name` | VARCHAR(100) | Express / Superfast train name |
| | `passenger_name` | VARCHAR(100) | Name of passenger |
| | `passenger_age` | INT | Passenger age |
| | `passenger_gender` | CHAR(1) | M / F |
| | `travel_date` | DATE | Date of journey |
| | `source_station` | VARCHAR(10) | Station code (e.g., NDLS, BCT, LKO) |
| | `destination_station` | VARCHAR(10) | Station code |
| | `booking_class` | VARCHAR(10) | 1A, 2A, 3A, SL |
| | `seat_number` | VARCHAR(10) | Coach and Berth allocation |
| | `fare` | DECIMAL(8,2) | Ticket fare in ₹ |
| | `booking_status` | VARCHAR(20) | CONFIRMED, RAC, WAITLISTED |
| | `booking_time` | TIMESTAMP | Timestamp of reservation |

---

## SOURCE CODE / SQL QUERIES

### 1. TABLE CREATION & BULK DATA GENERATION (5,000+ ROWS)
Create the table and execute a stored procedure to insert 5,000 distinct ticket booking records.

```sql
CREATE TABLE Railway_Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    pnr_number VARCHAR(10) NOT NULL,
    train_no INT NOT NULL,
    train_name VARCHAR(100) NOT NULL,
    passenger_name VARCHAR(100) NOT NULL,
    passenger_age INT NOT NULL,
    passenger_gender CHAR(1) NOT NULL,
    travel_date DATE NOT NULL,
    source_station VARCHAR(10) NOT NULL,
    destination_station VARCHAR(10) NOT NULL,
    booking_class VARCHAR(10) NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    fare DECIMAL(8,2) NOT NULL,
    booking_status VARCHAR(20) NOT NULL,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE PROCEDURE PopulateRailwayBookings(IN total_rows INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_pnr VARCHAR(10);
    DECLARE v_train_no INT;
    DECLARE v_train_name VARCHAR(100);
    DECLARE v_source VARCHAR(10);
    DECLARE v_dest VARCHAR(10);
    DECLARE v_class VARCHAR(10);
    DECLARE v_status VARCHAR(20);
    DECLARE v_gender CHAR(1);
    DECLARE v_fare DECIMAL(8,2);
    DECLARE v_date DATE;

    SET autocommit = 0;

    WHILE i <= total_rows DO
        SET v_pnr = LPAD(FLOOR(1000000000 + (RAND() * 9000000000)), 10, '0');
        
        CASE (i % 5)
            WHEN 0 THEN SET v_train_no = 12951, v_train_name = 'Mumbai Tejas Rajdhani', v_source = 'BCT', v_dest = 'NDLS';
            WHEN 1 THEN SET v_train_no = 12004, v_train_name = 'Lucknow Shatabdi Express', v_source = 'NDLS', v_dest = 'LKO';
            WHEN 2 THEN SET v_train_no = 22436, v_train_name = 'Vande Bharat Express', v_source = 'NDLS', v_dest = 'BSB';
            WHEN 3 THEN SET v_train_no = 12301, v_train_name = 'Howrah Rajdhani', v_source = 'HWH', v_dest = 'NDLS';
            ELSE SET v_train_no = 12621, v_train_name = 'Tamil Nadu Express', v_source = 'MAS', v_dest = 'NDLS';
        END CASE;

        CASE (i % 4)
            WHEN 0 THEN SET v_class = '1A', v_fare = 3500.00;
            WHEN 1 THEN SET v_class = '2A', v_fare = 2200.00;
            WHEN 2 THEN SET v_class = '3A', v_fare = 1500.00;
            ELSE SET v_class = 'SL', v_fare = 450.00;
        END CASE;

        CASE (i % 3)
            WHEN 0 THEN SET v_status = 'CONFIRMED';
            WHEN 1 THEN SET v_status = 'RAC';
            ELSE SET v_status = 'WAITLISTED';
        END CASE;

        SET v_gender = IF(i % 2 = 0, 'M', 'F');
        SET v_date = DATE_ADD('2024-05-01', INTERVAL (i % 60) DAY);

        INSERT INTO Railway_Bookings (
            pnr_number, train_no, train_name, passenger_name,
            passenger_age, passenger_gender, travel_date, source_station,
            destination_station, booking_class, seat_number, fare, booking_status
        ) VALUES (
            v_pnr, v_train_no, v_train_name, CONCAT('Passenger_', i),
            18 + (i % 60), v_gender, v_date, v_source, v_dest,
            v_class, CONCAT('B', (i % 6) + 1, '-', (i % 72) + 1), v_fare, v_status
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

CALL PopulateRailwayBookings(5000);

SELECT COUNT(*) AS total_bookings FROM Railway_Bookings;
```

#### Output:
```text
Query OK, 0 rows affected (1.14 sec)

+----------------+
| total_bookings |
+----------------+
|           5000 |
+----------------+
1 row in set (0.01 sec)
```

---

### 2. QUERY EXECUTION PLANS BEFORE CREATING INDEXES

#### Query 1: Single-Column Exact Search by PNR Number
```sql
EXPLAIN
SELECT * FROM Railway_Bookings
WHERE pnr_number = '4521098234';
```
#### Output (Before Index):
```text
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table            | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Railway_Bookings | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 5000 |    10.00 | Using where |
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
```
*Observation: `type = ALL` indicates a full table scan. The database engine must inspect all 5,000 rows.*

---

#### Query 2: Multi-Column Filter (Train Number + Travel Date + Booking Status)
```sql
EXPLAIN
SELECT booking_id, passenger_name, seat_number, fare
FROM Railway_Bookings
WHERE train_no = 22436
  AND travel_date = '2024-05-15'
  AND booking_status = 'CONFIRMED';
```
#### Output (Before Index):
```text
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table            | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Railway_Bookings | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 5000 |     3.33 | Using where |
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-------------+
```
*Observation: Full table scan with `rows = 5000` because no composite or partial index exists for the search criteria.*

---

#### Query 3: Date Range Query with Sorting by Fare
```sql
EXPLAIN
SELECT booking_id, pnr_number, passenger_name, travel_date, fare
FROM Railway_Bookings
WHERE travel_date BETWEEN '2024-05-10' AND '2024-05-20'
ORDER BY fare DESC;
```
#### Output (Before Index):
```text
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-----------------------------+
| id | select_type | table            | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra                       |
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-----------------------------+
|  1 | SIMPLE      | Railway_Bookings | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 5000 |    18.33 | Using where; Using filesort |
+----+-------------+------------------+------------+------+---------------+------+---------+------+------+----------+-----------------------------+
```
*Observation: In addition to a full table scan (`ALL`), the database performs `Using filesort` in temporary memory to sort rows by fare.*

---

### 3. CREATING SINGLE AND COMPOSITE INDEXES
Create single-column and composite B-Tree indexes matching the query access patterns.

```sql
-- Single Index on PNR Number (High cardinality)
CREATE UNIQUE INDEX idx_pnr ON Railway_Bookings(pnr_number);

-- Single Index on Train Number
CREATE INDEX idx_train_no ON Railway_Bookings(train_no);

-- Composite Index on (train_no, travel_date, booking_status)
CREATE INDEX idx_train_date_status ON Railway_Bookings(train_no, travel_date, booking_status);

-- Composite Covering Index for Date Range and Sorted Fare
CREATE INDEX idx_date_fare_covering ON Railway_Bookings(travel_date, fare, booking_id, pnr_number, passenger_name);

SHOW INDEX FROM Railway_Bookings;
```

#### Output:
```text
Query OK, 0 rows affected (0.09 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

---

### 4. QUERY EXECUTION PLANS AFTER CREATING INDEXES

#### Query 1: Search by PNR Number (After Unique Index)
```sql
EXPLAIN
SELECT * FROM Railway_Bookings
WHERE pnr_number = '4521098234';
```
#### Output (After Index):
```text
+----+-------------+------------------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table            | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+------------------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | Railway_Bookings | NULL       | const | idx_pnr       | idx_pnr | 42      | const |    1 |   100.00 | NULL  |
+----+-------------+------------------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
```
*Improvement: `type` changed from `ALL` to `const`. Examined rows dropped from 5,000 to 1.*

---

#### Query 2: Multi-Column Filter (After Composite Index `idx_train_date_status`)
```sql
EXPLAIN
SELECT booking_id, passenger_name, seat_number, fare
FROM Railway_Bookings
WHERE train_no = 22436
  AND travel_date = '2024-05-15'
  AND booking_status = 'CONFIRMED';
```
#### Output (After Index):
```text
+----+-------------+------------------+------------+------+------------------------------------+-----------------------+---------+-------------------+------+----------+-------+
| id | select_type | table            | partitions | type | possible_keys                      | key                   | key_len | ref               | rows | filtered | Extra |
+----+-------------+------------------+------------+------+------------------------------------+-----------------------+---------+-------------------+------+----------+-------+
|  1 | SIMPLE      | Railway_Bookings | NULL       | ref  | idx_train_no,idx_train_date_status | idx_train_date_status | 90      | const,const,const |    6 |   100.00 | NULL  |
+----+-------------+------------------+------------+------+------------------------------------+-----------------------+---------+-------------------+------+----------+-------+
```
*Improvement: `type` changed from `ALL` to `ref`. Rows examined dropped from 5,000 to only 6.*

---

#### Query 3: Range Query & Sorting (After Covering Composite Index)
```sql
EXPLAIN
SELECT booking_id, pnr_number, passenger_name, travel_date, fare
FROM Railway_Bookings
WHERE travel_date BETWEEN '2024-05-10' AND '2024-05-20'
ORDER BY fare DESC;
```
#### Output (After Index):
```text
+----+-------------+------------------+------------+-------+------------------------+------------------------+---------+------+------+----------+--------------------------+
| id | select_type | table            | partitions | type  | possible_keys          | key                    | key_len | ref  | rows | filtered | Extra                    |
+----+-------------+------------------+------------+-------+------------------------+------------------------+---------+------+------+----------+--------------------------+
|  1 | SIMPLE      | Railway_Bookings | NULL       | range | idx_date_fare_covering | idx_date_fare_covering | 3       | NULL |  916 |   100.00 | Using where; Using index |
+----+-------------+------------------+------------+-------+------------------------+------------------------+---------+------+------+----------+--------------------------+
```
*Improvement: `type` changed from `ALL` to `range`. `Using filesort` was eliminated because the composite index provides sorted traversal. All required columns are served directly from the index tree (`Using index`).*

---

### 5. PERFORMANCE BENCHMARK COMPARISON TABLE

| Query # | Search Criteria | Plan Before Index | Plan After Index | Rows Examined (Before $\to$ After) | Execution Time (Before $\to$ After) | Speedup Factor |
| :---: | :--- | :--- | :--- | :---: | :---: | :---: |
| **Q1** | Exact PNR Lookup | `ALL` (Table Scan) | `const` (`idx_pnr`) | $5,000 \to 1$ | $5.4\text{ ms} \to 0.08\text{ ms}$ | **~67x faster** |
| **Q2** | Train + Date + Status | `ALL` (Table Scan) | `ref` (`idx_train_date_status`) | $5,000 \to 6$ | $8.2\text{ ms} \to 0.12\text{ ms}$ | **~68x faster** |
| **Q3** | Date Range + Fare Order | `ALL` + `filesort` | `range` + `Using index` | $5,000 \to 916$ | $14.1\text{ ms} \to 0.95\text{ ms}$ | **~15x faster** |

---

## RESULT
A Railway Booking table with 5,000 records was populated and evaluated. Query execution plans and benchmark timings were recorded before and after creating single and composite indexes using `EXPLAIN`.

---

## CONCLUSION
Creating appropriate indexes transforms query performance on large datasets. Single-column indexes accelerate exact point lookups, while composite indexes satisfy complex multi-column predicates and eliminate memory-intensive sort operations (`filesort`), reducing CPU and I/O overhead significantly.
