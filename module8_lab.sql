-- Create a new database named PixelPizzaPalace.
-- A database is the container that will hold all tables and objects.
CREATE DATABASE PixelPizzaPalace;
GO

-- Switch to the PixelPizzaPalace database.
USE PixelPizzaPalace;
GO

-- Create the Products table.
-- ProductID is an auto-incrementing primary key.
CREATE TABLE Products (
    ProductID   INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(50),
    Price       DECIMAL(5,2),  -- 5 digits total, 2 after decimal
    Stock       INT
);

-- Create the Sales table.
-- ProductID is a foreign key that must match a ProductID in Products.
-- SaleDate defaults to the current date/time.
CREATE TABLE Sales (
    SaleID    INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity  INT,
    SaleDate  DATETIME DEFAULT GETDATE()
);

-- Insert sample data into Products.
INSERT INTO Products (ProductName, Price, Stock)
VALUES 
    ('Pepperoni Pizza', 12.99, 50),
    ('Cheese Pizza',    10.99, 50),
    ('Garlic Bread',     4.99, 75),
    ('Soda',             2.50, 200);

-- Insert sample data into Sales.
INSERT INTO Sales (ProductID, Quantity)
VALUES (1, 3), (2, 2), (3, 5);
GO


-- Create server-level logins.
CREATE LOGIN Cashier WITH PASSWORD = 'Cash123!';
CREATE LOGIN Manager WITH PASSWORD = 'Mangr123!';
GO

USE PixelPizzaPalace;
GO

-- Create database users linked to the logins.
CREATE USER Cashier FOR LOGIN Cashier;
CREATE USER Manager FOR LOGIN Manager;
GO

-- Grant limited permissions to Cashier.
GRANT SELECT ON Products TO Cashier;
GRANT SELECT, INSERT ON Sales TO Cashier;
GO

-- Grant full permissions to Manager.
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO Manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO Manager;
GO

-- Verify permissions using system catalog views.
SELECT 
    dp.name            AS UserName,
    o.name             AS TableName,
    p.permission_name  AS Permission
FROM sys.database_permissions p
JOIN sys.database_principals dp 
    ON p.grantee_principal_id = dp.principal_id
JOIN sys.objects o 
    ON p.major_id = o.object_id
WHERE dp.name IN ('Cashier', 'Manager')
ORDER BY UserName, TableName;
GO

-- Check database file sizes.
-- size is stored in 8 KB pages; divide by 128 to convert to MB.
SELECT 
    name        AS FileName,
    size / 128.0 AS SizeMB
FROM sys.database_files;
GO

-- Create a full database backup.
BACKUP DATABASE PixelPizzaPalace
TO DISK = '/var/opt/mssql/data/PixelPizzaPalace.bak'
WITH FORMAT;
GO

-- Create a nonclustered index on ProductName for faster searches.
CREATE NONCLUSTERED INDEX IX_Products_Name 
ON Products(ProductName);
GO

-- Verify the index was created.
SELECT 
    i.name      AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id 
    AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('Products')
ORDER BY i.name;
GO

-- ===== PART 2 STEP 2: ADD INVENTORY USER =====

-- Create a new server-level login for the inventory manager
CREATE LOGIN InventoryMgr WITH PASSWORD = 'Inv12345!';
GO

-- Switch to the PixelPizzaPalace database
USE PixelPizzaPalace;
GO

-- Create a database user linked to the InventoryMgr login
CREATE USER InventoryMgr FOR LOGIN InventoryMgr;
GO

-- Grant InventoryMgr permission to view and update Products only
GRANT SELECT, UPDATE ON Products TO InventoryMgr;
GO

-- Verify permissions (same query from Part 1 Step 4)
SELECT 
    dp.name            AS UserName,
    o.name             AS TableName,
    p.permission_name  AS Permission
FROM sys.database_permissions p
JOIN sys.database_principals dp 
    ON p.grantee_principal_id = dp.principal_id
JOIN sys.objects o 
    ON p.major_id = o.object_id
WHERE dp.name IN ('Cashier', 'Manager', 'InventoryMgr')
ORDER BY UserName, TableName;
GO


-- ===== PART 2 STEP 3: TABLE SIZES =====

USE PixelPizzaPalace;
GO

SELECT 
    t.name              AS TableName,
    p.rows              AS NumberOfRows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB
FROM sys.tables t
JOIN sys.indexes i 
    ON t.object_id = i.object_id
JOIN sys.partitions p 
    ON i.object_id = p.object_id 
    AND i.index_id = p.index_id
JOIN sys.allocation_units a 
    ON p.partition_id = a.container_id
GROUP BY t.name, p.rows
ORDER BY TotalSpaceKB DESC;
GO


-- ===== PART 2 STEP 4: BACKUP AND RESTORE =====

-- 4a: Add a new product
INSERT INTO Products (ProductName, Price, Stock)
VALUES ('Ice Cream Sundae', 5.99, 60);
GO


-- 4b: Back up the database with the new product included
BACKUP DATABASE PixelPizzaPalace
TO DISK = '/var/opt/mssql/data/PixelPizzaPalace_New.bak'
WITH FORMAT;
GO


-- 4c: Delete the product and verify it is gone
DELETE FROM Products WHERE ProductName = 'Ice Cream Sundae';
GO

SELECT * FROM Products;
GO


-- 4d: Restore the database and verify the product returned

USE master;
GO

-- Set database to single user mode so restore can run
ALTER DATABASE PixelPizzaPalace SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE PixelPizzaPalace
FROM DISK = '/var/opt/mssql/data/PixelPizzaPalace_New.bak'
WITH REPLACE;
GO

-- Return database to normal multi-user mode
ALTER DATABASE PixelPizzaPalace SET MULTI_USER;
GO

USE PixelPizzaPalace;
GO

SELECT * FROM Products;
GO

-- ===== PART 2 STEP 5: REFLECTION =====

-- Reflection
-- Question 1: The three most important database administration tasks were managing user permissions, monitoring database and table sizes, and performing backups and restores.
-- Question 2: Pixel Pizza Palace needs permission control to protect sensitive data and ensure employees can only access what they need to do their job.
-- Question 3: Without regular backups, the business could permanently lose important data due to crashes, accidental deletions, or cyberattacks.