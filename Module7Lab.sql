USE Northwind;
GO

-- Procedure 1: No parameters
-- This procedure just prints a message.

CREATE OR ALTER PROCEDURE WelcomeMessage
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Welcome to the Northwind Database!';
END
GO

-- Test it
EXEC WelcomeMessage;
GO

-- Procedure 2: One input parameter
-- Looks up a customer's company name by CustomerID.

CREATE OR ALTER PROCEDURE GetCustomerName
    @CustomerID NCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CompanyName NVARCHAR(40);

    SELECT @CompanyName = CompanyName
    FROM Customers
    WHERE CustomerID = @CustomerID;

    IF @CompanyName IS NULL
        PRINT 'Customer not found.';
    ELSE
        PRINT 'Company Name: ' + @CompanyName;
END
GO

-- Test with a valid customer
EXEC GetCustomerName @CustomerID = 'ALFKI';
GO

-- Test with an invalid customer
EXEC GetCustomerName @CustomerID = 'ZZZZZ';
GO

-- Procedure 3: One input parameter, one output parameter
-- Returns the total number of orders for a customer.

CREATE OR ALTER PROCEDURE GetCustomerOrderCount
    @CustomerID NCHAR(5),
    @OrderCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @OrderCount = COUNT(*)
    FROM Orders
    WHERE CustomerID = @CustomerID;
END
GO

-- Test it
DECLARE @OrderCount INT;

EXEC GetCustomerOrderCount
    @CustomerID = 'ALFKI',
    @OrderCount = @OrderCount OUTPUT;

PRINT 'Order count for ALFKI: ' + CAST(@OrderCount AS NVARCHAR(10));
GO

-- Procedure 4: Input and output parameters with error handling
-- Calculates the total dollar amount for a given order.

CREATE OR ALTER PROCEDURE CalculateOrderTotal
    @OrderID INT,
    @TotalAmount MONEY OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalAmount = SUM(UnitPrice * Quantity * (1 - Discount))
    FROM [Order Details]
    WHERE OrderID = @OrderID;

    IF @TotalAmount IS NULL
    BEGIN
        SET @TotalAmount = 0;
        PRINT 'Order ' + CAST(@OrderID AS NVARCHAR(10)) + ' not found.';
        RETURN;
    END

    PRINT 'Total for Order ' + CAST(@OrderID AS NVARCHAR(10)) + ': $' + CAST(@TotalAmount AS NVARCHAR(20));
END
GO

-- Test with a valid order
DECLARE @TotalAmount MONEY;

EXEC CalculateOrderTotal
    @OrderID = 10248,
    @TotalAmount = @TotalAmount OUTPUT;

PRINT 'Returned total: $' + CAST(@TotalAmount AS NVARCHAR(20));
GO

-- Test with an invalid order
DECLARE @TotalAmount MONEY;

EXEC CalculateOrderTotal
    @OrderID = 99999,
    @TotalAmount = @TotalAmount OUTPUT;

PRINT 'Returned total: $' + CAST(ISNULL(@TotalAmount, 0) AS NVARCHAR(20));
GO