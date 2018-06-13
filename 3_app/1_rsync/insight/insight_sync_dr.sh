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

DEFPATH=/4csysmon/3_app/

DR=insight@10.209.0.20
EXCLUDE=$DEFPATH/1_rsync/insight/insight_sync_dr.exclude
LOG=$DEFPATH/1_rsync/insight/insight_sync_dr.log
FSLIST=$DEFPATH/1_rsync/insight/insight_sync_dr.include
LOGTMP=/4csysmon/1_unix/7_temp/insight_sync_dr.tmp
OPTS="-avzlrpt --rsync-path=/usr/bin/rsync -e "/usr/bin/ssh" --timeout=8000 --exclude-from=$EXCLUDE --delete-before"
CMD=`which rsync`
. /4csysmon/1_unix/6_misc/global_parameters.list

################
# Main Program #
################

#Create the temporary files

touch $LOGTMP

#Sync Insight application data to DR


for DIR in `cat $FSLIST`
do

$CMD $OPTS ${DIR} $DR:${DIR}

# Find status code

RESULT=$?

# If the error is any of these 2 then change the exit code to 0

        if [ $RESULT -eq "24" ] || [ $RESULT -eq "23" ];then
        RESULT=0
        fi

# If the status code is not 0 then print an error to the log file

if [ $RESULT != '0' ]; then
        echo $DATE $HOST: error $RESULT occured syncing $DIR >> $LOG
        echo $DATE $HOST: error $RESULT occured syncing $DIR >> $LOGTMP
fi
done

# If there are any errors printed in LOGTMP then alert

if [ -s $LOGTMP ]; then
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
  $URG\n\n" | cat - $LOGTEMP | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: Check rsync" $SERVICEDESKMAIL

#        cat $LOGTMP | mailx -s "$HOST Check rsync" $SERVICEDESKMAIL
else
        echo $DATE stamp >> $LOG
fi

rm $LOGTMP
