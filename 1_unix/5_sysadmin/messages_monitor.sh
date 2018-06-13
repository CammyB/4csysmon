#!/bin/bash

# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

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
TMP1=$DEFPATH/7_temp/msg.tmp1
TMP2=$DEFPATH/7_temp/msg.tmp2
MARKER=$DEFPATH/7_temp/msg.mark
MESG1=$DEFPATH/7_temp/msg.msg1
MESG2=$DEFPATH/7_temp/msg.msg2
P1=$DEFPATH/7_temp/msg.p1
P2=$DEFPATH/7_temp/msg.p2
ORIMESG=/var/adm/messages       #Path to the messages file

. $DEFPATH/6_misc/global_parameters.list

LEVELCRIT="'.emerg|.alert|.crit|.err|.warning'"
P1TRAP="'.emerg|.alert|.crit'"
P2TRAP="'.err|.warning'"
IGNORE="sshd|su root|su insight|su oracle|EV_AGENT|pam_authtok_check|Oracle HA daemon is enabled"

################
# Main Program #
################

# Create the temporary files

touch $MARKER $TMP1 $TMP2

# if a historic file exists(MSG2) then copy MSG1 to MSG2 else create MSG2 from the original msg file

if [ -e $MESG2 ]; then
cp $MESG1 $MESG2
else
cp $ORIMESG $MESG2
fi

# Copy the original msg file to a location to be manipulated

cp $ORIMESG $MESG1

# if there is a difference between MSG1 and MSG2 then remove the first 4 columns(date) and dump it in TMP1

if [[ `diff $MESG2 $MESG1` != "" ]];then
diff $MESG2 $MESG1 |grep ">" | sed 's/> //' | awk '{ $1="";$2="";$3="";$4="" ; print }' | awk '{$1=$1 ;print }' > $TMP1
fi

# If the contents of TMP1 is notify-worthy then dump the worthy stuff to TMP2

if [[ `egrep '.emerg|.alert|.crit|.err|.warning' $TMP1` != "" ]];then
       egrep '.emerg|.alert|.crit|.err|.warning' $TMP1 > $TMP2

# Log sev1 and sev2 alerts and change the alert line to conform to the naming convention

egrep '.emerg|.alert|.crit' $TMP2 |egrep -v "$IGNORE" | nawk '{$0="'"$DATE"' '"$HOSTLOGNAME"' P1 '"$LOGDES"' "$0}1' |cut -c -125 > $P1
egrep '.err|.warning|su root' $TMP2 | egrep -v "$IGNORE" | nawk '{$0="'"$DATE"' '"$HOSTLOGNAME"' P2 '"$LOGDES"' "$0}1' |cut -c -125 > $P2

# Notify if the p1 file contains something

                if [[ `cat $P1` != "" ]];then
#		cat $P1 | awk '{ $1="";$2="";$3="";$4="";$5="" ; print }' | awk '{$1=$1 ;print }' | mailx -s -r "$SYSMONMAIL" "$HOST P1: messages" $SERVICEDESKMAIL

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
  $URG\n\n" | cat - $P1 | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P1: messages" $SERVICEDESKMAIL

#		(sh $SMS $UXSUPPSMS "$HOST P1: var_adm_messages")
                cat $P1 >> $LOG
                cat $P1 >> $MASTERLOG
                rm $P1
                echo $DATE >> $MARKER
                fi

# Notify if the p2 file contains something

                if [[ `cat $P2` != "" ]];then
#		cat $P2 | awk '{ $1="";$2="";$3="";$4="";$5="" ; print }' | awk '{$1=$1 ;print }' | mailx -r "$SYSMONMAIL" -s "$HOST P2: messages" $SERVICEDESKMAIL
		cat $SDTEMP $P2 | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: messages" $SERVICEDESKMAIL
                cat $P2 >> $LOG
                cat $P2 >> $MASTERLOG
                rm $P2
                echo $DATE >> $MARKER
                fi
fi

# If no errors are found create a time stamp in the log

        if [[ -z `cat $MARKER` ]];then
        echo $DATE stamp >> $LOG
        fi

# Remove temporary files

rm $TMP1 $TMP2 $MARKER
