--PART 1

--Insert these values into customers
INSERT INTO Customers (CustomerID, CompanyName, ContactName, Country)
VALUES ('STUDE', 'Student Company', 'Your Name', 'Your Country');
--Verify by showing said values
SELECT CustomerID, CompanyName FROM Customers WHERE CustomerID = 'STUDE';

--Create an order for the customer just added
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, ShipCountry)
VALUES ('STUDE', 1, GETDATE(), 'Your Country');
--Check that it was created
SELECT TOP 1 OrderID FROM Orders WHERE CustomerID = 'STUDE' ORDER BY OrderID DESC;

--Change the contact name for the customer
UPDATE Customers
SET ContactName = 'New Contact Name'
WHERE CustomerID = 'STUDE';
--Verify that the name was updated
SELECT ContactName FROM Customers WHERE CustomerID = 'STUDE';

--Change the shipping country for the order
UPDATE Orders
SET ShipCountry = 'New Country'
WHERE CustomerID = 'STUDE';
--Check that the country was updated
SELECT ShipCountry FROM Orders WHERE CustomerID = 'STUDE';

--Remove the order we created
DELETE FROM Orders WHERE CustomerID = 'STUDE';
--Verify that the order was deleted
SELECT OrderID, CustomerID FROM Orders WHERE CustomerID = 'STUDE';

--Remove test customer
DELETE FROM Customers WHERE CustomerID = 'STUDE';
--Verify that the customer was deleted
SELECT CustomerID, CompanyName FROM Customers WHERE CustomerID = 'STUDE';



--PART 2

--Insert a new supplier into the Suppliers table
INSERT INTO Suppliers (CompanyName, ContactName, ContactTitle, Country)
VALUES ('Pop-up Foods', 'Jake Vogel', 'Owner', 'USA');

--Verify
SELECT * FROM Suppliers WHERE CompanyName = 'Pop-up Foods';

--get supplier ID
SELECT SupplierID, CompanyName 
FROM Suppliers 
WHERE CompanyName = 'Pop-up Foods';

--Add a new product linked to your supplier
INSERT INTO Products (ProductName, SupplierID, CategoryID, UnitPrice, UnitsInStock)
VALUES ('House Special Pizza', 30, 2, 15.99, 50);

--Verify
SELECT * FROM Products WHERE ProductName = 'House Special Pizza';

--Update the price of the pizza
UPDATE Products
SET UnitPrice = 16.99
WHERE ProductName = 'House Special Pizza';

--Update both inventory count and price at the same time
UPDATE Products
SET UnitsInStock = 25, UnitPrice = 17.99      -- Increase price
WHERE ProductName = 'House Special Pizza';

--Verify
SELECT * FROM Products WHERE ProductName = 'House Special Pizza';

--Remove the pizza from the Products table
DELETE FROM Products
WHERE ProductName = 'House Special Pizza';

--Verify
SELECT * FROM Products WHERE ProductName = 'House Special Pizza';

--Challenge

--Add a brand new menu item
INSERT INTO Products (ProductName, SupplierID, CategoryID, UnitPrice, UnitsInStock)
VALUES ('Garlic Bread Deluxe', 30, 2, 6.99, 40);

--Verify
SELECT * FROM Products WHERE ProductName = 'Garlic Bread Deluxe';

-- Modify both price and stock after business changes
UPDATE Products
SET UnitPrice = 7.99, UnitsInStock = 30    --set price and modify stock  
WHERE ProductName = 'Garlic Bread Deluxe';

-- Verify
SELECT * FROM Products WHERE ProductName = 'Garlic Bread Deluxe';

-- Delete product from the menu
DELETE FROM Products
WHERE ProductName = 'Garlic Bread Deluxe';

-- Verify
SELECT * FROM Products WHERE ProductName = 'Garlic Bread Deluxe';