/*
02_seed.sql — 匯入一些測試資料
執行前請先確保已經建立 LibraryDB 與表格（01_schema.sql）。
*/
USE LibraryDB;
GO

-- 會員
INSERT INTO dbo.Member(FullName, Email, Phone) VALUES
(N'王小明', N'ming@example.com', N'0912-345-678'),
(N'陳美玉', N'mei@example.com',  N'0922-222-222');
GO

-- 作者
INSERT INTO dbo.Author(Name) VALUES
(N'J. K. Rowling'),
(N'Haruki Murakami'),
(N'Yuval Noah Harari');
GO

-- 書籍
INSERT INTO dbo.Book(Title, Isbn13, PublishedYear, Category) VALUES
(N'Harry Potter and the Philosopher''s Stone', '9780747532699', 1997, N'Fantasy'),
(N'Norwegian Wood', '9780375704024', 1987, N'Fiction'),
(N'Sapiens: A Brief History of Humankind', '9780062316097', 2011, N'History');
GO

-- 書籍-作者關聯
INSERT INTO dbo.BookAuthor(BookId, AuthorId)
SELECT b.BookId, a.AuthorId
FROM dbo.Book b
JOIN dbo.Author a
  ON (b.Title LIKE N'Harry Potter%' AND a.Name = N'J. K. Rowling')
   OR (b.Title = N'Norwegian Wood' AND a.Name = N'Haruki Murakami')
   OR (b.Title LIKE N'Sapiens:%' AND a.Name = N'Yuval Noah Harari');
GO

-- 副本
INSERT INTO dbo.BookCopy(BookId, Barcode) VALUES
((SELECT BookId FROM dbo.Book WHERE Isbn13='9780747532699'), N'HP-0001'),
((SELECT BookId FROM dbo.Book WHERE Isbn13='9780747532699'), N'HP-0002'),
((SELECT BookId FROM dbo.Book WHERE Isbn13='9780375704024'), N'NW-0001'),
((SELECT BookId FROM dbo.Book WHERE Isbn13='9780062316097'), N'SP-0001');
GO

-- 範例借閱（王小明借HP-0001，借期14天）
DECLARE @CopyId INT = (SELECT CopyId FROM dbo.BookCopy WHERE Barcode = N'HP-0001');
DECLARE @MemberId INT = (SELECT MemberId FROM dbo.Member WHERE FullName = N'王小明');

INSERT INTO dbo.Loan(CopyId, MemberId, DueDate)
VALUES(@CopyId, @MemberId, DATEADD(day, 14, CAST(GETDATE() AS DATE)));

UPDATE dbo.BookCopy SET Status = N'Loaned' WHERE CopyId = @CopyId;
GO