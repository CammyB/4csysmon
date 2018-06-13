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

LOGDES=ssh_______connection
HOSTL=$DEFPATH/6_misc/1_hostlists/site.list 
LOG=$DEFPATH/3_io/2_network/ssh_connection.log
LOGTMP=$DEFPATH/7_temp/ssh_connection.tmp

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

touch $LOGTMP

for x in `cat $HOSTL |grep -v "#"`
do
echo $x
        ssh orca@$x exit

# If ssh fails then notify

if [[ `echo $?` != 0 ]]; then
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
  $URG\n\n
SSH Connection lost to $x on $DATE from $HOST" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST $x P2: Connection lost" $SERVICEDESKMAIL

#	echo "SSH Connection lost to $x on $DATE from $HOST" | mailx -s "$x P2: Connection lost" $UXSUPPMAIL
#	(sh $SMS $UXSUPPSMS "$x P1: SSH Connection lost to $x on $DATE from $HOST")
	echo "$DATE $HOSTLOGNAME P1 $LOGDES SSH Connection lost to $x on $DATE from $HOST" >> $LOG
	echo "$DATE $HOSTLOGNAME P1 $LOGDES SSH Connection lost to $x on $DATE from $HOST" >> $MASTERLOG
	echo $x >> $LOGTMP
fi
done

# If no errors were logged then echo a time stamp to the alert log

if [[ -z `cat $LOGTMP` ]];then
echo $DATE stamp >> $LOG
fi

rm $LOGTMP
