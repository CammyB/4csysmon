#!/bin/bash

####################################################################
#Script to check for any DRC Insight logs that are not being written to or updated          #
####################################################################

DEFPATH=/4csysmon/1_unix
. $DEFPATH/6_misc/global_parameters.list

PATH=/usr/bin:/bin
echo `date` >> /4csysmon/3_app/5_log_check/insight_log_check.log    #Date stamp for run log
echo "-----------------------------------------------------------------------------------------------------" >> /4csysmon/3_app/5_log_check/insight_log_check.log
touch /tmp/time_file                                            #File to compare log files' time stamps with
touch /4csysmon/3_app/5_log_check/insight_log_check.tmp
sleep 1800                                                       #Sleeps for 30 minutes
#sleep 0
#Finding files not newer than the time file created 20 minutes ago.
find /insight/log/ ! -newer /tmp/time_file -type f | egrep -v 'lck|zip|archive'  > /tmp/insight_logs_behind
for j in `ls -ltr /mis/log/sub_events/ | tail -1 | awk {'print $9'}`; do find /mis/log/sub_events/ ! -newer /tmp/time_file -type f -name $j >> /tmp/insight_logs_behind;done

#Notify App support if any log files were found that are older than time file
if      [ `cat /tmp/insight_logs_behind | wc -l` -gt 0 ]; then

        for eachlog in `cat /tmp/insight_logs_behind`; do

                        echo `date` $eachlog "behind" >> /4csysmon/3_app/5_log_check/insight_log_check.log
                        echo $eachlog >> /4csysmon/3_app/5_log_check/insight_log_check.tmp
#                        echo $eachlog | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2 iNsight Logs NOT updating" $SERVICEDESK #Servicedesk.VCL@4cgroup.co.za
printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  @@GROUP=Solutions@@
  $OPP
  @@TECHNICIAN=4C Support - Application Standby Technician@@
  @@CATEGORY=iNSight SLA@@
  @@SUBCATEGORY=ODS@@
  @@ITEM=BE App Down@@
  $PRI
  $URG\n\n
  $HOST\n
$eachlog" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2 iNsight Logs NOT updating" $SERVICEDESK

#/root/bin/sms.sh "243814444428" "Check insight DRC: Logs NOT updating"
        done
fi


rm /tmp/time_file
rm /tmp/insight_logs_behind
rm /4csysmon/3_app/5_log_check/insight_log_check.tmp
exit
