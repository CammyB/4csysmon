#!/bin/bash
#
###
#       This will check if the Thales HSM will respond to requests
#       and will notify if it cannot.
#       This check require tcpping and a system list (HSM.lst) that look like this:
### Thales HSM's ###################
#IP Address     Hostname
####################################
#10.90.4.21      Justice_HSM
#10.90.104.21   Sitrix_DR_HSM
#10.90.4.20      Justice_Test_HSM
###
#
WRKDIR="/4csysmon/1_unix/3_io/2_network/2_thales"
LOGFLE="thales_`date +"%Y_%m_%d"`.err"
MAILDIST="oscar.thiersen@4cgroup.co.za servicedesk@4cgroup.co.za Unix.Standby@4cgroup.co.za"
#
cd $WRKDIR
cat HSM.lst | grep -iv "#" | while read IPADDR HOSTNME
do
        STATUS=`./tcpping.pl $IPADDR 1500 |awk -F" " '{print $NF}'`
        if [ $STATUS = "failed" ]
   then
      echo "$HOSTNME is dead" | mailx -s "`hostname` $HOSTNME is dead" $MAILDIST
      echo "`date +"%Y-%m-%d %H:%M"` `hostname` $HOSTNME is dead" >> $LOGFLE
      echo "`date +"%Y-%m-%d %H:%M"` `hostname`___ P1 $HOSTNME is dead" >> /4csysmon/drcvodammdb03.log
   fi
done
echo "`date +"%Y-%m-%d %H:%M"` `hostname` Timestamp" >> $LOGFLE
### FIN ###
