# EXPERIMENT - 8

## AIM
Implement banking-style transactions using `BEGIN`, `COMMIT`, `ROLLBACK`, and `SAVEPOINT`. Simulate partial failures. Demonstrate isolation levels and concurrency anomalies using two sessions.

---

## OBJECTIVES
- To understand ACID properties (Atomicity, Consistency, Isolation, Durability) in relational database transactions.
- To execute atomic fund transfer transactions using `START TRANSACTION`, `COMMIT`, and `ROLLBACK`.
- To simulate and manage partial transaction failures using `SAVEPOINT` and `ROLLBACK TO SAVEPOINT`.
- To investigate standard SQL Transaction Isolation Levels (`READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`).
- To demonstrate concurrency anomalies (**Dirty Read**, **Non-Repeatable Read**, **Phantom Read**, and **Lost Update**) using two synchronized database client sessions.

---

## DATABASE USED
The experiment uses a banking schema housed in the `BankingDB` database.

```sql
CREATE DATABASE BankingDB;
USE BankingDB;
```

---

## SCHEMA REFERENCE

| Table | Primary Columns | Purpose |
| :--- | :--- | :--- |
| **Accounts** | `account_no`, `customer_name`, `account_type`, `balance`, `status` | Stores customer account balances and active status. |
| **Transaction_Log** | `log_id`, `txn_time`, `account_no`, `txn_type`, `amount`, `balance_after`, `remarks` | Audit ledger maintaining transaction records. |

---

## SOURCE CODE / SQL QUERIES

### 1. TABLE CREATION AND INITIAL DATA SETUP
Create the core tables with balance constraints and populate baseline customer records.

```sql
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

INSERT INTO Accounts (account_no, customer_name, account_type, balance, status) VALUES
(1001, 'Aarav Patel', 'Savings', 50000.00, 'Active'),
(1002, 'Sneha Rao', 'Savings', 30000.00, 'Active'),
(1003, 'Vikram Sharma', 'Current', 75000.00, 'Active'),
(1004, 'Ananya Roy', 'Savings', 12000.00, 'Inactive');

SELECT * FROM Accounts;
```

#### Output:
```text
+------------+---------------+--------------+----------+----------+
| account_no | customer_name | account_type | balance  | status   |
+------------+---------------+--------------+----------+----------+
|       1001 | Aarav Patel   | Savings      | 50000.00 | Active   |
|       1002 | Sneha Rao     | Savings      | 30000.00 | Active   |
|       1003 | Vikram Sharma | Current      | 75000.00 | Active   |
|       1004 | Ananya Roy    | Savings      | 12000.00 | Inactive |
+------------+---------------+--------------+----------+----------+
4 rows in set (0.00 sec)
```

---

### 2. ATOMIC TRANSACTION WITH COMMIT
Transfer ₹10,000 from Account 1001 (Aarav) to Account 1002 (Sneha) atomically. Both debits, credits, and audit logging must succeed together.

```sql
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
```

#### Output:
```text
+------------+---------------+--------------+----------+--------+
| account_no | customer_name | account_type | balance  | status |
+------------+---------------+--------------+----------+--------+
|       1001 | Aarav Patel   | Savings      | 40000.00 | Active |
|       1002 | Sneha Rao     | Savings      | 40000.00 | Active |
+------------+---------------+--------------+----------+--------+
2 rows in set (0.00 sec)

+--------+---------------------+------------+----------+----------+---------------+-----------------------+
| log_id | txn_time            | account_no | txn_type | amount   | balance_after | remarks               |
+--------+---------------------+------------+----------+----------+---------------+-----------------------+
|      1 | 2026-10-27 12:15:00 |       1001 | DEBIT    | 10000.00 |      40000.00 | Transfer to Acc 1002  |
|      2 | 2026-10-27 12:15:00 |       1002 | CREDIT   | 10000.00 |      40000.00 | Transfer from Acc 1001|
+--------+---------------------+------------+----------+----------+---------------+-----------------------+
2 rows in set (0.00 sec)
```

---

### 3. SIMULATE COMPLETE TRANSACTION FAILURE (ROLLBACK)
Simulate a scenario where Account 1002 attempts to transfer ₹1,00,000 (exceeding balance). Upon failure detection, the entire transaction is rolled back.

```sql
START TRANSACTION;

-- Debit attempt that violates business logic / insufficient funds
UPDATE Accounts
SET balance = balance - 100000.00
WHERE account_no = 1002;

-- Application checks balance condition (< 0 violates CHECK constraint or business rules)
-- Rolling back changes:
ROLLBACK;

-- Verify balance remains unmodified
SELECT * FROM Accounts WHERE account_no = 1002;
```

#### Output:
```text
+------------+---------------+--------------+----------+--------+
| account_no | customer_name | account_type | balance  | status |
+------------+---------------+--------------+----------+--------+
|       1002 | Sneha Rao     | Savings      | 40000.00 | Active |
+------------+---------------+--------------+----------+--------+
1 row in set (0.00 sec)
```
*The balance was preserved at ₹40,000 with zero side-effects.*

---

### 4. SIMULATE PARTIAL FAILURE USING SAVEPOINT
In banking workflows, a primary transaction (e.g. peer-to-peer transfer) may succeed, but an optional secondary step (e.g., fee payment or utility subscription) may fail. Using a `SAVEPOINT`, the failure of the optional step can be rolled back without discarding the primary transfer.

```sql
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

-- Set Savepoint after primary transfer completes
SAVEPOINT transfer_complete;

-- Secondary Action: Attempt utility service payment to Inactive Account (1004)
UPDATE Accounts
SET balance = balance - 1500.00
WHERE account_no = 1001;

UPDATE Accounts
SET balance = balance + 1500.00
WHERE account_no = 1004;

-- Error Condition Detected: Beneficiary Account 1004 is 'Inactive'
-- Roll back only to the savepoint
ROLLBACK TO SAVEPOINT transfer_complete;

-- Commit the primary transfer
COMMIT;

-- Verify final state
SELECT * FROM Accounts WHERE account_no IN (1001, 1002, 1004);
```

#### Output:
```text
+------------+---------------+--------------+----------+----------+
| account_no | customer_name | account_type | balance  | status   |
+------------+---------------+--------------+----------+----------+
|       1001 | Aarav Patel   | Savings      | 35000.00 | Active   |
|       1002 | Sneha Rao     | Savings      | 45000.00 | Active   |
|       1004 | Ananya Roy    | Savings      | 12000.00 | Inactive |
+------------+---------------+--------------+----------+----------+
3 rows in set (0.00 sec)
```
*The peer-to-peer transfer was retained (Aarav ₹35,000, Sneha ₹45,000), while the failed secondary fee debit was isolated and reverted.*

---

### 5. DEMONSTRATION OF CONCURRENCY ANOMALIES (TWO SESSIONS)

#### Overview of SQL Isolation Levels:

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read |
| :--- | :---: | :---: | :---: |
| **READ UNCOMMITTED** | Permitted | Permitted | Permitted |
| **READ COMMITTED** | Prevented | Permitted | Permitted |
| **REPEATABLE READ** (MySQL Default) | Prevented | Prevented | Prevented (via MVCC/Gap Locks) |
| **SERIALIZABLE** | Prevented | Prevented | Prevented |

---

#### SCENARIO A: DIRTY READ (`READ UNCOMMITTED`)
A dirty read occurs when Session 2 reads uncommitted modifications made by Session 1 that are later aborted.

| Step | Session 1 | Session 2 | Observation / Output |
| :--- | :--- | :--- | :--- |
| **T1** | `SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;`<br>`START TRANSACTION;` | `SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;`<br>`START TRANSACTION;` | Both sessions start in READ UNCOMMITTED mode. |
| **T2** | `UPDATE Accounts SET balance = balance + 20000 WHERE account_no = 1001;` | *(Idle)* | Balance uncommitted = ₹55,000. |
| **T3** | *(Idle)* | `SELECT balance FROM Accounts WHERE account_no = 1001;` | **Dirty Read**: Session 2 sees ₹55,000 even though Session 1 has not committed! |
| **T4** | `ROLLBACK;` | *(Idle)* | Session 1 aborts. Actual balance returns to ₹35,000. |
| **T5** | *(Session 1 finished)* | `SELECT balance FROM Accounts WHERE account_no = 1001;`<br>`COMMIT;` | Session 2 sees balance is back to ₹35,000. The ₹55,000 read at T3 was invalid. |

---

#### SCENARIO B: NON-REPEATABLE READ (`READ COMMITTED` vs `REPEATABLE READ`)
A non-repeatable read occurs when a transaction reads the same row twice and obtains different values because another committed transaction modified it in between.

| Step | Session 1 (`READ COMMITTED`) | Session 2 | Observation / Output |
| :--- | :--- | :--- | :--- |
| **T1** | `SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;`<br>`START TRANSACTION;` | `START TRANSACTION;` | Session 1 configured with READ COMMITTED. |
| **T2** | `SELECT balance FROM Accounts WHERE account_no = 1003;` | *(Idle)* | Query 1 returns **₹75,000**. |
| **T3** | *(Idle)* | `UPDATE Accounts SET balance = balance + 5000 WHERE account_no = 1003;`<br>`COMMIT;` | Session 2 commits new balance = **₹80,000**. |
| **T4** | `SELECT balance FROM Accounts WHERE account_no = 1003;`<br>`COMMIT;` | *(Idle)* | Query 2 returns **₹80,000** within the same transaction! *(Non-repeatable read observed)*. |

> **Contrast with `REPEATABLE READ`:** Under MySQL's default `REPEATABLE READ`, MVCC ensures that Session 1 continues reading the snapshot taken at statement start (₹75,000) regardless of Session 2's commit.

---

#### SCENARIO C: PHANTOM READ & `SERIALIZABLE` ISOLATION
A phantom read occurs when a transaction re-executes a range query and discovers new "phantom" rows inserted by another committed transaction.

| Step | Session 1 (`SERIALIZABLE`) | Session 2 | Observation / Output |
| :--- | :--- | :--- | :--- |
| **T1** | `SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;`<br>`START TRANSACTION;` | `START TRANSACTION;` | Session 1 enters SERIALIZABLE mode. |
| **T2** | `SELECT COUNT(*) FROM Accounts WHERE balance > 30000;` | *(Idle)* | Reads count = 3. Shared range lock acquired. |
| **T3** | *(Idle)* | `INSERT INTO Accounts VALUES (1005, 'Kavita Sen', 'Savings', 45000.00, 'Active');` | **Blocked**: Session 2 waits for Session 1's lock release. |
| **T4** | `SELECT COUNT(*) FROM Accounts WHERE balance > 30000;`<br>`COMMIT;` | *(Waiting)* | Session 1 sees identical count (3). Lock released upon `COMMIT`. |
| **T5** | *(Finished)* | *(INSERT proceeds and succeeds)*<br>`COMMIT;` | Phantom reads are strictly eliminated. |

---

#### SCENARIO D: PREVENTING LOST UPDATES USING PESSIMISTIC LOCKING (`FOR UPDATE`)
When two concurrent sessions attempt to read and deduct funds from the same account simultaneously, standard updates can overwrite each other without proper locking.

```sql
START TRANSACTION;
-- Acquire exclusive row-level lock
SELECT balance FROM Accounts WHERE account_no = 1001 FOR UPDATE;

-- Execute safe debit
UPDATE Accounts SET balance = balance - 2000.00 WHERE account_no = 1001;

COMMIT;
```

---

## RESULT
Banking transactions were implemented using `START TRANSACTION`, `COMMIT`, `ROLLBACK`, and `SAVEPOINT`. Partial failures were managed without compromising entire transactions. All four transaction isolation levels and concurrency anomalies were demonstrated across two synchronized sessions.

---

## CONCLUSION
Database transactions guarantee the integrity of critical multi-step operations via ACID principles. `SAVEPOINT` provides granular error containment for complex workflows. Choosing the appropriate isolation level enables database administrators to strike the right balance between concurrency performance and data consistency.
