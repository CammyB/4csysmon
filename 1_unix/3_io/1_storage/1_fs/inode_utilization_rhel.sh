#!/bin/bash

# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="fs_inode_utilization_rhel"
LOG=$DEFPATH/3_io/1_storage/1_fs/inode_utilization_rhel.log
INODETHRESH=$DEFPATH/6_misc/inodes_thresholds_rhel.list
TMP=$DEFPATH/7_temp/fs_inode_rhel.tmp
MARKER=$DEFPATH/7_temp/fs_inode_utilization_rhel.tmp

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

# Create list of filesystems to monitor.

df -Pi -F ext4 |grep -v Mounted|awk '{print $5,$6}'  > $TMP

# Loop through all filesystems to be monitored

for FS in `cat $TMP |awk '{print $2}'`
do

# Loop Variables

AVAIL=`awk '$2 == "'"$FS"'" {print $1}' $TMP |cut -d "%" -f 1`

# Loop Variables

THRESHPERC=`cat $INODETHRESH |grep -v '#' |awk '$1 == "'"$FS"'" {print $2}'`

# If current percentage is greater than the percentage in the threshold file, do the following:

  if [[ $AVAIL -gt $THRESHPERC ]]; then

# Log alerts to a log file

  echo $DATE $HOSTLOGNAME P2 $LOGDES $FS at $AVAIL "percent inodes used" >> $LOG
  echo $DATE $HOSTLOGNAME P2 $LOGDES $FS at $AVAIL "percent inodes used" >> $MASTERLOG

# Email Service Desk

#  echo "$FS at $AVAIL "percent inodes used"" | mailx -s "@4CSD@$HOST P2: Inodes running full $FS $AVAIL %" $SERVICEDESK $UXSUPPMAIL
printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  $GRP
  $OPP
  $TECH
  $CAT
  @@SUBCATEGORY=Space Management@@
  $ITEM
  $PRI
  $URG\n\n
$FS at $AVAIL percent inodes used" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: Inodes running full $FS $AVAIL %" $SERVICEDESKMAIL

  fi
done

rm $TMP
