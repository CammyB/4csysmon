#!/bin/bash
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

#############
# Variables #
#############

BASE_DIR=/4csysmon/4_bckp/1_db_archive
BACKUPLOG=$BASE_DIR`date +"%d%m%y"`.log
LOG=$BASE_DIR/backup_failures.log
LOGDES="db_arc_bkup_failure"

. /4csysmon/1_unix/6_misc/global_parameters.list

################
# Main Program #
################

## Check if backup ran and produced a log

ls $BACKUPLOG
if [[ `echo $?` != 0 ]]; then
        echo "Insight_DB_Archive backup log was not generated. Check whether backup ran"  | mailx -r "$SYSMONMAIL" -s "$HOST P1: Check Insight_DB_Archive backup" $FIREMAIL $UXSUPPMAIL
        echo $DATE $HOSTLOGNAME P1 $LOGDES Insight_DB_Archive backup log not generated >> $LOG
        echo $DATE $HOSTLOGNAME P1 $LOGDES Insight_DB_Archive backup log not generated >> $MASTERLOG
        exit
fi

## Check if backup is waiting in queue.

tail $BACKUPLOG |grep queue
if [[ `echo $?` = 0 ]]; then
        echo "Insight_DB_Archive backup is queued. Please check."  | mailx -r $SYSMONMAIL -s "$HOST P1: Insight_DB_Archive backup queued" $FIREMAIL $UXSUPPMAIL
        echo $DATE $HOSTLOGNAME P1 $LOGDES Insight_DB_Archive backup is queued >> $LOG
        echo $DATE $HOSTLOGNAME P1 $LOGDES Insight_DB_Archive backup is queued >> $MASTERLOG
        exit
fi

## Check if backup was successful

if [[ `cat $BACKUPLOG |grep "Server status" |awk '{print $7}'` != 0 ]]; then
        echo "Insight_DB_Archive backup failed to complete successfully. Please check the log."  | mailx -r $SYSMONMAIL -s "$HOST P1: Insight_DB_Archive backup failed" $ORASUPPMAIL $FIREMAIL $UXSUPPMAIL
        echo $DATE $HOSTLOGNAME P1 $LOGDES Insight_DB_Archive backup failed >> $LOG
        echo $DATE $HOSTLOGNAME P1 $LOGDES Insight_DB_Archive backup failed >> $MASTERLOG
else
         echo $DATE stamp >> $LO
