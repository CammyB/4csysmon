#!/bin/bash

## CHECK if ALREADY RUNNING

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
        echo "already running"
        exit 1
fi


## VARIABLES

LOGDES="oms___________status"
DEFPATH=/4csysmon/1_unix
DBDEFPATH=/4csysmon/2_db/5_oms_check
LOG=$DBDEFPATH/oms_check.log
MSG1=$DBDEFPATH/oms_check.msg1
TMP1=$DBDEFPATH/oms_check.tmp1

. $DEFPATH/6_misc/global_parameters.list

export ORACLE_SID=oem
ORAENV_ASK=NO
. oraenv

cd $DBDEFPATH


## DUMP OMS STATUS TO TEMP FILE
$ORACLE_BASE/product/middleware/oms/bin/emctl status oms > $TMP1

## CHECK IF ALL THREE OMS SERVICES ARE UP AND NOTIFY WHICH NOT, IF ANY
if [ `cat $TMP1 | grep -i down | wc -l` -gt 0 ]; then

	cat $TMP1 | grep -i down > $MSG1
	
printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  $GRP
  $OPP
  @@TECHNICIAN=4C Support - Oracle Standby Technician@@ 
  $CAT 
  $SCAT
  $ITEM
  @@PRIORITY=P1@@
  $URG\n\n" | cat - $MSG1  | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P1: OMS Component DOWN" $SERVICEDESKMAIL $ORASUPPMAIL $OSCARMAIL

	echo $DATE $HOSTLOGNAME P1 $LOGDES | cat - $MSG1  | tr '\n' ',' >> $LOG
	echo "" >> $LOG
	echo $DATE $HOSTLOGNAME P1 $LOGDES | cat - $MSG1  | tr '\n' ',' >> $MASTERLOG
	echo "" >> $MASTERLOG
	else

	 echo $DATE stamp >> $LOG

fi

## DELETE TEMP FILES
rm $TMP1 $MSG1
