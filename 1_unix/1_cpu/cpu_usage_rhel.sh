#!/bin/bash

######################
# Info and Changelog #
######################
# C. White, 2011
#
# This script takes the cpu idle value every X amount of seconds and if the value of all 4 values is above the threshold the necessary parties will be notified/logged in the appropriate logs.


## CHECK IF SCRIPT ALREADY RUNNING
SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
        echo "already running"
exit 1
fi

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="cpu____________usage"
LOG=$DEFPATH/1_cpu/cpu_usage.log
TMP1=$DEFPATH/7_temp/cpu_usage.tmp1
TMP2=$DEFPATH/7_temp/cpu_usage.tmp2
MARKER=$DEFPATH/7_temp/cpu_usage.tmp4

. $DEFPATH/6_misc/global_parameters.list

THRESH=10	# The threshold the idle value should be monitored at
SLP=150         # The amount of seconds between readings

################
# Main Program #
################

#Create the temporary files

touch $MARKER

# Funtion to determine the CPU usage

  cpu_usage_func ()
  {
  echo $DATE `sar 1 1 | awk 'NR>4' |awk '{print $8}'`
  }

# Function to get the last value added

  last_value_func ()
  {
  tail -1 $TMP1 | awk '{print $3}' | awk -F"." '{print $1}'
  }

# Create 1st CPU Usage value

DATE=`date '+%D %T'`
cpu_usage_func > $TMP1

# If usage is above the threshold then create 2nd CPU Usage value after $SLP seconds

if [ `last_value_func` -lt $THRESH ]; then
sleep $SLP
DATE=`date '+%D %T'`
cpu_usage_func >> $TMP1

# If usage is above the threshold then create 3rd CPU Usage value after $SLP seconds

  if [ `last_value_func` -lt $THRESH ]; then
  sleep $SLP
  DATE=`date '+%D %T'`
  cpu_usage_func >> $TMP1

# If usage is above the threshold then create 4th CPU Usage value after $SLP seconds

    if [ `last_value_func` -lt $THRESH ]; then
    sleep $SLP
    DATE=`date '+%D %T'`
    cpu_usage_func >> $TMP1

      if [ `last_value_func` -lt $THRESH ]; then

# Find the average of the 4 values

      U1=`sed -n 1p $TMP1 | awk '{print $3}'`
      U2=`sed -n 2p $TMP1 | awk '{print $3}'`
      U3=`sed -n 3p $TMP1 | awk '{print $3}'`
      U4=`sed -n 4p $TMP1 | awk '{print $3}'`
      AVG=`echo "($U1 + $U2 + $U3 + $U4) / 4" |bc`

# Compile the file to be the email body

      echo CPU usage above $THRESH for the last 5 minutes > $TMP2
      echo $U1% Idle >> $TMP2
      echo $U2% Idle >> $TMP2	
      echo $U3% Idle >> $TMP2
      echo $U4% Idle >> $TMP2
      echo Average = $AVG% Idle >> $TMP2

# Alert us/log it, if the values exceed the threshold

      cat $SDTEMP $TMP2 | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: CPU Usage $AVG% Idle" $SERVICEDESKMAIL
#      cat $TMP2 | mailx -s "$HOST P2: CPU Usage $AVG% Idle" $UXSUPPMAIL
      echo `sed -n 4p $TMP1 | awk '{print $1" "$2}'` $HOSTLOGNAME P2 $LOGDES CPU Usage $AVG% Idle >> $LOG
      echo `sed -n 4p $TMP1 | awk '{print $1" "$2}'` $HOSTLOGNAME P2 $LOGDES CPU Usage $AVG% Idle >> $MASTERLOG
      echo $DATE > $MARKER

      fi
    fi
  fi
fi

# If no errors are found create a time stamp in the log

	if [[ -z `cat $MARKER` ]];then
	echo $DATE stamp >> $LOG
	fi

# Remove temporary files

rm $TMP1 $TMP2 $MARKER
