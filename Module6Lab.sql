CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    BirthDate DATE
); 


CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(100),
    AuthorID INT,
    PublicationYear INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
); 


-- Insert data into Authors table
INSERT INTO Authors (AuthorID, FirstName, LastName, BirthDate)
VALUES 
(1, 'Jane', 'Austen', '1775-12-16'),
(2, 'George', 'Orwell', '1903-06-25'),
(3, 'J.K.', 'Rowling', '1965-07-31'),
(4, 'Ernest', 'Hemingway', '1899-07-21'),
(5, 'Virginia', 'Woolf', '1882-01-25');

-- Insert data into Books table
INSERT INTO Books (BookID, Title, AuthorID, PublicationYear, Price)
VALUES 
(1, 'Pride and Prejudice', 1, 1813, 12.99),
(2, '1984', 2, 1949, 10.99),
(3, 'Harry Potter and the Philosopher''s Stone', 3, 1997, 15.99),
(4, 'The Old Man and the Sea', 4, 1952, 11.99),
(5, 'To the Lighthouse', 5, 1927, 13.99);


--create a ciew that combines data from both tables
CREATE VIEW BookDetails AS
SELECT 
    b.BookID,
    b.Title,
    a.FirstName + ' ' + a.LastName AS AuthorName,
    b.PublicationYear,
    b.Price
FROM 
    Books b
JOIN 
    Authors a ON b.AuthorID = a.AuthorID;

--Create a view named RecentBooks that shows books published after the year 1990.
CREATE VIEW RecentBooks AS
SELECT 
    BookID,
    Title,
    PublicationYear,
    Price
FROM 
    Books
WHERE 
    PublicationYear > 1990;

--Create a view named AuthorStats that shows the number of books and average price of books for each author.
CREATE VIEW AuthorStats AS
SELECT 
    a.AuthorID,
    a.FirstName + ' ' + a.LastName AS AuthorName,
    COUNT(b.BookID) AS BookCount,
    AVG(b.Price) AS AverageBookPrice
FROM 
    Authors a
LEFT JOIN 
    Books b ON a.AuthorID = b.AuthorID
GROUP BY 
    a.AuthorID, a.FirstName, a.LastName;


-- a) Retrieve all records from the BookDetails view
SELECT Title, Price FROM BookDetails;

-- b) List all books from the RecentBooks view
SELECT * FROM RecentBooks;

-- c) Show statistics for authors
SELECT * FROM AuthorStats;

--Create an updateable view named AuthorContactInfo that allows updating the author's first name and last name.
CREATE VIEW AuthorContactInfo AS
SELECT 
    AuthorID,
    FirstName,
    LastName
FROM 
    Authors;

--update author name
UPDATE AuthorContactInfo
SET FirstName = 'Joanne'
WHERE AuthorID = 3;   

--create audit table
CREATE TABLE BookPriceAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE()
);

--create the trigger
CREATE TRIGGER trg_BookPriceChange
ON Books
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Price)
    BEGIN
        INSERT INTO BookPriceAudit (BookID, OldPrice, NewPrice)
        SELECT 
            i.BookID,
            d.Price,
            i.Price
        FROM inserted i
        JOIN deleted d ON i.BookID = d.BookID
    END
END;

--test by updating a book price
UPDATE Books
SET Price = 14.99
WHERE BookID = 1;

--chack table
SELECT * FROM BookPriceAudit;




-- PART 2

--Create BookReviews Table
CREATE TABLE BookReviews (
    ReviewID INT PRIMARY KEY,  -- Unique review ID

    BookID INT NOT NULL,       -- References Books table
    CustomerID NCHAR(5) NOT NULL,  -- References Customers table

    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5), -- Must be 1-5

    ReviewText NVARCHAR(MAX),  -- Written review
    ReviewDate DATE NOT NULL,  -- Date of review

    -- Foreign Key to Books
    CONSTRAINT FK_BookReviews_Books
        FOREIGN KEY (BookID) REFERENCES Books(BookID),

    -- Foreign Key to Customers
    CONSTRAINT FK_BookReviews_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

--Create View
CREATE VIEW vw_BookReviewStats AS
SELECT 
    b.Title AS BookTitle,
    COUNT(br.ReviewID) AS TotalReviews,
    AVG(CAST(br.Rating AS DECIMAL(3,2))) AS AverageRating,
    MAX(br.ReviewDate) AS MostRecentReviewDate
FROM Books b
LEFT JOIN BookReviews br
    ON b.BookID = br.BookID
GROUP BY b.Title;


--Trigger: Prevent Future Review Dates
CREATE TRIGGER tr_ValidateReviewDate
ON BookReviews
AFTER INSERT, UPDATE
AS
BEGIN
    -- Check if any new review has a future date
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE ReviewDate > GETDATE()
    )
    BEGIN
        RAISERROR ('Review date cannot be in the future.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


--Add AverageRating Column to Books
ALTER TABLE Books
ADD AverageRating DECIMAL(3,2);


--Trigger: Automatically Update Book Average Rating
CREATE TRIGGER tr_UpdateBookRating
ON BookReviews
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE b
    SET AverageRating = (
        SELECT AVG(CAST(Rating AS DECIMAL(3,2)))
        FROM BookReviews br
        WHERE br.BookID = b.BookID
    )
    FROM Books b
    WHERE b.BookID IN (
        SELECT BookID FROM inserted
        UNION
        SELECT BookID FROM deleted
    );
END;

--test
INSERT INTO BookReviews
VALUES (1, 1, 'ALFKI', 5, 'Great book!', GETDATE());

INSERT INTO BookReviews
VALUES (2, 2, 'ANATR', 4, 'Very informative.', GETDATE());

INSERT INTO BookReviews
VALUES (3, 3, 'ANTON', 3, 'Pretty good.', GETDATE());


--test fail
INSERT INTO BookReviews
VALUES (4, 1, 'ALFKI', 5, 'Future test', '2099-01-01');

--check the view
SELECT * FROM vw_BookReviewStats;

--Update a Review
UPDATE BookReviews
SET Rating = 2
WHERE ReviewID = 1;

SELECT BookID, AverageRating FROM Books;