#!/bin/ksh
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

#
#**************************************************************
#  Check if Shadbase is up . . . .
#**************************************************************
#
shadbase_uptime='Shadbase Replication is up'
shadbase_up=`ps -ef|grep sboracle|grep -v grep|wc -l`;
shadbase_num=`expr $shadbase_up`
log_file=/4csysmon/3_app/2_shadbase/shadbase_check.log
date=`date`
if [ $shadbase_num -lt 5 ]
 then

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
  $URG\n
Shadbase replication is NOT up" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: Check Shadbase processes" $SERVICEDESKMAIL

#        echo "Shadbase replication is NOT up."|mailx -s "Check Shadbase processes" unixsupport@4cit.co.za orasupport@4cit.co.za jacques.vanzyl@4cgroup.co.za Sekoala.Tsukulu@Vodacom.co.ls malekhase.moea@vodacom.co.ls
 else
        echo "$date ${shadbase_uptime}." >> $log_file
fi

#**************************************************************
#  Check if Shadbase is loading...
#**************************************************************

#shadbase_up=`ps -ef|grep sboracle|grep -v grep|grep -v grep|wc -l`;
#shadbase_uptime=`/app/oracle/shadbase/v3940r3/bin/sbmon/ <<EOFF
#list
#exit
#<<EOFF`
#shadbase_num=`expr $shadbase_up`
#if [ $shadbase_num -lt 22 ]
# then echo "\nShadbase is NOT up processing.\n"
# else echo "\nShadbase ${shadbase_uptime}.\n"
#fi
