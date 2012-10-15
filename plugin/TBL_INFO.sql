set nocount on

SELECT T.name
FROM  Sys.Tables T
WHERE T.type = 'U'
ORDER BY T.name