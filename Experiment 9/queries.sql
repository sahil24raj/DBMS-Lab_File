-- ==========================================================
-- EXPERIMENT 9: Railway Booking Indexing & Benchmarking
--               (Dataset with 5,000+ Records)
-- ==========================================================

DROP DATABASE IF EXISTS RailwayDB;
CREATE DATABASE RailwayDB;
USE RailwayDB;

-- ==========================================================
-- 1. TABLE CREATION: RAILWAY BOOKINGS
-- ==========================================================

DROP TABLE IF EXISTS Railway_Bookings;
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

-- ==========================================================
-- 2. POPULATE AT LEAST 5,000 REALISTIC RECORDS
-- Automated generation procedure using bulk insertion
-- ==========================================================

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

    -- Disable autocommit for fast bulk insert
    SET autocommit = 0;

    WHILE i <= total_rows DO
        -- Generate pseudo-random realistic attributes
        SET v_pnr = LPAD(FLOOR(1000000000 + (RAND() * 9000000000)), 10, '0');
        
        -- Pick from 5 major train routes
        CASE (i % 5)
            WHEN 0 THEN
                SET v_train_no = 12951, v_train_name = 'Mumbai Tejas Rajdhani', v_source = 'BCT', v_dest = 'NDLS';
            WHEN 1 THEN
                SET v_train_no = 12004, v_train_name = 'Lucknow Shatabdi Express', v_source = 'NDLS', v_dest = 'LKO';
            WHEN 2 THEN
                SET v_train_no = 22436, v_train_name = 'Vande Bharat Express', v_source = 'NDLS', v_dest = 'BSB';
            WHEN 3 THEN
                SET v_train_no = 12301, v_train_name = 'Howrah Rajdhani', v_source = 'HWH', v_dest = 'NDLS';
            ELSE
                SET v_train_no = 12621, v_train_name = 'Tamil Nadu Express', v_source = 'MAS', v_dest = 'NDLS';
        END CASE;

        -- Booking class
        CASE (i % 4)
            WHEN 0 THEN SET v_class = '1A', v_fare = 3500.00;
            WHEN 1 THEN SET v_class = '2A', v_fare = 2200.00;
            WHEN 2 THEN SET v_class = '3A', v_fare = 1500.00;
            ELSE SET v_class = 'SL', v_fare = 450.00;
        END CASE;

        -- Status
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
            v_pnr,
            v_train_no,
            v_train_name,
            CONCAT('Passenger_', i),
            18 + (i % 60),
            v_gender,
            v_date,
            v_source,
            v_dest,
            v_class,
            CONCAT('B', (i % 6) + 1, '-', (i % 72) + 1),
            v_fare,
            v_status
        );

        -- Periodic batch commit
        IF (i % 1000 = 0) THEN
            COMMIT;
        END IF;

        SET i = i + 1;
    END WHILE;

    COMMIT;
    SET autocommit = 1;
END //
DELIMITER ;

-- Execute procedure to generate 5,000 records
CALL PopulateRailwayBookings(5000);

-- Verify record count
SELECT COUNT(*) AS total_bookings FROM Railway_Bookings;

-- ==========================================================
-- 3. BENCHMARK QUERIES BEFORE CREATING INDEXES
-- ==========================================================

-- Query 1: Single-column exact search on PNR (High cardinality)
EXPLAIN
SELECT * FROM Railway_Bookings
WHERE pnr_number = '4521098234';

-- Query 2: Multi-column filter (Train + Date + Status)
EXPLAIN
SELECT booking_id, passenger_name, seat_number, fare
FROM Railway_Bookings
WHERE train_no = 22436
  AND travel_date = '2024-05-15'
  AND booking_status = 'CONFIRMED';

-- Query 3: Date range filter with sorting on Fare
EXPLAIN
SELECT booking_id, pnr_number, passenger_name, travel_date, fare
FROM Railway_Bookings
WHERE travel_date BETWEEN '2024-05-10' AND '2024-05-20'
ORDER BY fare DESC;

-- Query 4: Aggregate summary by source & destination station
EXPLAIN
SELECT source_station, destination_station, COUNT(*) AS total_tickets, SUM(fare) AS total_revenue
FROM Railway_Bookings
GROUP BY source_station, destination_station;

-- ==========================================================
-- 4. CREATING SINGLE AND COMPOSITE INDEXES
-- ==========================================================

-- Single Index 1: Unique index on PNR Number (eliminates table scan)
CREATE UNIQUE INDEX idx_pnr ON Railway_Bookings(pnr_number);

-- Single Index 2: Index on train_no
CREATE INDEX idx_train_no ON Railway_Bookings(train_no);

-- Composite Index 1: Filtering by train_no, travel_date, booking_status
CREATE INDEX idx_train_date_status ON Railway_Bookings(train_no, travel_date, booking_status);

-- Composite Index 2: Covering Index for range filter and sorting
CREATE INDEX idx_date_fare_covering ON Railway_Bookings(travel_date, fare, booking_id, pnr_number, passenger_name);

-- Check indexes created
SHOW INDEX FROM Railway_Bookings;

-- ==========================================================
-- 5. BENCHMARK QUERIES AFTER CREATING INDEXES
-- ==========================================================

-- Query 1 (After idx_pnr): Uses unique index lookup (const)
EXPLAIN
SELECT * FROM Railway_Bookings
WHERE pnr_number = '4521098234';

-- Query 2 (After idx_train_date_status): Uses composite index (ref)
EXPLAIN
SELECT booking_id, passenger_name, seat_number, fare
FROM Railway_Bookings
WHERE train_no = 22436
  AND travel_date = '2024-05-15'
  AND booking_status = 'CONFIRMED';

-- Query 3 (After idx_date_fare_covering): Uses covering index, eliminates filesort
EXPLAIN
SELECT booking_id, pnr_number, passenger_name, travel_date, fare
FROM Railway_Bookings
WHERE travel_date BETWEEN '2024-05-10' AND '2024-05-20'
ORDER BY fare DESC;
