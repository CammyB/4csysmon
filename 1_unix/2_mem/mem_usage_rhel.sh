#!/bin/bash

######################
# Info and Changelog #
######################
# C. White, 2011
#
# This script uses the application, top.

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

LOGDES1="memory_________usage"
LOGDES2="swap___________usage"
LOG=$DEFPATH/2_mem/mem_usage.log
TMP1=$DEFPATH/7_temp/mem_usage.tmp1
MARKER=$DEFPATH/7_temp/mem_usage.tmp2

. $DEFPATH/6_misc/global_parameters.list

MTHRESH=97      # Memory percentage usage threshold
STHRESH=50      # Swap percentage usage threshold

################
# Main Program #
################

#Create the temporary files

touch $MARKER

# Capture a snap of the output of "top" in $TMP1

#/usr/bin/top > $TMP1
/usr/bin/top -bn 1 > $TMP1

# Parameters for the usage of memory
# if statements to look at if the values are in GB, MB or KB
# Maximum Memory

        if [[ `grep "Mem:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |egrep 'k|K'` != "" ]];then
      MEMMAX="`grep "Mem:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |cut -d 'k' -f1`"
        fi
		
	if [[ `grep "Mem:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |egrep 'm|M'` != "" ]];then
   MEMMAXRAW="`grep "Mem:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |cut -d 'm' -f1`"
	MEMMAX=`echo "$MEMMAXRAW * 1000" |bc`
        fi
		
	if [[ `grep "Mem:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |egrep 'g|G'` != "" ]];then
   MEMMAXRAW="`grep "Mem:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |cut -d 'g' -f1`"
	MEMMAX=`echo "$MEMMAXRAW * 1000000" |bc`
        fi
		
# Available Memory		

        if [[ `grep "Mem:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |egrep 'k|K'` != "" ]];then
    MEMAVAIL="`grep "Mem:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |cut -d 'k' -f1`"
        fi
		
	if [[ `grep "Mem:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |egrep 'm|M'` != "" ]];then
 MEMAVAILRAW="`grep "Mem:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |cut -d 'm' -f1`"
	MEMAVAIL=`echo "$MEMAVAILRAW * 1000" |bc`
        fi
		
	if [[ `grep "Mem:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |egrep 'g|G'` != "" ]];then
 MEMAVAILRAW="`grep "Mem:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |cut -d 'g' -f1`"
	MEMAVAIL=`echo "$MEMAVAILRAW * 1000000" |bc`
        fi


MEMUSAGE=`expr $MEMMAX - $MEMAVAIL`
MEMUSAGEPERC=`echo "$MEMUSAGE * 100 / $MEMMAX" | bc`

# Alert us/log it, if the percentage of memory used is more than $MTHRESH

        if [[ `echo "$MEMUSAGE * 100 / $MEMMAX" | bc` -gt $MTHRESH ]]; then
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
  $PRI
  $URG\n\n$DATE Memory Usage at $MEMUSAGEPERC%%\n" | mailx -r $SYSMONMAIL -s "@4CSD@$HOST P2: Mem Usage $MEMUSAGEPERC%" $SERVICEDESKMAIL

#        echo "$DATE Memory Usage at $MEMUSAGEPERC%" | mailx -s "$HOST P2: Mem Usage $MEMUSAGEPERC%" $UXSUPPMAIL
	echo $DATE $HOSTLOGNAME P2 $LOGDES1 Memory Usage: $MEMUSAGEPERC% >> $LOG
        echo $DATE $HOSTLOGNAME P2 $LOGDES1 Memory Usage: $MEMUSAGEPERC% >> $MASTERLOG
        echo $DATE >> $MARKER
        fi

# Parameters for the usage of swap 
# if statements to look at if the values are in GB or MB
# Maximum Swap

        if [[ `grep "Swap:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |egrep 'k|K'` != "" ]];then
     SWAPMAX="`grep "Swap:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |cut -d 'k' -f1`"
        fi
		
	if [[ `grep "Swap:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |egrep 'm|M'` != "" ]];then
  SWAPMAXRAW="`grep "Swap:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |cut -d 'm' -f1`"
	SWAPMAX=`echo "$SWAPMAXRAW * 1000" |bc`
        fi
		
	if [[ `grep "Swap:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |egrep 'g|G'` != "" ]];then
  SWAPMAXRAW="`grep "Swap:" $TMP1 |cut -d ',' -f1 |awk '{print $2}' |cut -d 'g' -f1`"
	SWAPMAX=`echo "$SWAPMAXRAW * 1000000" |bc`
	fi

# Available Swap
		
        if [[ `grep "Swap:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |egrep 'k|K'` != "" ]];then
   SWAPAVAIL="`grep "Swap:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |cut -d 'k' -f1`"
        fi
		
        if [[ `grep "Swap:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |egrep 'm|M'` != "" ]];then
SWAPAVAILRAW="`grep "Swap:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |cut -d 'm' -f1`"
	SWAPAVAIL=`echo "$SWAPAVAILRAW * 1000" |bc`
        fi
		
        if [[ `grep "Swap:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |egrep 'g|G'` != "" ]];then
SWAPAVAILRAW="`grep "Swap:" $TMP1 |cut -d ',' -f3 |awk '{print $1}' |cut -d 'g' -f1`"
	SWAPAVAIL=`echo "$SWAPAVAILRAW * 1000000" |bc`
        fi

SWAPUSAGE=`expr $SWAPMAX - $SWAPAVAIL`
SWAPUSAGEPERC=`echo "$SWAPUSAGE * 100 / $SWAPMAX" | bc`

# Alert us/log it, if the percentage of memory used is more than 

        if [[ `echo "$SWAPUSAGE * 100 / $SWAPMAX" | bc` -gt $STHRESH ]]; then
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
  $PRI
  $URG\n\n$DATE Memory Usage at $SWAPUSAGEPERC%%\n" | mailx -r $SYSMONMAIL -s "@4CSD@$HOST P2: Mem Usage $SWAPUSAGEPERC%" $SERVICEDESKMAIL
        #echo "$DATE Swap Usage at $SWAPUSAGEPERC%" | mailx -s "$HOST P1: Swap Usage $SWAPUSAGEPERC%" $UXSUPPMAIL
        (sh $SMS $UXSUPPSMS "$HOST P1: Swap Usage at $SWAPUSAGEPERC%")
		(sh $SMS $PATRICKSMS "$HOST P1: Swap Usage at $SWAPUSAGEPERC%")
	echo $DATE $HOSTLOGNAME P1 $LOGDES2 Swap Usage: $SWAPUSAGEPERC% >> $LOG
        echo $DATE $HOSTLOGNAME P1 $LOGDES2 Swap Usage: $SWAPUSAGEPERC% >> $MASTERLOG
        echo $DATE >> $MARKER
        fi

# If no errors are found create a time stamp in the log

        if [[ -z `cat $MARKER` ]];then
        echo $DATE stamp >> $LOG
        fi

# Remove temporary files

rm $TMP1 $MARKER
