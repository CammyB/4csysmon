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

DATE=`date +"%d%m%y"`
POLICY=ins01_pins_transit
SCHEDULE=UserArc
BACKUPSERVER=vclm5k02.vcl.corp
LOG=/4csysmon/4_bckp/2_db_archive/$DATE.log

## Backup command to back up DB tar.gz files from /transit_2/oracle/DataArchiveStaging/

/usr/openv/netbackup/bin/bparchive -p $POLICY -s $SCHEDULE -S $BACKUPSERVER -L $LOG /transit_2/oracle/DataArchiveStaging/*
