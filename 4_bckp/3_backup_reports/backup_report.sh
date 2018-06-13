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
DEFPATH=/4csysmon/1_unix
NBUDATE=`date +"%m/%d/%Y"`
POLICY=ins01_ins_file
LOG=/4csysmon/4_bckp/2_backup_reports/backup_report.log
TMP=/4csysmon/1_unix/7_temp/backupreport.tmp

. $DEFPATH/6_misc/global_parameters.list

/usr/openv/netbackup/bin/bpclimagelist -client $HOST -ct 4 -s $NBUDATE 00:00:00 >> $LOG
/usr/openv/netbackup/bin/bpclimagelist -client $HOST -ct 0 -s $NBUDATE 00:00:00 |egrep -v 'Policy|--------' >> $LOG

## Mail daily backup report

/usr/openv/netbackup/bin/bpclimagelist -client $HOST -ct 4 -s $NBUDATE 00:00:00 >> $TMP
/usr/openv/netbackup/bin/bpclimagelist -client $HOST -ct 0 -s $NBUDATE 00:00:00 |egrep -v 'Policy|-------' >> $TMP

cat $TMP |mailx -r "$SYSMONMAIL" -s "Daily backup report for $HOST" $OSCARMAIL $SEKOLAMAIL $FIREMAIL $ORASUPPMAIL attie.duplessis@4cgroup.co.za $UXSUPPMAIL

rm $TMP
