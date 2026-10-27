-- ==========================================================
-- EXPERIMENT 8: Banking Transactions, Partial Failures,
--               and Concurrency Anomalies (Two Sessions)
-- ==========================================================

DROP DATABASE IF EXISTS BankingDB;
CREATE DATABASE BankingDB;
USE BankingDB;

-- ==========================================================
-- 1. SCHEMA CREATION & INITIAL SEED DATA
-- ==========================================================

DROP TABLE IF EXISTS Transaction_Log;
DROP TABLE IF EXISTS Accounts;

CREATE TABLE Accounts (
    account_no INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(20) DEFAULT 'Savings',
    balance DECIMAL(12,2) NOT NULL CHECK (balance >= 0),
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE Transaction_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    txn_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    account_no INT,
    txn_type VARCHAR(20),
    amount DECIMAL(12,2),
    balance_after DECIMAL(12,2),
    remarks VARCHAR(255),
    FOREIGN KEY (account_no) REFERENCES Accounts(account_no)
);

-- Insert sample accounts
INSERT INTO Accounts (account_no, customer_name, account_type, balance, status) VALUES
(1001, 'Aarav Patel', 'Savings', 50000.00, 'Active'),
(1002, 'Sneha Rao', 'Savings', 30000.00, 'Active'),
(1003, 'Vikram Sharma', 'Current', 75000.00, 'Active'),
(1004, 'Ananya Roy', 'Savings', 12000.00, 'Inactive');

SELECT * FROM Accounts;

-- ==========================================================
-- 2. BASIC TRANSACTION: ATOMIC TRANSFER WITH COMMIT
-- Transfer 10,000 from Aarav (1001) to Sneha (1002)
-- ==========================================================

START TRANSACTION;

-- Step 1: Debit Account 1001
UPDATE Accounts
SET balance = balance - 10000.00
WHERE account_no = 1001;

-- Step 2: Credit Account 1002
UPDATE Accounts
SET balance = balance + 10000.00
WHERE account_no = 1002;

-- Step 3: Record transaction in audit log
INSERT INTO Transaction_Log (account_no, txn_type, amount, balance_after, remarks)
VALUES
(1001, 'DEBIT', 10000.00, (SELECT balance FROM Accounts WHERE account_no = 1001), 'Transfer to Acc 1002'),
(1002, 'CREDIT', 10000.00, (SELECT balance FROM Accounts WHERE account_no = 1002), 'Transfer from Acc 1001');

COMMIT;

-- Verify updated balances
SELECT * FROM Accounts WHERE account_no IN (1001, 1002);
SELECT * FROM Transaction_Log;

-- ==========================================================
-- 3. SIMULATE COMPLETE TRANSACTION FAILURE WITH ROLLBACK
-- Attempt to transfer 1,00,000 from Sneha (1002) which exceeds balance
-- ==========================================================

START TRANSACTION;

-- Debit attempt
UPDATE Accounts
SET balance = balance - 100000.00
WHERE account_no = 1002;

-- Check balance validity in application logic / constraint check
-- In case of violation or insufficient funds:
ROLLBACK;

-- Verify balance remains intact
SELECT * FROM Accounts WHERE account_no = 1002;

-- ==========================================================
-- 4. PARTIAL FAILURE SIMULATION USING SAVEPOINT
-- Transfer 5,000 from 1001 to 1002, then attempt optional bill debit
-- to an Inactive account (1004). Rollback only the secondary step.
-- ==========================================================

START TRANSACTION;

-- Primary Action: Transfer 5,000 from 1001 to 1002
UPDATE Accounts
SET balance = balance - 5000.00
WHERE account_no = 1001;

UPDATE Accounts
SET balance = balance + 5000.00
WHERE account_no = 1002;

INSERT INTO Transaction_Log (account_no, txn_type, amount, balance_after, remarks)
VALUES
(1001, 'DEBIT', 5000.00, (SELECT balance FROM Accounts WHERE account_no = 1001), 'Peer Transfer to 1002'),
(1002, 'CREDIT', 5000.00, (SELECT balance FROM Accounts WHERE account_no = 1002), 'Peer Transfer from 1001');

-- Establish Savepoint before secondary action
SAVEPOINT transfer_complete;

-- Secondary Action: Utility service fee deduction to Inactive Account (1004)
UPDATE Accounts
SET balance = balance - 1500.00
WHERE account_no = 1001;

UPDATE Accounts
SET balance = balance + 1500.00
WHERE account_no = 1004;

-- Detect status error: Account 1004 is 'Inactive', fee transfer is invalid
-- Roll back only to the savepoint
ROLLBACK TO SAVEPOINT transfer_complete;

-- Commit the primary transfer successfully
COMMIT;

-- Verify final state: Transfer succeeded, secondary fee was reverted
SELECT * FROM Accounts WHERE account_no IN (1001, 1002, 1004);
SELECT * FROM Transaction_Log;

-- ==========================================================
-- 5. DEMONSTRATION OF CONCURRENCY ANOMALIES (TWO SESSIONS)
-- ==========================================================

-- ----------------------------------------------------------
-- SCENARIO A: DIRTY READ (READ UNCOMMITTED)
-- ----------------------------------------------------------
-- [Session 1]:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- START TRANSACTION;
-- UPDATE Accounts SET balance = balance + 20000 WHERE account_no = 1001;
-- -- (Do not commit yet)

-- [Session 2]:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM Accounts WHERE account_no = 1001; -- Reads dirty uncommitted value!

-- [Session 1]:
-- ROLLBACK; -- Session 1 cancels changes

-- [Session 2]:
-- SELECT balance FROM Accounts WHERE account_no = 1001; -- Value reverted; dirty read occurred!
-- COMMIT;

-- ----------------------------------------------------------
-- SCENARIO B: NON-REPEATABLE READ (READ COMMITTED vs REPEATABLE READ)
-- ----------------------------------------------------------
-- [Session 1 - READ COMMITTED]:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM Accounts WHERE account_no = 1003; -- Reads 75000

-- [Session 2]:
-- START TRANSACTION;
-- UPDATE Accounts SET balance = balance + 5000 WHERE account_no = 1003;
-- COMMIT;

-- [Session 1]:
-- SELECT balance FROM Accounts WHERE account_no = 1003; -- Reads 80000 (Non-repeatable read observed)
-- COMMIT;

-- [Repeat with REPEATABLE READ]:
-- Under REPEATABLE READ, Session 1 will see the exact same snapshot (75000)
-- even after Session 2 commits, until Session 1 completes its transaction.

-- ----------------------------------------------------------
-- SCENARIO C: PHANTOM READ & SERIALIZABLE ISOLATION
-- ----------------------------------------------------------
-- [Session 1]:
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- SELECT COUNT(*) FROM Accounts WHERE balance > 30000;

-- [Session 2]:
-- START TRANSACTION;
-- INSERT INTO Accounts VALUES (1005, 'Kavita Sen', 'Savings', 45000.00, 'Active');
-- COMMIT;

-- [Session 1 under SERIALIZABLE]:
-- Under SERIALIZABLE, Session 2's INSERT is blocked until Session 1 completes,
-- preventing phantom rows completely.

-- ----------------------------------------------------------
-- SCENARIO D: ROW-LEVEL LOCKING & PREVENTING LOST UPDATES
-- ----------------------------------------------------------
-- Using pessimistic locking with SELECT ... FOR UPDATE:
START TRANSACTION;
SELECT balance FROM Accounts WHERE account_no = 1001 FOR UPDATE;
UPDATE Accounts SET balance = balance - 2000.00 WHERE account_no = 1001;
COMMIT;
