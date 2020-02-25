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

CREATE TABLE KN_301_Antipenkova.Антипенкова.tariffs
(
	Id tinyint NOT NULL,
	Name nvarchar(50),
	SubFee money CHECK (SubFee >= 0),
	Minutes int CHECK (Minutes >= 0 AND Minutes<=43800),
	MinFee money CHECK (MinFee >= 0)
	CONSTRAINT PK_Tariff PRIMARY KEY (Id) 
)
GO

CREATE SYNONYM Tariffs   
FOR KN_301_Antipenkova.Антипенкова.tariffs;  
GO 

CREATE FUNCTION count_tariff (@minutes int)
RETURNS tinyint
AS
BEGIN
	DECLARE @min_id tinyint = 0;
	DECLARE @minFee money = 1000000000000;

	DECLARE @id tinyint;
	DECLARE @name nvarchar(50);
	DECLARE @fee money;
	DECLARE @min_c int;
	DECLARE @min_fee money;

	DECLARE tariffsCurs CURSOR 
	FOR
	SELECT Id, Name, SubFee, Minutes, MinFee
	FROM Tariffs

	OPEN tariffsCurs
	FETCH NEXT FROM tariffsCurs INTO @id, @name, @fee, @min_c, @min_fee
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF (@minutes < @min_c)
		BEGIN
			IF (@fee < @minFee)
			BEGIN
				SET @min_id = @id;
				SET @minFee = @fee;
			END
		END
		ELSE 
		IF (((@minutes - @min_c)*@min_fee + @fee) < @minFee)
		BEGIN
			SET @min_id = @id;
			SET @minFee = ((@minutes - @min_c)*@min_fee + @fee);
		END
		FETCH NEXT FROM tariffsCurs INTO @id, @name, @fee, @min_c, @min_fee
	END
	CLOSE tariffsCurs
	DEALLOCATE tariffsCurs
	RETURN @min_id
END
GO

CREATE FUNCTION get_intersection (@sf1 money,  @sf2 money, @mc1 money, @mc2 money, @mf1 money, @mf2 money)
RETURNS money
AS
BEGIN
	IF ((@mf2-@mf1) = 0)
		RETURN NULL
	RETURN (@sf1-@sf2 - @mc1*@mf1 + @mc2*@mf2) / (@mf2-@mf1)
END
GO

CREATE PROCEDURE combain_intervals
AS
BEGIN
DECLARE @a int = -1;
	DECLARE @a1 int;
	DECLARE @d int = -1;
	DECLARE @d1 int;
	DECLARE @t nvarchar(50) = '';
	DECLARE @t1 nvarchar(50);
	DECLARE curs2 CURSOR 
	FOR
	SELECT *
	FROM #intervals

	OPEN curs2
	FETCH NEXT FROM curs2 INTO @a1, @d1, @t1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@t1 = @t)
		BEGIN
			DELETE FROM #intervals
			WHERE @a = [Начало интервала] AND @d = [Конец интервала];

			UPDATE #intervals
			SET [Начало интервала] = @a
			WHERE [Начало интервала] = @a1 AND @t1 = Тариф

			SET @d = @d1;
		END
		ELSE
		BEGIN
			SET @a = @a1
			SET @d = @d1
			SET @t = @t1
		END
		FETCH NEXT FROM curs2 INTO @a1, @d1, @t1
	END
	CLOSE curs2
	DEALLOCATE curs2
END 
GO

CREATE PROCEDURE get_intervals
AS
BEGIN
	DROP TABLE IF EXISTS #dotes; 
	CREATE TABLE #dotes 
	(
		Dot money
	)

	DECLARE @id1 tinyint;
	DECLARE @id2 tinyint;

	DECLARE @sf1 money;
	DECLARE @sf2 money;

	DECLARE @mc1 money;
	DECLARE @mc2 money;

	DECLARE @mf1 money;
	DECLARE @mf2 money;

	DECLARE curs1 CURSOR 
	FOR
	SELECT Id, SubFee, Minutes, MinFee
	FROM Tariffs

	OPEN curs1
	FETCH NEXT FROM curs1 INTO @id1, @sf1, @mc1, @mf1
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		DECLARE curs2 CURSOR 
		FOR
		SELECT Id, SubFee, Minutes, MinFee
		FROM Tariffs

		OPEN curs2
		FETCH NEXT FROM curs2 INTO @id2, @sf2, @mc2, @mf2
		WHILE @@FETCH_STATUS = 0
		BEGIN 
			IF (@id1 <> @id2)
			BEGIN
				DECLARE @intersection float;
				SET @intersection = dbo.get_intersection(@sf1, @sf2, 0, @mc2, 0, @mf2) --12
				IF (@intersection is not NULL AND (@intersection >= @sf1 OR @intersection >= @sf2)
					AND dbo.count_tariff(@intersection+1) <> dbo.count_tariff(@intersection-1))
				INSERT INTO #dotes VALUES (@intersection)

				SET @intersection = dbo.get_intersection(@sf1, @sf2, @mc1, 0, @mf1, 0) --21
				IF (@intersection is not NULL AND (@intersection >= @sf1 OR @intersection >= @sf2)
					AND dbo.count_tariff(@intersection+1) <> dbo.count_tariff(@intersection-1))
				INSERT INTO #dotes VALUES (@intersection)

				SET @intersection = dbo.get_intersection(@sf1, @sf2, @mc1, @mc2, @mf1, @mf2) --22
				IF (@intersection is not NULL AND (@intersection >= @sf1 OR @intersection >= @sf2)
					AND dbo.count_tariff(@intersection+1) <> dbo.count_tariff(@intersection-1))
				INSERT INTO #dotes VALUES (@intersection)
			END
			FETCH NEXT FROM curs2 INTO @id2, @sf2, @mc2, @mf2
		END
		CLOSE curs2
		DEALLOCATE curs2
		FETCH NEXT FROM curs1 INTO @id1, @sf1, @mc1, @mf1
	END
	CLOSE curs1
	DEALLOCATE curs1


	DROP TABLE IF EXISTS #intevals; 
	CREATE TABLE #intervals
	(
		[Начало интервала] float,
		[Конец интервала] float,
		[Тариф] nvarchar(50)
	)
	DECLARE @dot1 money = 0;
	DECLARE @dot2 money = 0;
	DECLARE curs2 CURSOR 
	FOR
	SELECT DISTINCT Dot
	FROM #dotes

	OPEN curs2
	FETCH NEXT FROM curs2 INTO @dot2
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #intervals VALUES (CONVERT(float, @dot1), CONVERT(float, @dot2), (SELECT Name FROM Tariffs WHERE Id = dbo.count_tariff(@dot2-1)))
		SET @dot1=@dot2
		FETCH NEXT FROM curs2 INTO @dot2
	END
	INSERT INTO #intervals VALUES (CONVERT(float, @dot2), CONVERT(float, 43800), (SELECT Name FROM Tariffs WHERE Id = dbo.count_tariff(@dot2+1)))
	CLOSE curs2
	DEALLOCATE curs2
	EXEC dbo.combain_intervals
	EXEC dbo.combain_intervals
	EXEC dbo.combain_intervals
	EXEC dbo.combain_intervals
	
	SELECT * FROM #intervals
END
GO

INSERT INTO Tariffs VALUES
(1, 'Безлимит', 15, 43800, 0)
,(2, 'Без абонентской платы', 0, 0, 2)
,(3, 'Тариф', 5, 10, 1.4)
GO


--INSERT INTO Tariffs VALUES
--(4, 'Неправильный тариф', 50, 45000, 0.5)
--GO

--INSERT INTO Tariffs VALUES
--(5, 'Новый тариф', 5, 10, 0.5)
--GO


--SELECT Name AS [Тариф] FROM Tariffs WHERE Id = dbo.count_tariff(1)
--GO
--SELECT Name AS [Тариф] FROM Tariffs WHERE Id = dbo.count_tariff(3)
--GO
--SELECT Name AS [Тариф] FROM Tariffs WHERE Id = dbo.count_tariff(15)
--GO
--SELECT Name AS [Тариф] FROM Tariffs WHERE Id = dbo.count_tariff(10)
--GO
--SELECT Name AS [Тариф] FROM Tariffs WHERE Id = dbo.count_tariff(40)
--GO

--SELECT Name AS [Тариф] FROM Tariffs WHERE Id = dbo.count_tariff(2)
--GO
--SELECT Name AS [Тариф] FROM Tariffs WHERE Id = dbo.count_tariff(3)
--GO

EXEC dbo.get_intervals
