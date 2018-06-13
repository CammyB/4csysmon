#!/bin/bash
#
# This script checks network connectivity duplexity and speed
#
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

DEFPATH=/4csysmon/1_unix

LOGDES=nic___________speed
LOG=$DEFPATH/3_io/2_network/nic_speed.log
#SPEED=`dladm show-dev | grep "link: up" |awk {'print $5'} | grep -v 1000 | wc -l`
SPEED=`dladm show-phys | grep "up" |grep -v usb|awk {'print $4'} | grep -v 1000 | wc -l`
#DUP=`dladm show-dev | grep "link: up" |awk {'print $8'} | grep -v full | wc -l`
DUP=`dladm show-phys | grep "up" |grep -v usb|awk {'print $5'} | grep -v full | wc -l`

. $DEFPATH/6_misc/global_parameters.list


################
# Main Program #
################


if [ $SPEED -gt 0 ]; then
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
NIC Speed not connected @ Gbit on $HOST" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: NIC Speed not connected @ Gbit" $SERVICEDESKMAIL

        echo "$DATE $HOSTLOGNAME P3 $LOGDES NIC Speed not connected @ Gbit on $DATE from $HOST" >> $LOG
        echo "$DATE $HOSTLOGNAME P3 $LOGDES NIC Speed not connected @ Gbit on $DATE from $HOST" >> $MASTERLOG

#        echo "$DATE $HOSTLOGNAME P3 $LOGDES NIC Speed not connected @ Gbit on $DATE from $HOST" | mailx unixsupport@4cit.co.za
fi

if [ $DUP -gt 0 ]; then
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
NIC Duplexity not connected @ Full on $HOST" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: NIC Duplexity not connected @ Full" $SERVICEDESKMAIL

        echo "$DATE $HOSTLOGNAME P3 $LOGDES NIC Duplexity not connected @ Full on $DATE from $HOST" >> $LOG
        echo "$DATE $HOSTLOGNAME P3 $LOGDES NIC Duplexity not connected @ Full on $DATE from $HOST" >> $MASTERLOG
#        echo "$DATE $HOSTLOGNAME P3 $LOGDES NIC Duplexity not connected @ Full on $DATE from $HOST" | mailx unixsupport@4cit.co.za
fi
