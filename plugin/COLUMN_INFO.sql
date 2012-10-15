set nocount on

SELECT 
	 C.name AS 'COLUMN'
	,T.name AS 'TYPE'
	,(CASE 
		WHEN T.name IN('datetime', 'smalldatetime', 'bit', 'int', 'smallint', 'tinyint') THEN '-'
		WHEN T.name IN('decimal') THEN CONVERT(varchar, C.precision) + ',' + CONVERT(varchar, C.scale)
		ELSE CONVERT(char(10), C.max_length)
	  END) AS 'LENGTH'
	,(CASE WHEN I.is_primary_key = 1 THEN 'PK' ELSE '-' END ) AS 'PK'
	,(CASE WHEN FC.parent_column_id IS NOT NULL THEN 'FK' ELSE '-' END ) AS 'FK'
	,(CASE C.is_nullable WHEN 1 THEN 'NULL' ELSE 'NOT NULL' END) AS 'NULL'
	,(CASE WHEN (I.is_primary_key IS NULL OR I.is_primary_key = 0) AND I.is_unique = 1 THEN 'UQ' ELSE '-' END) AS 'UQ'
FROM Sys.Columns C
INNER JOIN Sys.Types T
	ON C.system_type_id = T.system_type_id
	AND C.user_type_id = T.user_type_id
LEFT OUTER JOIN Sys.Index_columns IC
	ON C.object_id = IC.object_id
	AND C.column_id = IC.column_id
LEFT OUTER JOIN Sys.Indexes I
	ON C.object_id = I.object_id
	AND IC.index_id = I.index_id
LEFT OUTER JOIN Sys.foreign_key_columns FC
	ON C.object_id = FC.parent_object_id
	AND C.column_id = FC.parent_column_id
WHERE C.object_id = object_id('$(TBL)')
ORDER BY C.column_id
