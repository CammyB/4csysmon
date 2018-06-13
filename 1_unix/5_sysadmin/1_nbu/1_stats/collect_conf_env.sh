#!/bin/bash

# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi
#
# This script collects the the backup environment configuration detail
#
#
PATH=$PATH:/usr/local/bin:/usr/openv/netbackup/bin:/usr/openv/volmgr/bin:/usr/openv/netbackup/bin/admincmd/
DEFPATH=/4csysmon/1_unix/5_sysadmin/1_nbu/1_stats
OUTPUT="$DEFPATH/cfg_env.out"

if [ -f cfg_env.out ]; then
        rm $OUTPUT
fi

SITE="VCL"
DATE=`date +"%Y%m%d%H%M%S"`
FILEDATE=`date +"%Y%m%d%H%M%S"`
MAILOUTPUT=BCKP_CONF_ENV_"$FILEDATE"_"$SITE"
MASTERS=`nbemmcmd -listhosts | grep master | awk {'print $2'}`
MEDIAS=`nbemmcmd -listhosts | grep media | awk {'print $2'}`
TAPECOUNT=`vmoprcmd | grep -c /dev/rmt`
LIBCOUNT=`tpconfig -emm_dev_list | grep -c "^Robot:"`
DISKCOUNT=`bpstulist -U | grep "Storage Unit Type:" | grep -c Disk`
J_QUE=`bpdbjobs | grep -c Que`
J_ACT=`bpdbjobs | grep -c Act`
ACT_DRIVES=`vmoprcmd | grep rmt | grep -c ACTIVE`
DOWN_DRIVES=`vmoprcmd  | grep -c DOWN`
CLEAN_RQ=`tpclean -l | grep -ic cleaning`

if [ `tpclean -l | grep -ic cleaning` -eq 0 ]; then
        DR_CLEAN_RQ="0"
        else
                DR_CLEAN_RQ=`tpclean -l | grep hc | grep cleaninig | awk {'print $1'}`
fi

echo "RecordDate|Site|Record Type|MasterServer|MediaServer|LibraryDeviceCount|TapeDeviceCount|DiskStorageUnitCount|JobsInQue|JobsActive|ActiveDrives|DownDrives|TapeCleaningRequests|DriveRequestingCleaning" > $OUTPUT

echo "`echo $DATE`|`echo $SITE`|`echo EnvConfig`|`echo $MASTERS`|`echo $MEDIAS`|`echo $LIBCOUNT`|`echo $TAPECOUNT`|`echo $DISKCOUNT`|`echo $J_QUE`|`echo $J_ACT`|`echo $ACT_DRIVES`|`echo $DOWN_DRIVES`|`echo $CLEAN_RQ`|`echo $DR_CLEAN_RQ`" >> $OUTPUT

cd $DEFPATH
cp $OUTPUT $MAILOUTPUT
#/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "$SITE NBU Configuration Stats" laramy.starbuck@4cgroup.co.za
/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "Performance Monitor" monitor@4cgroup.co.za

rm $OUTPUT
