#!/bin/bash

#############
#CRON ENTRY #
#############
# 0,30 * * * * /4csysmon/1_unix/5_sysadmin/cron_queue.sh > /dev/null 2>&1

#
######################
# Info and Changelog #
######################
# L. Starbuck, 2015

# Check if already running

SCRIPT=`basename $0`
echo $SCRIPT
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
echo "already running"
exit 1
fi

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="__cron__________queue"
LOG=$DEFPATH/5_sysadmin/cron_queue.log
ORIGLOG=/var/cron/log        #Path to the cron log file
MSG="cron queue limit reached"

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

# Check CRON LOG for entries stating max queue has been met

Q_LIM_REACHED=`tail -50 $ORIGLOG | grep 'queue max run limit reached' | tail -1`

if [ `echo ${#Q_LIM_REACHED}` -gt 0 ]; then
        Q_TYPE=`echo $Q_LIM_REACHED |awk {'print $2'}`
        echo "$DATE" "$HOSTLOGNAME" P2 "$LOGDES" "$Q_LIM_REACHED" >> $LOG
        echo "$DATE" "$HOSTLOGNAME" P2 "$LOGDES" "$Q_LIM_REACHED" >> $MASTERLOG
        cat $SDTEMP | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: Type $Q_TYPE $MSG" $SERVICEDESKMAIL

else
         echo $DATE stamp >> $LOG
fi
