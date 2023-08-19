-- 1. и 2.
ALTER TRIGGER GetBook
ON Issued
FOR INSERT AS
DECLARE @count INT = 0
DECLARE @id INT = 0
IF EXISTS(SELECT * FROM INSERTED, Book WHERE book_name = Book.name)
BEGIN
	SELECT @id = Book.id, @count = Book.quantity FROM INSERTED, Book WHERE book_name = Book.name
	IF (@count = 0)
	BEGIN
		PRINT 'Нет книги в наличии'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		UPDATE Book
		SET Book.quantity = @count - 1
		WHERE Book.id = @id
	END
END
ELSE
BEGIN
	PRINT 'Нет такой книги в библиотеке'
END

-- 3. и 4.
ALTER TRIGGER ReturnBook
ON Returned
FOR INSERT AS
DECLARE @all_count INT = 0
DECLARE @count INT = 0
DECLARE @id INT = 0
IF EXISTS(SELECT * FROM INSERTED, Book WHERE book_name = Book.name)
BEGIN
	SELECT @id = Book.id, @all_count = Book.total_count, @count = Book.quantity FROM INSERTED, Book WHERE book_name = Book.name
	IF (@count + 1 > @all_count)
	BEGIN
		PRINT 'Все книги в наличии'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		UPDATE Book
		SET Book.quantity = @count + 1
		WHERE Book.id = @id
	END
END
ELSE
BEGIN
	PRINT 'Нет такой книги в библиотеке'
END

-- 5.
ALTER TRIGGER MoreThanThree
ON Issued
FOR INSERT AS
DECLARE @quantity_on_hand INT = 0
SELECT @quantity_on_hand = COUNT(*) FROM INSERTED, Issued WHERE INSERTED.last_name = Issued.last_name
IF (@quantity_on_hand > 3)
BEGIN
	PRINT 'На руках минимум 3 книги'
	ROLLBACK TRAN
END

-- 6.
ALTER TRIGGER DeleteBook
ON Book
AFTER DELETE AS	
INSERT INTO LibDeleted(name, pages, year_press, id_theme, id_category, id_author, id_publishment, comment, quantity, total_count) 
SELECT name, pages, year_press, id_theme, id_category, id_author, id_publishment, comment, quantity, total_count 
FROM DELETED

-- 7.
CREATE TRIGGER AddBook
ON Book
FOR INSERT AS
DECLARE @name NVARCHAR(100) = NULL
SELECT @name = INSERTED.name FROM INSERTED, Book WHERE INSERTED.name = Book.name
IF (@name IS NOT NULL)
BEGIN
	DELETE FROM LibDeleted WHERE LibDeleted.name = @name
END

-- 8.
CREATE TRIGGER CheckStudent
ON Issued
FOR INSERT AS
IF EXISTS(select *
		from S_Cards, INSERTED, Issued
		where Issued.last_name = INSERTED.last_name AND MONTH(cast(S_Cards.date_in as date)) - MONTH(cast(S_Cards.date_out as date)) > 2)
BEGIN
	PRINT 'Студент книгу читал больше двух месяцев'
	ROLLBACK TRAN
END

-- 9.
CREATE TRIGGER SomeName
ON Issued
FOR INSERT AS
DECLARE @count INT = 0
DECLARE @id INT = 0
IF EXISTS(select * FROM INSERTED WHERE INSERTED.name = 'Вячеслав')
BEGIN
	SELECT @id = Book.id, @count = Book.quantity FROM INSERTED, Book WHERE book_name = Book.name
	UPDATE Book
	SET Book.quantity = @count - 1
	WHERE Book.id = @id
END
