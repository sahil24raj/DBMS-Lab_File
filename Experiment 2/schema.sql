-- Create Database
CREATE DATABASE EcommerceDB;
USE EcommerceDB;

-- Create Customer Table
CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15)
);

-- Create Category Table
CREATE TABLE Category (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(100) NOT NULL UNIQUE
);

-- Create Seller Table
CREATE TABLE Seller (
    Seller_ID INT PRIMARY KEY,
    Seller_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE
);

-- Create Product Table
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

-- Sample Data Insertion
INSERT INTO Customer
VALUES (1, 'Sahil Raj', 'sahil@gmail.com', '9876543210');

INSERT INTO Category
VALUES (1, 'Electronics');

INSERT INTO Seller
VALUES (1, 'Tech Store', 'tech@gmail.com');

INSERT INTO Product
VALUES (101, 'Laptop', 65000, 10, 1, 1);

-- Referential Integrity Test
-- Expected Output: Foreign Key constraint error because Category_ID = 99 does not exist.
-- INSERT INTO Product VALUES (102, 'Mobile', 25000, 20, 99, 1);
