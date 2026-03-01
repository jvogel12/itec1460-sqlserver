USE Northwind;
GO

-- Part 2, Procedure 1: GetProductName
CREATE OR ALTER PROCEDURE GetProductName
    @ProductID INT,
    @ProductName NVARCHAR(40) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @ProductName = ProductName
    FROM Products
    WHERE ProductID = @ProductID;

    IF @ProductName IS NULL
        PRINT 'Product not found.';
    ELSE
        PRINT 'Product Name: ' + @ProductName;
END
GO

-- Test Procedure 1
DECLARE @ProductName NVARCHAR(40);

EXEC GetProductName
    @ProductID = 1,
    @ProductName = @ProductName OUTPUT;
GO


-- Part 2, Procedure 2: GetEmployeeOrderCount
CREATE OR ALTER PROCEDURE GetEmployeeOrderCount
    @EmployeeID INT,
    @OrderCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @OrderCount = COUNT(*)
    FROM Orders
    WHERE EmployeeID = @EmployeeID;

    PRINT 'Employee ' + CAST(@EmployeeID AS NVARCHAR(10)) +
          ' processed ' + CAST(@OrderCount AS NVARCHAR(10)) +
          ' orders.';
END
GO

-- Test Procedure 2
DECLARE @OrderCount INT;

EXEC GetEmployeeOrderCount
    @EmployeeID = 5,
    @OrderCount = @OrderCount OUTPUT;
GO


-- Part 2, Procedure 3: CheckProductStock
CREATE OR ALTER PROCEDURE CheckProductStock
    @ProductID INT,
    @NeedsReorder BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitsInStock INT;
    DECLARE @ReorderLevel INT;

    SELECT 
        @UnitsInStock = UnitsInStock,
        @ReorderLevel = ReorderLevel
    FROM Products
    WHERE ProductID = @ProductID;

    IF @UnitsInStock IS NULL
    BEGIN
        PRINT 'Product not found.';
        SET @NeedsReorder = 0;
        RETURN;
    END

    IF @UnitsInStock <= @ReorderLevel
    BEGIN
        SET @NeedsReorder = 1;
        PRINT 'Product ' + CAST(@ProductID AS NVARCHAR(10)) + 
              ' needs reordering.';
    END
    ELSE
    BEGIN
        SET @NeedsReorder = 0;
        PRINT 'Product ' + CAST(@ProductID AS NVARCHAR(10)) + 
              ' stock is OK.';
    END
END
GO

-- Test Procedure 3
DECLARE @NeedsReorder BIT;

EXEC CheckProductStock
    @ProductID = 2,
    @NeedsReorder = @NeedsReorder OUTPUT;

PRINT 'Needs Reorder flag: ' + CAST(@NeedsReorder AS VARCHAR(1));
GO