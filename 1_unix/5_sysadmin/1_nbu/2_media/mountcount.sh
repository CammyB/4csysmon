#! /bin/bash
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi
#
# This script calculates backup policy totals for the current month (1st to date)
#
# CRON Entry:
# 0 6 * * * /4csysmon/1_unix/5_sysadmin/1_nbu/2_media/mountcount.sh >/dev/null 2>&1
#
PATH=$PATH:/usr/local/bin:/usr/openv/netbackup/bin:/usr/openv/netbackup/bin/goodies:/usr/openv/volmgr/bin:/usr/openv/netbackup/bin/admincmd/
DEFPATH=/4csysmon/1_unix/5_sysadmin/1_nbu/2_media
MEDIALIST_TMP=$DEFPATH/medialist.tmp
MOUNTCOUNT_TMP=$DEFPATH/mountcount.tmp
MOUNTCOUNT=$DEFPATH/mountcount.out
LOGDIR=$DEFPATH/mountcount_logs
SITE=VCL


. /4csysmon/1_unix/6_misc/global_parameters.list


/usr/openv/netbackup/bin/goodies/available_media | egrep 'TLD|NONE' |grep -v CLN | awk {'print $1'} > $MEDIALIST_TMP


cat $MEDIALIST_TMP | while read TAPE;
do
        echo -n $TAPE >> $MOUNTCOUNT_TMP;
        vmquery -m $TAPE | grep 'number of mounts' | awk -F":" {'print $2'} >> $MOUNTCOUNT_TMP;
done

sort -k2,2nr $MOUNTCOUNT_TMP > $MOUNTCOUNT



uuencode $MOUNTCOUNT `date +"%Y-%m-%d"`_mountcount.txt | mailx -s "$SITE NBU Media Mount Count" $UXSUPPMAIL

mv $MOUNTCOUNT $LOGDIR/`date +"%Y-%m-%d"`_mountcount.txt
rm $MOUNTCOUNT_TMP
#rm $MOUNTCOUNT
rm $MEDIALIST_TMP
