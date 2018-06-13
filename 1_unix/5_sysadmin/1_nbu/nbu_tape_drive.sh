#!/bin/bash

#######################
# Universal variables #
#######################
DEFPATH=/4csysmon/1_unix

LOGDES="cpu____________usage"
LOG=$DEFPATH/5_sysadmin/1_nbu/nbu_tapedrive.log
TMP1=$DEFPATH/5_sysadmin/1_nbu/nbu_tapedrive.tmp1
LST=$DEFPATH/5_sysadmin/1_nbu/nbu_tapedrive.list

. $DEFPATH/6_misc/global_parameters.list


DATE=`date '+%D %T'`


/usr/openv/volmgr/bin/tpconfig -l | egrep -i 'down|avr'  > $TMP
cat $TMP |awk '{print $9}' > $LST

TOTAL=`cat $TMP | wc -l | awk '{ print $1 }'`

if [ $TOTAL -gt 0 ]
then

MSG="$TOTAL tape drives down"
        cat $SDTEMP $LST |mailx -s "@4CSD@$HOST $MSG" $SERVICEDESKMAIL
        echo $DATE $HOST: tapedrive down `cat $LST` >> $LOG
	echo $DATE $HOST: tapedrive down `cat $LST` >> $MASTERLOG
else
        echo $DATE stamp >> $LOG
fi
rm $TMP $LST
