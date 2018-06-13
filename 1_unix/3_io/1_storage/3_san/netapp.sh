#!/bin/bash
#
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

###############################################################################################
# Get the NetApp Log's
# Need the controler list file (netapp_cntrl.list) with entries like this:
# Hostname      IP Address
#TZVODANETAPP01  10.10.94.17
#
#
# Put it in cron
#0 7,22 * * * /4csysmon/1_unix/3_io/1_storage/3_netapp_storage/netapp_mess.sh > /dev/null 2>&1
#
###############################################################################################
WRKDIR=/4csysmon/1_unix/3_io/1_storage/3_netapp_storage
CNTLR_LIST=netapp_cntrl.list
RCMD="/usr/bin/rsh -n"
LOG="`date "+%d-%m-%Y"`.mess"
ERRLOG=NetApp_Storage.err
#
###############################################################################################
cd $WRKDIR
cat $WRKDIR/$CNTLR_LIST | grep -v "#" | while read HOST IP
do
        if [ -f ${HOST}_$LOG ]
                then
                        $RCMD $IP rdfile /etc/messages > tmp_mess
                        diff ${HOST}_$LOG tmp_mess |grep -i "> " |sed 's/> //' >> "${HOST}_$LOG"
                else
                        $RCMD $IP rdfile /etc/messages > "${HOST}_$LOG"
        fi
done
rm tmp_mess
#
sleep 60
cat $CNTLR_LIST | grep -v "#" | while read HOST IP
do
        #echo "${HOST}_$LOG"
        cat "${HOST}_$LOG" |egrep -i 'error|Unable to grow|lun.offline|CRITICAL|Service Processor' > tmp_err
        diff "${HOST}_$LOG" tmp_err |grep -i "> " |sed 's/> //' >> $ERRLOG
done
rm tmp_err
#find $WRKDIR -newer *$LOG | grep -i $ERRLOG
#       COUNT=`tail -50 $FLE  |grep -i "state to STOPPED"|wc -l`
#       if [ $COUNT -ge  1 ]
#               then
#                       echo "`date +"%m/%d/%y %H:%M:%S"` ___`hostname`__ P3 APP______$FLE stopped" >> $MONLOG_FLE
#               else
#                       echo $FLE $FLETME >> tmp2.txt
#       fi
#done
### FIN ###

