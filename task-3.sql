-- =============================================
-- Create database template
-- =============================================
USE master
GO
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KN_301_Antipenkova'
)
ALTER DATABASE KN_301_Antipenkova set single_user with rollback immediate
GO
-- Drop the database if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KN_301_Antipenkova'
)
DROP DATABASE KN_301_Antipenkova
GO

CREATE DATABASE KN_301_Antipenkova
GO

USE KN_301_Antipenkova
GO

IF EXISTS(
  SELECT name
    FROM sys.schemas
   WHERE name = N'Антипенкова'
) 
 DROP SCHEMA Антипенкова
GO

CREATE SCHEMA Антипенкова
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.currencies
(
	Id nvarchar(3) NOT NULL,
	Buy smallmoney,
	Sell smallmoney
	CONSTRAINT PK_Region PRIMARY KEY (Id) 

)
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.purse
(
	Currency_id nvarchar(3) NOT NULL UNIQUE,
	Count smallmoney NULL CHECK (Count >= 0)
)
GO

ALTER TABLE KN_301_Antipenkova.Антипенкова.purse ADD 
	CONSTRAINT FK_Currency_purse FOREIGN KEY (Currency_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.currencies(Id)
GO

CREATE SYNONYM Currencies   
FOR KN_301_Antipenkova.Антипенкова.currencies;  
GO 

CREATE SYNONYM Purse   
FOR KN_301_Antipenkova.Антипенкова.purse;  
GO 


CREATE PROCEDURE add_currency (@currency_name nvarchar(3), @sell smallmoney, @buy smallmoney)
AS
BEGIN
	INSERT INTO Currencies VALUES
	(UPPER(@currency_name), @sell, @buy)
END
GO

CREATE PROCEDURE update_currency (@currency_name nvarchar(3), @sell smallmoney, @buy smallmoney)
AS
BEGIN
	SET @currency_name = UPPER(@currency_name)
	IF NOT EXISTS(SELECT * FROM Currencies WHERE Id=@currency_name)
		THROW 50001, 'Валюту невозможно обновить, так как эта валюта не зарегестрирована.', 1 
	IF @currency_name = 'EUR'
		THROW 50005, 'Валюту невозможно изменить, так как эта валюта базовая.', 1 
	UPDATE Currencies
	SET Sell = @sell, Buy = @buy
	WHERE @currency_name = Id
END
GO

CREATE PROCEDURE delete_currency (@currency_name nvarchar(3))
AS
BEGIN
	SET @currency_name = UPPER(@currency_name)
	IF NOT EXISTS(SELECT * FROM Currencies WHERE Id=@currency_name)
		THROW 50002, 'Валюту невозможно удалить, так как эта валюта не зарегестрирована.', 1 
	IF @currency_name = 'EUR'
		THROW 50004, 'Валюту невозможно удалить, так как эта валюта базовая.', 1 
	DELETE FROM Currencies WHERE Id = @currency_name
END
GO

CREATE PROCEDURE pop_money (@currency_name nvarchar(3), @count smallint)
AS
BEGIN
	SET @currency_name = UPPER(@currency_name)
	IF (NOT EXISTS(SELECT * FROM Purse WHERE Currency_id=@currency_name) 
	OR (SELECT Count FROM Purse WHERE Currency_id = @currency_name)<@count)
		THROW 50003, 'Валюту невозможно взять, так как у вас ее недостаточно.', 1 
	IF (SELECT Count FROM Purse WHERE Currency_id=@currency_name)-@count = 0
		DELETE FROM Purse WHERE Currency_id = @currency_name
	ELSE
		UPDATE Purse
		SET Count = Count-@count
		WHERE Currency_id=@currency_name
END
GO

CREATE PROCEDURE push_money (@currency_name nvarchar(3), @count smallint)
AS
BEGIN
	SET @currency_name = UPPER(@currency_name)
	IF NOT EXISTS(SELECT * FROM Purse WHERE Currency_id=@currency_name)
		INSERT INTO Purse VALUES
		(@currency_name, @count)
	ELSE
		UPDATE Purse
		SET Count = Count+@count
		WHERE Currency_id=@currency_name
END
GO

CREATE FUNCTION convert_curr (@curr1 nvarchar(3), @curr2 nvarchar(3))
RETURNS money
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
	IF (@curr1 is null)
	RETURN NULL
	IF (@curr2 is null)
	RETURN NULL
	DECLARE @exc1 smallmoney = (SELECT Buy FROM Currencies WHERE Id = @curr1)
	DECLARE @exc2 smallmoney = (SELECT Buy FROM Currencies WHERE Id = @curr2)
	RETURN (@exc2/@exc1)
END
GO

CREATE PROCEDURE show_purse_sum (@currency_name nvarchar(3), @sum money OUTPUT)
AS
BEGIN
	SET @currency_name = UPPER(@currency_name)
	IF NOT EXISTS(SELECT * FROM Currencies WHERE Id=@currency_name)
		THROW 50006, 'К этой валюте нельзя привести содержимое кошелька, так как эта валюта не была зарегестрирована.', 1 
	SET @sum = 0
	DECLARE @curr nvarchar(3)
	DECLARE @count smallmoney

	DECLARE count_money CURSOR 
	FOR
	SELECT Currency_id, Count
	FROM Purse

	OPEN count_money
	FETCH NEXT FROM count_money INTO @curr, @count
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @sum = @sum + (@count * dbo.convert_curr(@curr, @currency_name))
		FETCH NEXT FROM count_money INTO @curr, @count
	END
	CLOSE count_money
	DEALLOCATE count_money
	RETURN @sum
END
GO


CREATE PROCEDURE show_table 
AS 
BEGIN
	DROP TABLE IF EXISTS #curses; 
	SELECT a.Id AS [Валюта],
			b.Id AS Curr2,
			dbo.convert_curr(a.Id,b.Id) AS Curs 
	INTO #curses
	FROM Currencies a CROSS JOIN Currencies b
	ORDER BY [Валюта]
	DECLARE @cols  AS NVARCHAR(MAX)='';
	DECLARE @query AS NVARCHAR(MAX)='';

	SELECT @cols = @cols + QUOTENAME(Id) + ',' FROM (select Id from Currencies ) as tmp
	select @cols = substring(@cols, 0, len(@cols)) --trim "," at end

	set @query = 
	'SELECT * from 
	(
		SELECT [Валюта], Curr2, CAST(Curs as float) as Cu
		FROM #curses
	) src
	pivot 
	(
	   MAX(Cu) for Curr2 in (' + @cols + ')
	) piv'

	execute(@query)
END
GO


EXEC add_currency 'EUR', 1, 1
--EXEC add_currency 'EUR', 1, 1
EXEC add_currency 'USD', 1.3769, 0.7263
EXEC add_currency 'CNY', 0.8578, 1.1658
EXEC add_currency 'HUF', 1.2409, 0.8059
EXEC add_currency 'LTL', 1.3954, 0.7166
EXEC add_currency 'JPY', 107.495, 0.0093
EXEC add_currency 'Eek', 7.4443, 0.1343
EXEC add_currency 'bgn', 1.7279, 0.5787
GO 
SELECT * FROM Currencies
GO

----- Показать таблицу, добавить валюту
--dbo.show_table
--GO

--EXEC add_currency 'SEC', 9.0357, 0.1107
--GO
--dbo.show_table
--GO

--EXEC delete_currency 'SEC'
--GO
--dbo.show_table
--GO

-----  Обновление валюты
--EXEC update_currency 'BGN', 2, 1
--GO
--SELECT * FROM Currencies


--------   Обновление несуществующей валюты
--EXEC update_currency 'HHH', 3, 2
--GO
--SELECT * FROM Currencies

---------  Повтороное удаление валюты
--EXEC delete_currency 'BGN'
--GO
--SELECT * FROM Currencies

--EXEC delete_currency 'BGN'
--GO
--SELECT * FROM Currencies









------   Добавление валюты в кошелек
--EXEC push_money 'USD', 15
--GO
--SELECT * FROM Purse

--EXEC push_money 'USD', 15
--GO
--SELECT * FROM Purse

--------  Попытка взять валюту, которой нет в кошельке
--EXEC pop_money 'EUR', 10
--GO
--SELECT * FROM Purse


------- Попытка взять больше валюты чем есть
--EXEC pop_money 'USD', 40
--GO
--SELECT * FROM Purse

-------  Взятие всей валюты удаляет ее из кошелька
--EXEC push_money 'EUR', 10
--GO
--SELECT * FROM Purse

--EXEC pop_money 'EUR', 10
--GO
--SELECT * FROM Purse

------- Попытка положить несуществующую валюту
--EXEC push_money 'HHH', 15
--GO
--SELECT * FROM Purse


------   Добавление валюты
--EXEC add_currency 'AUD', 1.3273, 0.7534
--GO 

--EXEC push_money 'AUD', 10
--GO


--EXEC push_money 'AUD', 10
--GO
--SELECT * FROM Purse


------ Показать все деньги в кошельке
--EXEC push_money 'USD', 15
--EXEC push_money 'EUR', 150
--EXEC push_money 'JPY', 47
--EXEC push_money 'LTL', 2
--EXEC push_money 'HUF', 10
--GO

--DECLARE @res money 
--DECLARE @currency nvarchar(3) = 'EUR' 
----DECLARE @currency nvarchar(3) = 'USD' 
----DECLARE @currency nvarchar(3) = 'JPY' 
--EXEC show_purse_sum @currency, @sum = @res OUTPUT
--SELECT @res AS 'Общее количество денег'
--GO

--EXEC pop_money 'JPY', 10
--GO
