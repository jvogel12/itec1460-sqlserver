-- Query 1: Get all products
SELECT * FROM Products;

-- Query 2: Get specific customer columns
SELECT CompanyName, ContactName, City
FROM Customers;

-- Query 3: Get customers from USA
SELECT CompanyName, ContactName, City
FROM Customers
WHERE Country = 'USA';