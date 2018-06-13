#!/bin/bash

## Variables

#################################################
##Removing Oracle trace files older than 7 days##
#################################################

# Check if already running

SCRIPT=`basename $0`
echo $SCRIPT
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

LOGDES="ora_trc_file_removal"
DEFPATH=/4csysmon/1_unix
DBDEFPATH=/4csysmon/2_db/3_trace_file_removal
LOG=$DBDEFPATH/trace_file_removal.log
ORACLE_BASE=`su - oracle -c 'echo $ORACLE_BASE' | tail -1`
MSG1="Trace File Deletion abnormal exit"
MSG2="ORACLE_BASE could not be set"

. $DEFPATH/6_misc/global_parameters.list

## test if ORACLE_BASE is set

if [ `echo $ORACLE_BASE |wc -m` -lt 2 ]; then
printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  $GRP
  $OPP
  $TECH
  $CAT
  $SCAT
  $ITEM
  $PRI
  $URG\n
$LOGDES $MSG2" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: $LOGDES $MSG2" $SERVICEDESKMAIL
 
	echo $DATE $HOSTLOGNAME P2 $LOGDES $MSG2 >> $LOG
 	echo $DATE $HOSTLOGNAME P2 $LOGDES $MSG2 >> $MASTERLOG
#	echo $LOGDES $MSG2 | mailx -r "root@$HOST" -s "@4CSD@$HOST P2: $LOGDES $MSG2" $SERVICEDESKMAIL
	exit 1
else

## find trace files within ORACLE_BASE older than 7 days and remove

	find $ORACLE_BASE -type f -name "*.trc" -mtime +7 -exec rm {} \;
	RSTAT=`echo $?`

	if [ $RSTAT -gt 0 ]; then

# Log alerts to log file
printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  $GRP
  $OPP
  $TECH
  $CAT
  $SCAT
  $ITEM
  $PRI
  $URG\n
$LOGDES $MSG1" | mailx -s "@4CSD@$HOST P2: $LOGDES $MSG1" $SERVICEDESKMAIL

 		echo $DATE $HOSTLOGNAME P2 $LOGDES $MSG1 >> $LOG
 		echo $DATE $HOSTLOGNAME P2 $LOGDES $MSG1 >> $MASTERLOG
#		echo $LOGDES $MSG1 | mailx -r "root@$HOST" -s "@4CSD@$HOST P2: $LOGDES $MSG1" $SERVICEDESKMAIL

 		else 
			echo $DATE stamp >> $LOG

	fi
fi
