#!/bin/bash
#
###
#       This will check if the iPG services are availible
#       and will notify if it cannot.
#       This check require tcpping and a system list that look like this:
### Host list ################################################
#IP Address     Hostname        TCP port        Port Description
##############################################################
#Justice DC: (PROD)
#10.90.4.50     drcvodammipg01
###
#
# in cron like this:
# 0,15,30,45 * * * * /4csysmon/1_unix/3_io/2_network/3_iPG/ipg_services_check.sh >/dev/null 2>&1
#
WRKDIR="/4csysmon/1_unix/3_io/2_network/3_iPG"
LOGFLE="ipg_`date +"%Y_%m_%d"`.err"
MAILDIST="oscar.thiersen@4cgroup.co.za servicedesk@4cgroup.co.za Willie.Spence@4cgroup.co.za Application.Standby@4cgroup.co.za"
#
cd $WRKDIR
cat hosts.lst | grep -iv "#" | while read IPADDR HOSTNME PPORT DESCR
do
        STATUS=`./tcpping.pl $IPADDR $PPORT |awk -F" " '{print $NF}'`
        if [ $STATUS = "failed" ]
   then
      echo "$HOSTNME port $PPORT services $DESCR is DOWN" | mailx -s "$HOSTNME port $PPORT services $DESCR is DOWN" $MAILDIST
      echo "`date +"%Y-%m-%d %H:%M"` `hostname` $HOSTNME port $PPORT services $DESCR is DOWN" >> $LOGFLE
      echo "`date +"%Y-%m-%d %H:%M"` `hostname`___ P1 $HOSTNME port $PPORT services $DESCR is DOWN" >> /4csysmon/drcvodammdb03.log
   fi
done
echo "`date +"%Y-%m-%d %H:%M"` `hostname` Timestamp" >> $LOGFLE
### FIN ###
