select
         round((sum(decode(metric_name, 'Physical Read Bytes Per Sec' , value,0)))/1024,0)  rkbps,
         round((sum(decode(metric_name, 'Physical Read Total Bytes Per Sec' , value,0)))/1024,0) rtkbps,
         round((sum(decode(metric_name, 'Physical Read Total IO Requests Per Sec' , value,0 ))),2) rtops,
         round((sum(decode(metric_name, 'Physical Write Bytes Per Sec' , value,0 )))/1024,0)  wkbps,
         round((sum(decode(metric_name, 'Physical Write Total Bytes Per Sec' , value,0 )))/1024,0) wtkbps,
         round((sum(decode(metric_name, 'Physical Write Total IO Requests Per Sec', value,0 ))),2) wtops
     from     v$sysmetric
     where    metric_name in (
                    'Physical Read Total Bytes Per Sec' ,
                    'Physical Read Bytes Per Sec' ,
                    'Physical Write Bytes Per Sec' ,
                    'Physical Write Total Bytes Per Sec' ,
                    'Physical Write Total IO Requests Per Sec',
                    'Physical Read Total IO Requests Per Sec'
                    )
       and group_id=2
/
exit
