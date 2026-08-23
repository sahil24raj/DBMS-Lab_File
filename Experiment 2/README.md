# Experiment 2: Convert ER Diagram into Relational Schema

## Aim
To convert the designed ER diagram into a relational schema and implement it using MySQL.

## SQL Commands

```sql
CREATE DATABASE EcommerceDB;
USE EcommerceDB;

CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15)
);

CREATE TABLE Category (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Seller (
    Seller_ID INT PRIMARY KEY,
    Seller_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE
);

CREATE TABLE Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT,
    Category_ID INT,
    Seller_ID INT,
    FOREIGN KEY (Category_ID)
        REFERENCES Category(Category_ID)
        ON DELETE SET NULL,
    FOREIGN KEY (Seller_ID)
        REFERENCES Seller(Seller_ID)
        ON DELETE SET NULL
);
```

## Sample Data

```sql
INSERT INTO Customer
VALUES (1, 'Sahil Raj', 'sahil@gmail.com', '9876543210');

INSERT INTO Category
VALUES (1, 'Electronics');

INSERT INTO Seller
VALUES (1, 'Tech Store', 'tech@gmail.com');

INSERT INTO Product
VALUES (101, 'Laptop', 65000, 10, 1, 1);
```

## Referential Integrity Test

```sql
INSERT INTO Product
VALUES (102, 'Mobile', 25000, 20, 99, 1);
```
* **Expected Output**: Foreign Key constraint error because `Category_ID = 99` does not exist.

## Important Constraints Used

* **PRIMARY KEY** &rarr; uniquely identifies each record.
* **FOREIGN KEY** &rarr; maintains relationship between tables.
* **NOT NULL** &rarr; prevents empty values.
* **UNIQUE** &rarr; prevents duplicate values.
* **ON DELETE CASCADE** &rarr; automatically deletes related records.
* **ON DELETE SET NULL** &rarr; sets the foreign-key value to NULL when the parent record is deleted.

## Result
The ER diagram was successfully converted into relational tables and implemented in MySQL with required constraints and referential integrity.
