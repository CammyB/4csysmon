#!/bin/bash

# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

######################
# Info and Changelog #
######################
# C. White, 2011

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="tapedrive_____status"
LOG=$DEFPATH/3_io/1_storage/2_tape/tapedrive_status.log
TMP=$DEFPATH/7_temp/tapedrive.tmp
LST=$DEFPATH/7_temp/tapedrive.list

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

touch $TMP $TMP $LST

# To exclude a tape drive just use 'grep -v' on the vmoprcmd output

# Pipe the output of the vmoprcmd cmd excluding all active and tld statuses to a file

vmoprcmd | grep $HOST |grep "/dev/" |egrep -i "DOWN|AVR" |awk '{print $2," ",$3}' > $TMP

TOTAL=`cat $TMP | wc -l | awk '{ print $1 }'`

if [ $TOTAL -gt 0 ]; then

cat "$SDTEMP" "$TMP" |mailx -r "$SYSMONMAIL" -s "@4CSD$HOST P2: $TOTAL tape drives faulted" $SERVICEDESKMAIL

#cat $TMP |mailx -s "$HOST P2: $TOTAL tape drives faulted" $UXSUPPMAIL
#(sh $SMS $UXSUPPSMS "$HOST P2: $TOTAL tape drives faulted")

	for i in `cat $TMP |awk '{print $1}'`
	do
	STAT=`grep $i $TMP |awk '{print $2}'`
	echo $DATE $HOSTLOGNAME P2 $LOGDES $i $STAT >> $LOG
	echo $DATE $HOSTLOGNAME P2 $LOGDES $i $STAT >> $MASTERLOG
	done

else
        echo $DATE stamp >> $LOG
fi

rm $TMP $LST
