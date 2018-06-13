#!/bin/bash

# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 1 ]; then
	echo "already running"
	exit 1
fi

#############
# Variables #
#############

DATE=`date +"%d%m%y"`
POLICY=ins01_ins_file
SCHEDULE=UserArc
BACKUPSERVER=vclm5k02.vcl.corp
LOG=/4csysmon/4_bckp/2_insight_archive/$DATE.log

## Backup command to back up insight tar files from /insight/backup

/usr/openv/netbackup/bin/bparchive -p $POLICY -s $SCHEDULE -S $BACKUPSERVER -L $LOG /insight/backup/*.tar
