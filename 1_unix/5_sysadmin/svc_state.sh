#!/bin/bash
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

#
# This script checks services in maintenance
#
DEFPATH=/4csysmon/1_unix

LOGDES="svc____________state"
LOG=$DEFPATH/5_sysadmin/svc_state.log
SVC_MAINTENANCE=`svcs -a | grep -i maintenance |  wc -l`
MSG="service in maintenance state"
. $DEFPATH/6_misc/global_parameters.list


################
# Main Program #
################


if [ $SVC_MAINTENANCE -gt 0 ]; then
        echo "$DATE $HOSTLOGNAME P3 $LOGDES $MSG $DATE from $HOST" >> $LOG
        echo "$DATE $HOSTLOGNAME P3 $LOGDES $MSG $DATE from $HOST" >> $MASTERLOG
printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  $GRP
  $OPP
  $TECH
  $CAT
  @@SUBCATEGORY=Preventative Maintenance@@
  $ITEM
  $PRI
  $URG\n
$LOGDES $MSG" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: $MSG" $SERVICEDESKMAIL

fi
