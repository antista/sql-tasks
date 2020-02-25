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

CREATE TABLE KN_301_Antipenkova.Антипенкова.position
(
	Position_id tinyint NOT NULL, 
	Position_name nvarchar(40) NULL, 
    CONSTRAINT PK_Position_id PRIMARY KEY (Position_id) 
)
GO


CREATE TABLE KN_301_Antipenkova.Антипенкова.stadion
(
	Stadion_id tinyint NOT NULL, 
	Stadion_name nvarchar(40) NULL, 
    CONSTRAINT PK_Stadion_id PRIMARY KEY (Stadion_id) 
)
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.comand
(
	Comand_id tinyint NOT NULL, 
	Comand_country nvarchar(40) NULL, 
	Group_number varchar(1) NULL, 
    CONSTRAINT PK_Comand_id PRIMARY KEY (Comand_id) 
)
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.match
(
	Match_id tinyint NOT NULL, 
	Stadion_id tinyint NULL, 
	Match_date datetime NULL,
    CONSTRAINT PK_Match_id PRIMARY KEY (Match_id) 
)
GO 
 
 
CREATE TABLE KN_301_Antipenkova.Антипенкова.game
(
	Match_id tinyint NOT NULL, 
	Comand1_id tinyint NOT NULL,
	Comand2_id tinyint NOT NULL
)
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.player
(
	Player_id tinyint NOT NULL, 
	Player_name varchar(50) NULL,
	Position_id tinyint NULL,
	Comand_id tinyint NULL,
    CONSTRAINT PK_Player_id PRIMARY KEY (Player_id) 
)
GO

CREATE TABLE KN_301_Antipenkova.Антипенкова.goal
(
	Point bit NULL,
	Player_id tinyint NULL, 
	Match_id tinyint NULL,
	Comand_id tinyint NULL
	
)
GO


CREATE SYNONYM Goals   
FOR KN_301_Antipenkova.Антипенкова.goal;  
GO 
CREATE SYNONYM Matches   
FOR KN_301_Antipenkova.Антипенкова.match;  
GO
CREATE SYNONYM Players   
FOR KN_301_Antipenkova.Антипенкова.player;  
GO 
CREATE SYNONYM Games   
FOR KN_301_Antipenkova.Антипенкова.game;  
GO 
CREATE SYNONYM Comands   
FOR KN_301_Antipenkova.Антипенкова.comand;  
GO 
CREATE SYNONYM Positions   
FOR KN_301_Antipenkova.Антипенкова.position;  
GO 
CREATE SYNONYM Stadions   
FOR KN_301_Antipenkova.Антипенкова.stadion;  
GO 

ALTER TABLE KN_301_Antipenkova.Антипенкова.game ADD 
	CONSTRAINT FK_Match_id FOREIGN KEY (Match_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.match(Match_id)
GO

ALTER TABLE KN_301_Antipenkova.Антипенкова.game ADD 
	CONSTRAINT FK_Comand1_id FOREIGN KEY (Comand1_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.comand(Comand_id)
GO
ALTER TABLE KN_301_Antipenkova.Антипенкова.game ADD 
	CONSTRAINT FK_Comand2_id FOREIGN KEY (Comand2_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.comand(Comand_id)
GO

ALTER TABLE KN_301_Antipenkova.Антипенкова.player ADD 
	CONSTRAINT FK_Position_id FOREIGN KEY (Position_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.position(Position_id)
GO	

ALTER TABLE KN_301_Antipenkova.Антипенкова.player ADD 
	CONSTRAINT FK_Player_Comand_id FOREIGN KEY (Comand_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.comand(Comand_id)
GO	

ALTER TABLE KN_301_Antipenkova.Антипенкова.goal ADD 
	CONSTRAINT FK_Goal_Player_id FOREIGN KEY (Player_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.player(Player_id)
GO	

ALTER TABLE KN_301_Antipenkova.Антипенкова.goal ADD 
	CONSTRAINT FK_Goal_Comand_id FOREIGN KEY (Comand_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.comand(Comand_id)
GO	

ALTER TABLE KN_301_Antipenkova.Антипенкова.goal ADD 
	CONSTRAINT FK_Goal_Match_id FOREIGN KEY (Match_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.match(Match_id)
GO	

ALTER TABLE KN_301_Antipenkova.Антипенкова.match ADD 
	CONSTRAINT FK_Match_Stasion_id FOREIGN KEY (Stadion_id) 
	REFERENCES KN_301_Antipenkova.Антипенкова.stadion(Stadion_id)
GO	

INSERT INTO Positions VALUES 
 (1,'Вратарь'),
 (2,'Полузащитник'),
 (3,'Центральный защитник'),
 (4,'Левый защитник'),
 (5,'Правый защитник'),
 (6,'Левый выдвинутый защитник'),
 (7,'Правый выдвинутый защитник'),
 (8,'Опорный полузащитник'),
 (9,'Оттянутый нападающий'),
 (10,'Чистильщик'),
 (11,'Центральный нападающий')

INSERT INTO Comands VALUES
(1, 'Россия', 'A'),
(2, 'Уганда', 'A'),
(3, 'Узбекистан', 'A'),
(4, 'Туркменистан', 'A'),
(5, 'Китай', 'B'),
(6, 'Венгрия', 'B'),
(7, 'Италия', 'B'),
(8, 'Германия', 'B'),
(9, 'Англия', 'C'),
(10, 'Швеция', 'C'),
(11, 'Швейцария', 'C'),
(12, 'Чехия', 'C'),
(13, 'Австрия', 'D'),
(14, 'Австралия', 'D'),
(15, 'Бразилия', 'D'),
(16, 'Япония', 'D')

INSERT INTO Stadions VALUES
(1, 'Ростов-Арена'),
(2, 'Самара-Арена'),
(3, 'Лужники'),
(4, 'Нижний Новгород'),
(5, 'Фишт'),
(6, 'Волгоград-Арена'),
(7, 'Екатеринбург-Арена'),
(8, 'Казань-Арена'),
(9, 'Калининград'),
(10, 'Санкт-Петербург'),
(11, 'Спартак'),
(12, 'Мордовия-Арена')

INSERT INTO Players VALUES
(1, 'Тома Н’Коно', 1, 1),
(2, 'Луис Кубилья', 2, 1),
(3, 'Конго Пол', 3, 1),
(4, 'Зизиньо', 4, 1),
(5, 'Герд Мюллер', 5, 1),
(6, 'Абеди Пеле', 6, 1),
(7, 'Олег Блохин', 7, 1),
(8, 'Томас Равелли', 8, 1),
(9, 'Артур Фриденрайх', 9, 1),
(10, 'Адольф Арма', 10, 1),
(11, 'Конго Мвемба', 11, 1),
(12, 'Салах Ассао', 1, 2),
(13, 'Йозеф Масопуст', 2, 2),
(14, 'Пеле', 3, 2),
(15, 'Франтишек Планичка', 4, 2),
(16, 'Эктор Скароне', 5, 2),
(17, 'Садок Сасси', 6, 2),
(18, 'Питер Шилтон', 7, 2),
(19, 'Гуннар Нордаль', 8, 2),
(20, 'Юсеф Фофана', 9, 2),
(21, 'Али Бенчех', 10, 2),
(22, 'Йозеф Бицан', 11, 2),
(23, 'Микаэль Лаудруп', 1, 3),
(24, 'Томас Коно', 2, 3),
(25, 'Аравии Мохамед', 3, 3),
(26, 'Адольфо Педернера', 4, 3),
(27, 'Жак Сонго’о', 5, 3),
(28, 'Кадзуёси Миура', 6, 3),
(29, 'Йохан Кройф', 7, 3),
(30, 'Сегун Одегбами', 8, 3),
(31, 'Энтони Йебоа', 9, 3),
(32, 'Магди Абдельгани', 10, 3),
(33, 'Уве Зеелер', 11, 3),
(34, 'Джамел Лалмас', 1, 4),
(35, 'Ясухико Окудэра', 2, 4),
(36, 'Ирландии Джордж', 3, 4),
(37, 'Диего Марадона', 4, 4),
(38, 'Эдвин ван', 5, 4),
(39, 'Мишель Прюдомм', 6, 4),
(40, 'Папа Камара', 7, 4),
(41, 'Алессандро «Сандро»', 8, 4),
(42, 'Вальтер Земан', 9, 4),
(43, 'Махмуд Эль-Хатиб', 10, 4),
(44, 'Али Парвин', 11, 4),
(45, 'Бобби Чарльтон', 1, 5),
(46, 'Сандей Олисе', 2, 5),
(47, 'Раймон Копа', 3, 5),
(48, 'Корея Чха', 4, 5),
(49, 'Хорхе Кампос', 5, 5),
(50, 'Марко ван', 6, 5),
(51, 'Джанпьеро Комби', 7, 5),
(52, 'Эммануэль Амунике', 8, 5),
(53, 'Диди', 9, 5),
(54, 'Салиф Кейта', 10, 5),
(55, 'Антонио Карбахаль', 11, 5),
(56, 'Ринат Дасаев', 1, 6),
(57, 'Ахмед Фарас', 2, 6),
(58, 'Ханс ван', 3, 6),
(59, 'Лев Яшин', 4, 6),
(60, 'Бенгали Силла', 5, 6),
(61, 'Рене Игита', 6, 6),
(62, 'Йожеф Божик', 7, 6),
(63, 'Кунисигэ Камамото', 8, 6),
(64, 'Поль ван', 9, 6),
(65, 'Элиас Фигероа', 10, 6),
(66, 'Марк Фиш', 11, 6),
(67, 'Финиди Джордж', 1, 7),
(68, 'Мишель Платини', 2, 7),
(69, 'Карим Багери', 3, 7),
(70, 'Тарек Диаб', 4, 7),
(71, 'Виктор Икпеба', 5, 7),
(72, 'Зико', 6, 7),
(73, 'Роже Милла', 7, 7),
(74, 'Фрэнк Свифт', 8, 7),
(75, 'Прадип Кумар', 9, 7),
(76, 'Испании Ференц', 10, 7),
(77, 'Хосе Леандро', 11, 7),
(78, 'Рудольф «Руди»', 1, 8),
(79, 'Стэнли Мэтьюз', 2, 8),
(80, 'Конго Етефе', 3, 8),
(81, 'Масами Ихара', 4, 8),
(82, 'Мохаммед Кейта', 5, 8),
(83, 'Ибрахим Сандей', 6, 8),
(84, 'Обдулио Хасинто', 7, 8),
(85, 'Эйсебио', 8, 8),
(86, 'Даниэль Амокачи', 9, 8),
(87, 'Эрнст Оцвирк', 10, 8),
(88, 'Джачинто Факкетти', 11, 8),
(89, 'Ян Томашевски', 1, 9),
(90, 'Амадео Каррисо', 2, 9),
(91, 'Серж-Алаин Магуи', 3, 9),
(92, 'Вальтер Дзенга', 4, 9),
(93, 'Лоран Поку', 5, 9),
(94, 'Рууд Гуллит', 6, 9),
(95, 'Гарринча', 7, 9),
(96, 'Фейсал Ад-Дахиль', 8, 9),
(97, 'Ибрагим Юсуф', 9, 9),
(98, 'Джордж Веа', 10, 9),
(99, 'Ахмед Шубейр', 11, 9),
(100, 'Франсиско Хенто', 1, 10),
(101, 'Иво Виктор', 2, 10),
(102, 'Абдель Азиз', 3, 10),
(103, 'Ходадад Азизи', 4, 10),
(104, 'Владимир', 5, 10),
(105, 'Карим Абдул', 6, 10),
(106, 'Баду Заки', 7, 10),
(107, 'Франц Беккенбауэр', 8, 10),
(108, 'Харальд Шумахер', 9, 10),
(109, 'Франсуа Омам-Бийик', 10, 10),
(110, 'Теофиль Абега', 11, 10),
(111, 'Хуан Альберто', 1, 11),
(112, 'Али Абугрейсма', 2, 11),
(113, 'Тостао', 3, 11),
(114, 'Маттиас Синделар', 4, 11),
(115, 'Уго Санчес', 5, 11),
(116, 'Нванкво Кану', 6, 11),
(117, 'Тахар Абу-Зеид', 7, 11),
(118, 'Жюст Фонтен', 8, 11),
(119, 'Яфет Н’Дорам', 9, 11),
(120, 'Уго Гатти', 10, 11),
(121, 'Пьяпонг Пье-оун', 11, 11),
(122, 'Роке Масполи', 1, 12),
(123, 'Хосе Луис', 2, 12),
(124, 'Эмерсон Леао', 3, 12),
(125, 'Шандор Кочиш', 4, 12),
(126, 'Опоку', 5, 12),
(127, 'Джанни Ривера', 6, 12),
(128, 'Аравии Маджид', 7, 12),
(129, 'Дино Дзофф', 8, 12),
(130, 'Андони Субисаррета', 9, 12),
(131, 'Кевин Киган', 10, 12),
(132, 'Шериф Сулейман', 11, 12),
(133, 'Рабах Маджер', 1, 13),
(134, 'Рашиди Йекини', 2, 13),
(135, 'Денис Лоу', 3, 13),
(136, 'Фриц Вальтер', 4, 13),
(137, 'Аравии Саид', 5, 13),
(138, 'Джузеппе Меацца', 6, 13),
(139, 'Сильвио Пиола', 7, 13),
(140, 'Гордон Бэнкс', 8, 13),
(141, 'Хани Рамзи', 9, 13),
(142, 'Народной Республики', 10, 13),
(143, 'Питер Руфаи', 11, 13),
(144, 'Франко Барези', 1, 14),
(145, 'Жан-Мари Пфафф', 2, 14),
(146, 'Ален Гуамене', 3, 14),
(147, 'Жилмар', 4, 14),
(148, 'Лотар Маттеус', 5, 14),
(149, 'Омар Сивори', 6, 14),
(150, 'Брюс Гроббелаар', 7, 14),
(151, 'Теофило Кубильяс', 8, 14),
(152, 'Корея Хон', 9, 14),
(153, 'Убальдо Фильоль', 10, 14),
(154, 'Ларби Бен', 11, 14),
(155, 'Лахдар Беллуми', 1, 15),
(156, 'Жозеф-Антуан Белл', 2, 15),
(157, 'Петер Шмейхель', 3, 15),
(158, 'Ирландии Пат', 4, 15),
(159, 'Корея Чхве', 5, 15),
(160, 'Конго Тшимен', 6, 15),
(161, 'Петит Сорри', 7, 15),
(162, 'Рикардо Самора', 8, 15),
(163, 'Бобби Мур', 9, 15),
(164, 'Карл-Хайнц Румменигге', 10, 15),
(165, 'Роберт Менса', 11, 15),
(166, 'Мохаммед Тимуми', 1, 16),
(167, 'Ладислао Мазуркевич', 2, 16),
(168, 'Зепп Майер', 3, 16),
(169, 'Арсенио Эрико', 4, 16),
(170, 'Ахмед Рахди', 5, 16),
(171, 'Дьюла Грошич', 6, 16),
(172, 'Хосе Мануэль', 7, 16),
(173, 'Корея Ким', 8, 16),
(174, 'Али Даеи', 9, 16),
(175, 'Жан Манга', 10, 16),
(176, 'Калуша Бвалиа', 11, 16)

INSERT INTO Matches VALUES
(1, 6, CONVERT(datetime, '2018-06-24 18:00:00', 120)),
(2, 5, CONVERT(datetime, '2018-06-25 16:00:00', 120)),
(3, 4, CONVERT(datetime, '2018-06-24 12:00:00', 120)),
(4, 3, CONVERT(datetime, '2018-06-26 14:00:00', 120)),
(5, 2, CONVERT(datetime, '2018-06-24 16:00:00', 120)),
(6, 1, CONVERT(datetime, '2018-06-25 12:00:00', 120)),
(7, 8, CONVERT(datetime, '2018-06-26 16:00:00', 120)),
(8, 7, CONVERT(datetime, '2018-06-27 14:00:00', 120)),
(9, 11, CONVERT(datetime, '2018-06-27 18:00:00', 120)),
(10, 10, CONVERT(datetime, '2018-06-25 14:00:00', 120)),
(11, 9, CONVERT(datetime, '2018-06-26 20:00:00', 120)),
(12, 12, CONVERT(datetime, '2018-06-27 12:00:00', 120)),
(13, 1, CONVERT(datetime, '2018-06-23 12:00:00', 120)),
(14, 2, CONVERT(datetime, '2018-06-23 14:00:00', 120)),
(15, 3, CONVERT(datetime, '2018-06-24 22:00:00', 120))


INSERT INTO Games VALUES
(1, 1, 2),
(2, 3, 4),
(3, 5, 6),
(4, 7, 8),
(5, 9, 10),
(6, 11, 12),
(7, 13, 14),
(8, 15, 16),
(9, 2, 4),
(10, 5, 8),
(11, 9, 11),
(12, 14, 15),
(13, 2, 5),
(14, 11, 15),
(15, 5, 11)
 
INSERT INTO Goals VALUES
(0, 5, 1, 1),
(1, 9, 1, 1),
(1, 5, 1, 1),
(0, 11, 1, 1),
(1, 9, 1, 1),
(0, 4, 1, 1),
(1, 20, 1, 2),
(1, 17, 1, 2),
(0, 19, 1, 2),
(0, 32, 2, 3),
(1, 25, 2, 3),
(1, 33, 2, 3),
(0, 29, 2, 3),
(1, 24, 2, 3),
(1, 28, 2, 3),
(1, 26, 2, 3),
(0, 41, 2, 4),
(1, 40, 2, 4),
(1, 44, 2, 4),
(1, 42, 2, 4),
(0, 35, 2, 4),
(1, 34, 2, 4),
(1, 34, 2, 4),
(1, 38, 2, 4),
(1, 38, 2, 4),
(1, 48, 3, 5),
(1, 45, 3, 5),
(0, 49, 3, 5),
(1, 54, 3, 5),
(0, 56, 3, 6),
(1, 56, 3, 6),
(1, 62, 3, 6),
(0, 63, 3, 6),
(0, 73, 4, 7),
(0, 77, 4, 7),
(0, 71, 4, 7),
(0, 73, 4, 7),
(0, 69, 4, 7),
(0, 69, 4, 7),
(0, 68, 4, 7),
(1, 68, 4, 7),
(1, 69, 4, 7),
(1, 78, 4, 8),
(0, 82, 4, 8),
(1, 79, 4, 8),
(0, 87, 4, 8),
(1, 79, 4, 8),
(0, 110, 5, 10),
(0, 101, 5, 10),
(0, 99, 5, 9),
(0, 97, 5, 9),
(0, 93, 5, 9),
(1, 95, 5, 9),
(0, 94, 5, 9),
(1, 97, 5, 9),
(1, 97, 5, 9),
(0, 116, 6, 11),
(1, 116, 6, 11),
(1, 115, 6, 11),
(1, 117, 6, 11),
(1, 114, 6, 11),
(0, 121, 6, 11),
(0, 111, 6, 11),
(1, 114, 6, 11),
(0, 128, 6, 12),
(1, 130, 6, 12),
(0, 132, 6, 12),
(0, 125, 6, 12),
(1, 130, 6, 12),
(0, 138, 7, 13),
(0, 135, 7, 13),
(0, 142, 7, 13),
(0, 137, 7, 13),
(0, 133, 7, 13),
(0, 136, 7, 13),
(0, 143, 7, 13),
(1, 142, 7, 13),
(0, 141, 7, 13),
(0, 142, 7, 13),
(1, 152, 7, 14),
(1, 146, 7, 14),
(1, 150, 7, 14),
(0, 156, 8, 15),
(0, 165, 8, 15),
(1, 164, 8, 15),
(0, 156, 8, 15),
(1, 158, 8, 15),
(1, 172, 8, 16),
(0, 167, 8, 16),
(0, 167, 8, 16),
(0, 175, 8, 16),
(1, 52, 10, 5),
(0, 51, 10, 5),
(0, 54, 10, 5),
(0, 53, 10, 5),
(0, 79, 10, 8),
(1, 87, 10, 8),
(0, 83, 10, 8),
(0, 88, 10, 8),
(0, 83, 10, 8),
(0, 111, 11, 11),
(1, 114, 11, 11),
(1, 112, 11, 11),
(1, 113, 11, 11),
(1, 111, 11, 11),
(0, 114, 11, 11),
(1, 117, 11, 11),
(0, 90, 11, 9),
(1, 92, 11, 9),
(0, 98, 11, 9),
(1, 94, 11, 9),
(0, 94, 11, 9),
(0, 99, 11, 9),
(0, 96, 11, 9),
(0, 151, 12, 14),
(1, 148, 12, 14),
(0, 147, 12, 14),
(0, 164, 12, 15),
(0, 155, 12, 15),
(0, 161, 12, 15),
(1, 157, 12, 15),
(1, 164, 12, 15),
(1, 157, 12, 15),
(1, 16, 9, 2),
(1, 14, 9, 2),
(0, 17, 9, 2),
(0, 16, 9, 2),
(0, 19, 9, 2),
(1, 19, 9, 2),
(1, 19, 9, 2),
(1, 14, 9, 2),
(1, 38, 9, 4),
(0, 40, 9, 4),
(1, 43, 9, 4),
(0, 40, 13, 2),
(0, 42, 13, 2),
(0, 41, 13, 2),
(0, 37, 13, 2),
(1, 39, 13, 2),
(1, 47, 13, 5),
(1, 51, 13, 5),
(1, 52, 13, 5),
(1, 51, 13, 5),
(1, 114, 14, 11),
(1, 120, 14, 11),
(1, 117, 14, 11),
(1, 119, 14, 11),
(0, 114, 14, 11),
(0, 153, 14, 15),
(1, 147, 14, 15),
(1, 154, 14, 15),
(0, 148, 14, 15),
(1, 147, 14, 15),
(0, 112, 15, 11),
(0, 117, 15, 11),
(1, 112, 15, 11),
(1, 112, 15, 11),
(1, 119, 15, 11),
(1, 34, 15, 5),
(0, 35, 15, 5),
(0, 41, 15, 5),
(0, 38, 15, 5),
(0, 41, 15, 5)


--  ПЕРВОЕ ЗАДАНИЕ
--  Вывести список команд, упорядоченный по группам и алфавиту.


SELECT Comand_country AS 'Название'
		,Group_number AS 'Группа'
FROM Comands
ORDER BY 'Группа', 'Название'



-- Таблица всех голов

DROP TABLE IF EXISTS #goals; 
SELECT Match_id
		,Comand1_id
		,Comand2_id
		,(SELECT SUM(CAST(Point as tinyint)) FROM Goals WHERE Comand_id = Games.Comand1_id AND Match_id = Games.Match_id)
		+(SELECT COUNT(Point) FROM Goals WHERE Comand_id = Games.Comand2_id AND Point=0 AND Match_id = Games.Match_id) as Goals1
		,(SELECT SUM(CAST(Point as tinyint)) FROM Goals WHERE Comand_id = Games.Comand2_id AND Match_id = Games.Match_id)
		+(SELECT COUNT(Point) FROM Goals WHERE Comand_id = Games.Comand1_id AND Point=0 AND Match_id = Games.Match_id)as Goals2
INTO #goals
FROM Games



--  ВТОРОЕ ЗАДАНИЕ 
--  Вывести список матчей с результатами на определенную дату.

SELECT Stadion_name as 'Стадион'
		,CONVERT(char(5), Match_date, 108) as 'Время матча'
		,(SELECT Comand_country FROM Comands WHERE Comand_id = Comand1_id) +' - '+
		+(SELECT Comand_country FROM Comands WHERE Comand_id = Comand2_id) as 'Команды'
		,(SELECT CAST(Goals1 as varchar(5))+':'+CAST(Goals2 as varchar(5)) FROM #goals WHERE Match_id = Matches.Match_id) as 'Счёт'
FROM Matches,Stadions,Games
WHERE CAST(Match_date AS date) ='2018-06-24' 
		AND Stadions.Stadion_id = Matches.Stadion_id 
		AND Games.Match_id = Matches.Match_id 
ORDER BY [Время матча]




--  ТРЕТЬЕ ЗАДАНИЕ
--  Вывести список команд по группам (для определенной группы) упорядоченный по очкам на определенную дату.

-- Таблица победил\проиграл в матче 
DROP TABLE IF EXISTS #temp_points;
SELECT DISTINCT #goals.Match_id
		,Comand_id,
		(SELECT COUNT(Comand1_id) FROM #goals WHERE Comand1_id = Comand_id 
			AND #goals.Goals1 > #goals.Goals2 AND #goals.Match_id = Matches.Match_id)
		+(SELECT COUNT(Comand2_id) FROM #goals WHERE Comand2_id = Comand_id 
			AND #goals.Goals1 < #goals.Goals2 AND #goals.Match_id = Matches.Match_id) as Point
INTO #temp_points
FROM #goals, Matches, Comands
WHERE CAST(Match_date AS date) <='2018-06-30' 
	AND #goals.Match_id = Matches.Match_id 
	AND (#goals.Comand1_id = Comand_id 
	OR #goals.Comand2_id = Comand_id)


SELECT DISTINCT Comand_country as 'Команда'
		,Group_number as 'Группа'
		,(SELECT COUNT(Point)*3 FROM #temp_points WHERE Comand_id = Comands.Comand_id AND Point = 1)
		+(SELECT COUNT(Point) FROM #temp_points WHERE Comand_id = Comands.Comand_id AND Point = 0) as 'Очки'
FROM #temp_points, Comands,Matches
WHERE #temp_points.Comand_id = Comands.Comand_id 
	AND Group_number = 'A'
ORDER BY Очки DESC




--  ЧЕВЕРТОЕ ЗАДАНИЕ
--  Вывести итоговую таблицу по группам с очками, забитыми и пропущенными мячами

-- Та же самая таблица, но уже не для определенной даты
DROP TABLE IF EXISTS #temp_points;
SELECT DISTINCT #goals.Match_id
		,Comand_id
		,(SELECT COUNT(Comand1_id) FROM #goals WHERE Comand1_id = Comand_id 
			AND #goals.Goals1 > #goals.Goals2 AND #goals.Match_id = Matches.Match_id)+
		(SELECT COUNT(Comand2_id) FROM #goals WHERE Comand2_id = Comand_id 
			AND #goals.Goals1 < #goals.Goals2 AND #goals.Match_id = Matches.Match_id) as Point
INTO #temp_points
FROM #goals, Matches, Comands
WHERE #goals.Match_id = Matches.Match_id 
	AND (#goals.Comand1_id = Comand_id 
	OR #goals.Comand2_id = Comand_id)



SELECT DISTINCT Comand_country as 'Команда'
		,Group_number as 'Группа'
		,(SELECT COUNT(Point)*3 FROM #temp_points WHERE Comand_id = Comands.Comand_id AND Point = 1)
			+(SELECT COUNT(Point) FROM #temp_points WHERE Comand_id = Comands.Comand_id AND Point = 0) as 'Очки'
		,ISNULL((SELECT SUM(Goals1) FROM #goals WHERE Comand1_id = Comands.Comand_id),0)
			+ISNULL((SELECT SUM(Goals2) FROM #goals WHERE Comand2_id = Comands.Comand_id),0) as 'Забито'
		,ISNULL((SELECT SUM(Goals2) FROM #goals WHERE Comand1_id = Comands.Comand_id),0)
			+ISNULL((SELECT SUM(Goals1) FROM #goals WHERE Comand2_id = Comands.Comand_id),0) as 'Пропущено'

FROM #temp_points, Comands,Matches
WHERE #temp_points.Comand_id = Comands.Comand_id 
	-- AND Group_number = 'A'
ORDER BY Группа, Очки DESC
