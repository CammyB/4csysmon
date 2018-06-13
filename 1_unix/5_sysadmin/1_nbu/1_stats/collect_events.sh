#!/bin/bash
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi
#
# This script collects the error events for the past hour
#
#
PATH=$PATH:/usr/local/bin:/usr/openv/netbackup/bin:/usr/openv/volmgr/bin:/usr/openv/netbackup/bin/admincmd/
DEFPATH=/4csysmon/1_unix/5_sysadmin/1_nbu/1_stats
OUTPUT="$DEFPATH/events.out"
OUTPUT_TMP="$DEFPATH/events.out.tmp"

if [ -f events.out ]; then
        rm $OUTPUT
fi

if [ -f events.out.tmp ]; then
        rm $OUTPUT_TMP
fi

SITE="VCL"
FILEDATE=`date +"%Y%m%d%H%M%S"`
MAILOUTPUT=BCKP_EVENTS_"$FILEDATE"_"$SITE"


/usr/openv/netbackup/bin/admincmd/bperror -problems -hoursago 1 >> $OUTPUT_TMP
echo "RecordDate|Site|Record Type|Policy|Media Server|Client|Description" > $OUTPUT

cat $OUTPUT_TMP | while read line;
do

        OLDDATE=`echo $line | awk {'print $1'}`
        NEWDATE=`/usr/local/bin/date -d @$OLDDATE +"%Y%m%d%H%M%S"`

        MEDIAS=`echo $line | awk {'print $5'}`
        CLIENT=`echo $line | awk {'print $9'}`
        DESCR=`echo $line | awk '{$1="";$2="";$3="";$4="";$5="";$6="";$7="";$8="";$9=""; print $0}'`
        TRYLOG=`echo $line | awk {'print $6'}`
        if [ -f /usr/openv/netbackup/db/jobs/trylogs/$TRYLOG.t ]; then
                POL=`get_id $TRYLOG | grep POLICY | awk -F. '{print  $4}' | head -1`
                else
                        POL=0
        fi


        echo "`echo $NEWDATE`|`echo $SITE`|`echo events`|`echo $POL`|`echo $MEDIAS`|`echo $CLIENT`|`echo $DESCR`" >> $OUTPUT

done

rm $OUTPUT_TMP
cd $DEFPATH
cp $OUTPUT $MAILOUTPUT
#/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "$SITE NBU Events Stats" laramy.starbuck@4cgroup.co.za
/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "Performance Monitor" monitor@4cgroup.co.za

rm $OUTPUT
