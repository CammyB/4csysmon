#!/bin/bash

######################
# Info and Changelog #
######################
# C. White, 2011

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="__adm_______messages"
LOG=$DEFPATH/5_sysadmin/messages_monitor.log
TMparam1=$DEFPATH/7_temp/msg.tmparam1
TMP2=$DEFPATH/7_temp/msg.tmp2
MARKER=$DEFPATH/7_temp/msg.mark
MESG1=$DEFPATH/7_temp/msg.msg1
MESG2=$DEFPATH/7_temp/msg.msg2
param1=$DEFPATH/7_temp/msg.param1
ORIMESG=/var/log/messages       #Path to the messages file

. $DEFPATH/6_misc/global_parameters.list

TRAP="emerg|crit|err|failed"

################
# Main Program #
################

# Create the temporary files

touch $MARKER $TMparam1 $TMP2

# if a historic file exists(MSG2) then copy MSG1 to MSG2 else create MSG2 from the original msg file

if [ -e $MESG2 ]; then
cp $MESG1 $MESG2
else
cp $ORIMESG $MESG2
fi

# Copy the original msg file to a location to be manipulated

cp $ORIMESG $MESG1

# if there is a difference between MSG1 and MSG2 then remove the first 4 columns(date) and dump it in TMparam1

if [[ `diff $MESG2 $MESG1` != "" ]];then
 diff $MESG2 $MESG1 						|\
		grep ">" 					|\
		sed 's/> //' 					|\
		awk '{ $1="";$2="";$3="";$4="" ; print }' 	|\
		awk '{$1=$1 ;print }'				|\
		> $TMparam1
fi
# If the contents of TMparam1 is notify-worthy then dump the worthy stuff to TMP2

if [[ `egrep "$TRAP" $TMparam1` != "" ]];then
	egrep "$TRAP" $TMparam1 > $TMP2

# Log sev1 and sev2 alerts and change the alert line to conform to the naming convention

	egrep "$param1TRAP" $TMP2 | nawk '{$0="'"$DATE"' '"$HOSTLOGNAME"' P2 $LOGDES "$0}1' |cut -c -125 > $param1

# Notify if the param1 file contains something

		if [[ `cat $param1` != "" ]];then
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
  $URG\n\n" | cat - $param1 | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: messages" $SERVICEDESKMAIL

#		cat $param1 | mailx -s "$HOST param1: messages" $UXSUPPMAIL
		#(sh $SMS $UXSUPPSMS "$HOST param1: var_adm_messages")
		cat $param1 >> $LOG
		cat $param1 >> $MASTERLOG
		rm $param1
		echo $DATE >> $MARKER
		fi
fi
# If no errors are found create a time stamp in the log

        if [[ -z `cat $MARKER` ]];then
        echo $DATE stamp >> $LOG
        fi

# Remove temporary files

rm $TMP2 $MARKER
