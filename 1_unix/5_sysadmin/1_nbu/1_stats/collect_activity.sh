#!/bin/bash
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi
#
# This script collects the backup history for the past 24 hours
#
#
PATH=$PATH:/usr/local/bin:/usr/openv/netbackup/bin:/usr/openv/volmgr/bin:/usr/openv/netbackup/bin/admincmd/
DEFPATH=/4csysmon/1_unix/5_sysadmin/1_nbu/1_stats
OUTPUT="$DEFPATH/activity.out"
OUTPUT_TMP="$DEFPATH/activity.out.tmp"
DRIVETYPE="IBM"
SITE="VCL"
FILEDATE=`date +"%Y%m%d%H%M%S"`
MAILOUTPUT=BCKP_ACT_"$FILEDATE"_"$SITE"

if [ -f activity.out ]; then
        rm $OUTPUT
fi

if [ -f activity.out.tmp ]; then
        rm $OUTPUT_TMP
fi

/usr/openv/netbackup/bin/admincmd/bperror -backstat -hoursago 24 | awk '{print $6"|"$5"|"$12"|"$14"|"$16"|"$19}' | sort +0 >> $OUTPUT_TMP
echo "Record Date|Site|Record Type|Start Time|End Time|Active Since|JOB ID|Media Server|Client|Policy|Schedule|Status Code|Size (KB)|Average throughput (KB/s)|Tape Device|Disk Device" > $OUTPUT

cat $OUTPUT_TMP | while read line;
do


TRYLOG=`echo $line | awk -F"|" '{print $1}'`

if [ -f /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t ]; then

        TMPEND=`cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep Ended |tail -1| awk '{print $2}'`
        NEWEND=`/usr/local/bin/date -d @$TMPEND +"%Y%m%d%H%M%S"`
        TMPACTSINCE=`cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep Started |tail -1| awk '{print $2}'`

                if [ `echo $TMPACTSINCE -eq 0` ]; then
                        NEWACTSINCE="19700101000000"
                        else
                                NEWACTSINCE=`/usr/local/bin/date -d @$TMPACTSINCE +"%Y%m%d%H%M%S"`
                fi
                        TMPSTART=`cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | /usr/sfw/bin/ggrep -A1 'Try 1' | tail -1 | awk '{print $2}'`
                        NEWSTART=`/usr/local/bin/date -d @$TMPSTART +"%Y%m%d%H%M%S"`


                if [ `cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep RESOURCE_GRANTED |grep -c $DRIVETYPE` -gt 0 ]; then
                        TAPEDEV=`cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep RESOURCE_GRANTED |grep $DRIVETYPE |head -1| awk '{print $3}'`
                        else
                                TAPEDEV=0
                fi

                if [ `cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep RESOURCE_GRANTED | grep -c Path` -gt 0 ]; then
                        DISKDEV=`cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep RESOURCE_GRANTED | grep Path | awk -F";" '{print $2}'`
                        else
                                DISKDEV="n/a"
                fi

                if [ `cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep -c KbPerSec` -gt 0 ]; then
                        KBPS=`cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep KbPerSec | head -1 |awk '{print $2}'`
                        KB=`cat /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t | grep Kilobytes | head -1 |awk '{print $2}'`

                        else
                                KBPS=0
                                KB=0
                fi
fi



echo "`echo $FILEDATE`|`echo $SITE`|`echo Activity`|`echo $NEWSTART`|`echo $NEWEND`|`echo $NEWACTSINCE `|`echo $line`|`echo $KB`|`echo $KBPS`|`echo $TAPEDEV`|`echo $DISKDEV`" >> $OUTPUT
done

cd $DEFPATH
cp $OUTPUT $MAILOUTPUT
#/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "$SITE NBU Activity Stats" laramy.starbuck@4cgroup.co.za
/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "Performance Monitor" monitor@4cgroup.co.za

rm $OUTPUT
rm $OUTPUT_TMP
