#!/bin/bash
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

#
# This scripts checks for any 4csysmon cron jobs that are hashed out

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="__4csysmon__disabled"
LOG=$DEFPATH/5_sysadmin/4csysmon_disabled.log
TMP=$DEFPATH/7_temp/4csysmon_disabled.tmp

. $DEFPATH/6_misc/global_parameters.list
if [ `cat /etc/*release | grep -ci linux` -gt 0 ]; then
	SEARCHPATH="/var/spool/cron/"
else
	SEARCHPATH="/var/spool/cron/crontabs/"
fi

################
# Main Program #
################

for CRON in `find $SEARCHPATH -type f`; 
do 

cat $CRON | grep /4csysmon | grep "^#" > $TMP

if [ `cat $CRON| grep /4csysmon | grep "^#" | wc -l` -gt 0 ];then 

	cat $SDTEMP $TMP | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: 4CSysmon Entries DISABLED" $SERVICEDESKMAIL
	cat $TMP |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P2","'"$LOGDES"'","'"$ZONE"'",$0}' >> $LOG
        cat $TMP |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P2","'"$LOGDES"'","'"$ZONE"'",$0}' >> $MASTERLOG
else
        echo $DATE stamp >> $LOG
fi
rm $TMP
done
