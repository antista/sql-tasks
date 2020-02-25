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

CREATE TABLE KN_301_Antipenkova.Антипенкова.regions
(
	Region_id nvarchar(3) CHECK (LEN(Region_id) = 2 OR LEN(Region_id) = 3 AND LEFT(Region_id,1) IN ('1','2','7')) NOT NULL
	,Region_name nvarchar(40) NULL, 
    CONSTRAINT PK_Region PRIMARY KEY (Region_id) 
)
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.entrances
(
	Entry bit NULL
	,Time time NULL
	,Auto_id nvarchar(9)
	,Post_id tinyint
)
GO

CREATE INDEX entrancesIndex ON KN_301_Antipenkova.Антипенкова.entrances (Auto_id)
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.auto
(
	Auto_id nvarchar(9) NOT NULL UNIQUE CHECK(LEN(Auto_id) = 6 
									AND Auto_id LIKE('[ABCEHKMOPTX][0-9][0-9][0-9][ABCEHKMOPTX][ABCEHKMOPTX]'))
	,Region_id nvarchar(3)
	CONSTRAINT PK_Auto PRIMARY KEY (Auto_id)
)

CREATE TABLE KN_301_Antipenkova.Антипенкова.auto_types
(
	Type_id tinyint NOT NULL
	,Type_name nvarchar(15) NULL
	CONSTRAINT PK_Type PRIMARY KEY (Type_id)
)

CREATE TABLE  KN_301_Antipenkova.Антипенкова.posts
(
	Post_id tinyint NOT NULL
	,Post_name nvarchar(35)
	CONSTRAINT PK_Post_id PRIMARY KEY (Post_id)
)



ALTER TABLE KN_301_Antipenkova.Антипенкова.auto ADD 
	CONSTRAINT FK_Region FOREIGN KEY (Region_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.regions(Region_id)
GO

ALTER TABLE KN_301_Antipenkova.Антипенкова.entrances ADD 
	CONSTRAINT FK_Auto FOREIGN KEY (Auto_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.auto(Auto_id)
GO

ALTER TABLE KN_301_Antipenkova.Антипенкова.entrances ADD 
	CONSTRAINT FK_Post FOREIGN KEY (Post_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.posts(Post_id)
GO


CREATE SYNONYM Autos   
FOR KN_301_Antipenkova.Антипенкова.auto;  
GO 
CREATE SYNONYM Regions  
FOR KN_301_Antipenkova.Антипенкова.regions;  
GO 
CREATE SYNONYM Entrances   
FOR KN_301_Antipenkova.Антипенкова.entrances;  
GO 
CREATE SYNONYM Posts   
FOR KN_301_Antipenkova.Антипенкова.posts;  
GO 
CREATE SYNONYM Auto_types   
FOR KN_301_Antipenkova.Антипенкова.auto_types;  
GO 

CREATE FUNCTION get_last_entry_time (@auto_id nvarchar(6), @entry bit)
RETURNS time
AS
BEGIN
	RETURN (SELECT TOP 1 Time FROM Entrances WHERE Auto_id = @auto_id 
				AND Entry = @entry ORDER BY Time DESC)
END
GO


CREATE FUNCTION get_type (@auto_id nvarchar(6))
RETURNS int
AS
BEGIN
	DECLARE @curr_region nvarchar(3) = '89';
	IF ((SELECT region_id FROM Autos WHERE Auto_id = @auto_id) = @curr_region)
	BEGIN
		IF (dbo.get_last_entry_time(@auto_id, 0) < dbo.get_last_entry_time(@auto_id, 1))
			RETURN 3
	END
	ELSE
	BEGIN
		DECLARE @last_out_time time = dbo.get_last_entry_time(@auto_id, 0)
		DECLARE @last_entry_time time = dbo.get_last_entry_time(@auto_id, 1)
		DECLARE @post_in tinyint = 
			(SELECT Post_id FROM Entrances WHERE Auto_id = @auto_id 
				AND Entry = 1 AND Time = @last_entry_time)
		DECLARE @post_out tinyint = 
			(SELECT Post_id FROM Entrances WHERE Auto_id = @auto_id 
				AND Entry = 0 AND Time = @last_out_time)
		IF (@last_entry_time < @last_out_time)
			IF (@post_in = @post_out)
				RETURN 2
			ELSE
				RETURN 1
	END
	RETURN 4
END
GO

CREATE TRIGGER add_entry
ON KN_301_Antipenkova.Антипенкова.entrances
INSTEAD OF INSERT, UPDATE
AS
INSERT INTO Autos (Region_id, Auto_id)
SELECT DISTINCT  IIF(LEN(Auto_id) = 9,RIGHT(Auto_id,3),RIGHT(Auto_id,2))
				, LEFT(Auto_id,6)
FROM INSERTED
WHERE NOT EXISTS (SELECT * FROM Autos WHERE Autos.Auto_id = LEFT(INSERTED.Auto_id,6))

DECLARE @curr_region nvarchar(3) = '89';
DECLARE @entry bit;
DECLARE @time time;
DECLARE @auto_id nvarchar(6);
DECLARE @region nvarchar(3);
DECLARE @post tinyint;

DECLARE curs CURSOR 
FOR
SELECT Entry, Time, Auto_id, Post_id
FROM INSERTED

OPEN curs
FETCH NEXT FROM curs INTO @entry, @time, @auto_id, @post
WHILE @@FETCH_STATUS = 0
BEGIN 
	SET @region = (SELECT Region_id FROM Autos WHERE Auto_id=@auto_id)
	DECLARE @in_count int = ISNULL((SELECT COUNT(Entry) FROM Entrances WHERE Auto_id=@auto_id AND Entry=1 AND Time < @time),0);
	DECLARE @out_count int = ISNULL((SELECT COUNT(Entry) FROM Entrances WHERE Auto_id=@auto_id AND Entry=0 AND Time < @time),0);
	IF ((@region <> @curr_region 
		AND ((@entry = 1 
			AND  @in_count = @out_count
				AND NOT EXISTS(SELECT * FROM Entrances WHERE Auto_id = @auto_id AND Entry = 0 AND DATEADD(MINUTE,5,Time) > @time) 
		OR (@entry = 0 
			AND @in_count > @out_count
				AND NOT EXISTS(SELECT * FROM Entrances WHERE Auto_id = @auto_id AND Entry = 1 AND DATEADD(MINUTE,5,Time) > @time)))))
	OR (@region = @curr_region 
		AND ((@entry = 0 
			AND  @in_count = @out_count
				AND NOT EXISTS(SELECT * FROM Entrances WHERE Auto_id = @auto_id AND Entry = 1 AND DATEADD(MINUTE,5,Time) > @time) 
		OR (@entry = 1
			AND @in_count < @out_count
				AND NOT EXISTS(SELECT * FROM Entrances WHERE Auto_id = @auto_id AND Entry = 0 AND DATEADD(MINUTE,5,Time) > @time))))))
	BEGIN
	INSERT INTO Entrances VALUES
	(@entry, @time, @auto_id, @post)
	END
    FETCH NEXT FROM curs INTO @entry, @time, @auto_id, @post
END
CLOSE curs
DEALLOCATE curs

GO


INSERT INTO Auto_types VALUES
(1,'Транзитный')
,(2,'Иногородний')
,(3,'Местный')
,(4,'Прочие')
GO

INSERT INTO Posts VALUES
(1,'Северный')
,(2,'Южный')
,(3,'Западный')
,(4,'Восточный')
,(5,'Северо-Западный')
,(6,'Речной')
GO

INSERT INTO Regions VALUES
--('502', 'Республика Башкортостан')
--,('2', 'Республика Башкортостан')
--,('1020', 'Республика Башкортостан'),
('102', 'Республика Башкортостан')
,('07', 'Республика Карелия')
,('10', 'Республика Карелия')
,('11', 'Республика Коми')
,('12', 'Марий Эл')
,('13', 'Республика Мордовия')
,('113', 'Республика Мордовия')
,('14', 'Саха (Якутия)')
,('16', 'Республика Татарстан')
,('116', 'Республика Татарстан')
,('17', 'Республика Тыва')
,('18', 'Удмуртская Республика')
,('19', 'Республика Хакасия')
,('21', 'Чувашская Республика')
,('121', 'Чувашская Республика')
,('22', 'Алтайский край')
,('123', 'Краснодарский край')
,('23', 'Краснодарский край')
,('93', 'Краснодарский край')
,('84', 'Красноярский край')
,('88', 'Красноярский край')
,('124', 'Красноярский край')
,('24', 'Красноярский край')
,('26', 'Ставропольский край')
,('27', 'Хабаровский край')
,('28', 'Амурская область')
,('29', 'Архангельская область')
,('30', 'Астраханская область')
,('31', 'Белгородская область')
,('32', 'Брянская область')
,('33', 'Владимирская область')
,('34', 'Волгоградская область')
,('35', 'Вологодская область')
,('36', 'Воронежская область')
,('136', 'Воронежская область')
,('37', 'Ивановская область')
,('38', 'Иркутская область')
,('85', 'Иркутская область')
,('39', 'Калининградская область')
,('91', 'Калининградская область')
,('40', 'Калужская область')
,('82', 'Камчатский край')
,('41', 'Камчатский край')
,('142', 'Кемеровская область')
,('42', 'Кемеровская область')
,('43', 'Кировская область')
,('44', 'Костромская область')
,('45', 'Курганская область')
,('46', 'Курская область')
,('47', 'Ленинградская область')
,('48', 'Липецкая область')
,('49', 'Магаданская область')
,('150', 'Московская область')
,('190', 'Московская область')
,('90', 'Московская область')
,('50', 'Московская область')
,('51', 'Мурманская область')
,('152', 'Нижегородская область')
,('52', 'Нижегородская область')
,('53', 'Новгородская область')
,('54', 'Новосибирская область')
,('154', 'Новосибирская область')
,('55', 'Омская область')
,('56', 'Оренбургская область')
,('57', 'Орловская область')
,('58', 'Пензенская область')
,('159', 'Пермский край')
,('81', 'Пермский край')
,('59', 'Пермский край')
,('60', 'Псковская область')
,('61', 'Ростовская область')
,('161', 'Ростовская область')
,('62', 'Рязанская область')
,('63', 'Самарская область')
,('163', 'Самарская область')
,('64', 'Саратовская область')
,('164', 'Саратовская область')
,('65', 'Сахалинская область')
,('96', 'Свердловская область')
,('66', 'Свердловская область')
,('67', 'Смоленская область')
,('68', 'Тамбовская область')
,('69', 'Тверская область')
,('70', 'Томская область')
,('71', 'Тульская область')
,('72', 'Тюменская область')
,('173', 'Ульяновская область')
,('73', 'Ульяновская область')
,('174', 'Челябинская область')
,('74', 'Челябинская область')
,('80', 'Забайкальский край')
,('75', 'Забайкальский край')
,('76', 'Ярославская область')
,('95', 'Чеченская республика')
,('89', 'Ямало-Ненецкий автономный округ')
,('83', 'Ненецкий автономный округ')
,('87', 'Чукотский автономный округ')
,('86', 'Ханты-Мансийский автономный округ')
,('197', 'Москва')
,('777', 'Москва')
,('77', 'Москва')
,('99', 'Москва')
,('199', 'Москва')
,('97', 'Москва')
,('177', 'Москва')
,('78', 'Санкт-Петербург')
,('98', 'Санкт-Петербург')
,('178', 'Санкт-Петербург')
GO

INSERT INTO Entrances VALUES
--(1,CONVERT(time, '18:00'),'A567AM189',2),
--(1,CONVERT(time, '18:00'),'A567AM89',12),
--(1,CONVERT(time, '18:00'),'A567AM89',2),
--(1,CONVERT(time, '18:00'),'U567AM89',2)
--(1,CONVERT(time, '18:00'),'A56OAM89',2)
--(1,CONVERT(time, '18:00'),'UA567M89',2)

(0,CONVERT(time, '16:00'),'A567AM89',2)
,(1,CONVERT(time, '17:00'),'A567AM89',3)
,(0,CONVERT(time, '18:00'),'A567AM89',6)
,(1,CONVERT(time, '19:00'),'A567AM89',4)
,(1,CONVERT(time, '19:01'),'A567AM89',4)
,(0,CONVERT(time, '19:01'),'A567AM89',4)
,(0,CONVERT(time, '19:05'),'A567AM89',2)
,(1,CONVERT(time, '21:00'),'A567AM89',3) --местный

,(1,CONVERT(time, '20:00'),'O734KH96',1)
,(0,CONVERT(time, '21:00'),'O734KH96',2)
,(1,CONVERT(time, '22:00'),'O734KH96',5) --прочий

,(1,CONVERT(time, '11:00'),'P000MB66',3)
,(0,CONVERT(time, '13:00'),'P000MB66',5)
,(1,CONVERT(time, '16:00'),'P000MB66',2)
,(0,CONVERT(time, '20:00'),'P000MB66',2) --иногородний

,(1,CONVERT(time, '11:00'),'K111CA21',2)
,(0,CONVERT(time, '20:00'),'K111CA21',2) --иногородний

,(1,CONVERT(time, '15:00'),'A777AA777',1)
,(0,CONVERT(time, '16:00'),'A777AA777',1)
,(1,CONVERT(time, '17:00'),'A777AA777',4)
,(0,CONVERT(time, '22:00'),'A777AA777',2) --транзитный

,(1,CONVERT(time, '14:30'),'E412EK07',1)
,(0,CONVERT(time, '20:00'),'E412EK07',6) --транзитный
GO


--SELECT * FROM Entrances
--ORDER BY Auto_id, Time
--GO
--SELECT Auto_id,Region_id, dbo.get_type(Auto_id) FROM Autos
--GO




IF EXISTS(SELECT 1 FROM sys.views WHERE name='AutosInfo' and type='v')
DROP VIEW AutosInfo;
GO

CREATE VIEW AutosInfo AS
SELECT Auto_id+Region_id AS 'Номер автомобиля'
	,(SELECT Region_name FROM Regions WHERE Region_id = Autos.Region_id) AS 'Название региона'
	,(SELECT Type_name FROM Auto_types WHERE Type_id = dbo.get_type(Auto_id)) AS 'Тип автомобиля'
	--,FORMAT(dbo.get_last_entry_time(Auto_id, 1),N'hh\:mm') AS 'Последнее время въезда'
	--,FORMAT(dbo.get_last_entry_time(Auto_id, 0),N'hh\:mm') AS 'Последнее время выезда'
FROM Autos
GO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='EntrancesInfo' and type='v')
DROP VIEW EntrancesInfo;
GO

CREATE VIEW EntrancesInfo AS
SELECT Auto_id+(SELECT Region_id FROM Autos WHERE Auto_id = Entrances.Auto_id) AS 'Номер автомобиля'
	,FORMAT(Time,N'hh\:mm') AS 'Время'
	,IIF (Entry=1,'Въезд','Выезд') AS 'Тип пересечения'
	,(SELECT Post_name FROM Posts WHERE Post_id=Entrances.Post_id) AS 'Пост'
FROM Entrances
GO



