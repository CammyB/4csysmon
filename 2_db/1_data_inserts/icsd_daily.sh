#!/bin/bash

WRKDIR=/4csysmon/2_db/1_data_inserts/
cd $WRKDIR
ORACLE_BASE=/app/oracle
export ORACLE_HOME=/app/oracle/product/11.2.0.4
export ORACLE_SID=pins
/app/oracle/product/11.2.0.4/bin/sqlplus -S '/as sysdba' @icsd_daily.sql
