select METRIC_NAME,VALUE from SYS.V_$SYSMETRIC where METRIC_NAME IN ('Database CPU Time Ratio','Database Wait Time Ratio') AND INTSIZE_CSEC =(select max(INTSIZE_CSEC) from SYS.V_$SYSMETRIC);
exit
