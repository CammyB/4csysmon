#!/bin/bash

######################
# Info and Changelog #
######################
# C. White, 2011

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
exit 1
fi

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="cpu___________status"
LOG=$DEFPATH/1_cpu/cpu_status.log
TMP1=$DEFPATH/7_temp/cpu_status.tmp1
MARKER=$DEFPATH/7_temp/cpu_status.tmp2

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

#Create the temporary files

touch $MARKER

# Gather CPU statuses

psrinfo |awk '{print $1," ",$2}' > $TMP1

# Loop round around all CPU statuses

for CPU in `cat $TMP1 |awk '{print $1}'`
do

# Alert us/log it, if the values are not equal to "on-line"

if [[ `cat $TMP1 |grep -w $CPU| awk '{print $2}'` != "on-line" ]];then
#	echo "$DATE CPU: $CPU down" | mailx -s "$HOST P1: CPU $CPU down" $UXSUPPMAIL
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
  @@PRIORITY=P1@@
  @@URGENCY=0 - Urgent@@\n\n
$LOGDES $CPU down" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P1: CPU $CPU down" $SERVICEDESKMAIL

#	(sh $SMS $UXSUPPSMS "$HOST P1: CPU $CPU down")
        echo $DATE $HOSTLOGNAME P1 $LOGDES CPU $CPU: down >> $LOG
	echo $DATE $HOSTLOGNAME P1 $LOGDES CPU $CPU: down >> $MASTERLOG
	echo $DATE >> $MARKER
fi
done

# If no errors are found create a time stamp in the log

        if [[ -z `cat $MARKER` ]];then
        echo $DATE stamp >> $LOG
        fi

# Remove temporary files

rm $TMP1 $MARKER
#echo "working" >> $MASTERLOG
