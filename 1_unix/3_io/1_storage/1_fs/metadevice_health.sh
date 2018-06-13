#!/bin/bash

######################
# Info and Changelog #
######################
# C. White, 2011

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

LOGDES="metadevice____health"
LOG=$DEFPATH/3_io/1_storage/1_fs/metadevice_health.log
TMP1=$DEFPATH/7_temp/meta1.tmp

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

# Create list of metadevices that have faulted 

metastat -c|egrep -i 'maint|err|unav' > $TMP1

# Amount of lines in the $TMP1 file

WC=`wc -l $TMP1`

# If $TMP1 is not empty then notify us/log it

if [[ `cat $TMP1` != "" ]]
then

#(sh $SMS $UXSUPPSMS "$HOST P1: Please check metadevice $WC faulted")
#cat $TMP1 | mailx -s "$HOST P1: Check metadev $WC faulted" $UXSUPPMAIL

printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  $GRP
  $OPP
  $TECH
  $CAT
  $SCAT
  $ITEM
  @@PRIORITY=P1@@
  $URG\n\n" | cat - $TMP1 | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P1: Check metadev $WC faulted" $SERVICEDESKMAIL

# Loop round all entries in the $TMP1 file and make an entry for each in the log

	for i in `cat $TMP1 | awk '{print $1}'`
	do
	echo $DATE $HOSTLOGNAME P1 $LOGDES $i in maintance state >> $LOG
	echo $DATE $HOSTLOGNAME P1 $LOGDES $i in maintance state >> $MASTERLOG
	done

else
	echo $DATE stamp >> $LOG
fi

# Remove temporary files

rm $TMP1
