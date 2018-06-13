col target_name format a40
col diskgroup format a25
col value format 999999
col record_type format a11
set pages 250
set lines 250
set heading off
spool DB_DG_Usage.tmp1
SELECT TO_CHAR(sysdate, 'YYYYMMDDhhmmss') as "RECORD_DATE",'site' as SITE,'DG_Usage' as RECORD_TYPE,target_name,
         diskgroup,
         MAX (DECODE (seq, 9, ceil(VALUE))) ASSIGNED_MB,
         MAX (DECODE (seq, 8, ceil(VALUE))) USABLE_FREE_MB
    FROM (SELECT target_name,
                 key_value diskgroup,
                 VALUE,
                 metric_column,
                 ROW_NUMBER ()
                 OVER (PARTITION BY target_name, key_value
                       ORDER BY metric_column)
                    AS seq
            FROM MGMT$METRIC_CURRENT
          WHERE        target_type in ('osm_instance','osm_cluster')
                   AND metric_column IN
                          ('rebalInProgress',
                           'free_mb',
                           'usable_file_mb',
                           'type',
                           'computedImbalance',
                           'usable_total_mb',
                           'percent_used','diskCnt')
                OR (    metric_column = 'total_mb'
                    AND metric_name = 'DiskGroup_Usage'))
GROUP BY target_name, diskgroup
order by 4,5;
spool off
exit

