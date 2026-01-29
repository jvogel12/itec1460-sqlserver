--Query A
SELECT CompanyName, City
FROM Customers
WHERE Country = 'Germany';

--Query B
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice < 20;

--Query C
SELECT CompanyName, ContactName, Phone
FROM Customers
WHERE City = 'London';
