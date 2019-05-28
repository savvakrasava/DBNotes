--Выдать типы сегментов в БД, общий объем памяти на диске для каждого типа и долю числа типов с равным или меньшим общим объемом памяти
SELECT segment_type, 
      SUM(bytes/1024/1024) Mbytes,
      CUME_DIST() OVER (ORDER BY SUM(bytes/1024/1024 )) Mbytes_percentile
      FROM sys.dba_segments
      GROUP BY segment_type order by 2 desc;
--Отобрать 40% "наиболее расточительных" по дисковой памяти типов:
SELECT * 
FROM
(SELECT segment_type, 
SUM(bytes/1024/1024) Mbytes,
CUME_DIST() OVER (ORDER BY SUM(bytes)) bytes_percentile
FROM sys.dba_segments
GROUP BY segment_type)
WHERE bytes_percentile >= 0.5;


--Отобрать пользователей, занимающих первые пять мест по расходованию памяти среди "наиболее расточительных" типов сегментов:
SELECT * 
FROM
(
SELECT owner,
        SUM(bytes/1024/1024) Mbytes,
        RANK() OVER(ORDER BY SUM(bytes) DESC) bytes_rank
FROM sys.dba_segments
WHERE segment_type IN
      (SELECT segment_type
        FROM
           (SELECT segment_type, 
                SUM(bytes) bytes,
                CUME_DIST() OVER (ORDER BY SUM(bytes)) bytes_percentile
                FROM sys.dba_segments
                GROUP BY segment_type)
        WHERE bytes_percentile >= 0.5)
GROUP BY owner
)
WHERE bytes_rank <=5
;


--Список переключений журнальных файлов хранится в динамической таблице v$loghist.
--exec :treshold := 30
SELECT 
start_time,
end_time,
ROUND((end_time - start_time)*24*60, 2) delta_min,
switches,
switches / ((end_time - start_time)*24*60) per_minute
FROM
(
SELECT
MIN(time_stamp) start_time,
MAX(time_stamp) end_time,
count (*) switches
FROM
(
SELECT time_stamp, freq10, more,
SUM(ABS(indicator)) OVER (ORDER BY time_stamp) part
FROM
(
SELECT time_stamp, freq10,
SIGN(freq10 - :treshold - 0.5) more,
SIGN(freq10 - :treshold - 0.5) - LAG(SIGN(freq10 - :treshold - 0.5), 1)
OVER (ORDER BY time_stamp) indicator
FROM
(
SELECT first_time time_stamp,
GREATEST(
COUNT(*)
OVER (ORDER BY first_time
RANGE BETWEEN CURRENT ROW AND INTERVAL '10' MINUTE FOLLOWING)
,
COUNT(*)
OVER (ORDER BY first_time
RANGE BETWEEN INTERVAL '10' MINUTE PRECEDING AND CURRENT ROW)
) freq10
FROM v$loghist
) /* frequency table */
) /* frequency treshold overcome table */
) /* transient partitioned table */
WHERE more > 0
GROUP BY part
)
WHERE (end_time - start_time)*24*60 > 0 
;

--max_tables

SELECT
   owner, 
   table_name, 
   TRUNC(sum(bytes)/1024/1024) Meg,
   ROUND( ratio_to_report( sum(bytes) ) over () * 100) Percent
FROM
(SELECT segment_name table_name, owner, bytes
 FROM dba_segments
 WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
 UNION ALL
 SELECT i.table_name, i.owner, s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')
WHERE owner in UPPER('&owner')
GROUP BY table_name, owner
HAVING SUM(bytes)/1024/1024 > 10  /* Ignore really small tables */
ORDER BY SUM(bytes) desc
;
