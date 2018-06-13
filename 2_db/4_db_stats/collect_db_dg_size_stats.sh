#!/bin/bash

## CHECK if ALREADY RUNNING

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
        echo "already running"
        exit 1
fi


## VARIABLES

DEFPATH=/4csysmon/1_unix
DBDEFPATH=/4csysmon/2_db/4_db_stats
SITE=site
FILENAME=$DBDEFPATH/DB_DG_Usage_`date +"%Y%m%d%H%M%S"`_$SITE
LOG=$DBDEFPATH/collect_db_dg_size_stats.log
TMP1=$DBDEFPATH/DB_DG_Usage.tmp1
TMP2=$DBDEFPATH/DB_DG_Usage.tmp2
export ORACLE_SID=oem
#export ORACLE_HOME=
#ORAENV_ASK=NO
#. oraenv

cd $DBDEFPATH


## EXECUTE SQL SCRIPT
$ORACLE_HOME/bin/sqlplus -S '/as sysdba' @dg_usage.sql

## CALCULATE USED SPACE
awk 'BEGIN{print}NR>0{print $1"|"$2"|"$3"|"$4"|"$5"|"$6"|"$6-$7"|"$7}' $TMP1 | grep $SITE > $TMP2


## REPLACE NULL COLUMNS WITH 0
awk 'BEGIN { FS = OFS = "|" } { for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = 0 }; 1' $TMP2 > $FILENAME

## ADD HEADING LINE TO OUTPUT FILE
sed -i '1s/^/RECORD_DATE|SITE|RECORD_TYPE|TARGET_NAME|DISKGROUP|ASSIGNED_MB|USED_MB|USABLE_FREE_MB\n/' $FILENAME


## REMOVE TEMP FILES
rm $TMP1 $TMP2

## MAKE OUTPUT FILE ACCESSIBLE TO INSIGHT MEDIATION
chmod 777 $FILENAME

### FIN ###
