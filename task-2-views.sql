USE KN_301_Antipenkova
GO

SELECT * FROM AutosInfo
ORDER BY [Номер автомобиля]
GO

SELECT * FROM EntrancesInfo
ORDER BY [Время]
GO

SELECT [Номер автомобиля]
	,FORMAT(dbo.get_last_entry_time([Номер автомобиля],1),N'hh\:mm') AS 'Последнее время въезда'
	,FORMAT(dbo.get_last_entry_time([Номер автомобиля],0),N'hh\:mm') AS 'Последнее время выезда'
FROM AutosInfo
WHERE [Тип автомобиля]='Транзитный'
GO

SELECT [Тип автомобиля]
	,COUNT([Тип автомобиля]) AS 'Количество автомобилей типа'
FROM AutosInfo
GROUP BY [Тип автомобиля]
GO

SELECT [Пост]
	,SUM(CASE WHEN [Тип пересечения]='Въезд' THEN 1 ELSE 0 END)  AS 'Въехало'
	,SUM(CASE WHEN [Тип пересечения]='Выезд' THEN 1 ELSE 0 END) AS 'Выехало'
FROM EntrancesInfo
GROUP BY [Пост]
GO

