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

LOG=$DEFPATH/5_sysadmin/slot_changes.log
LIST=$DEFPATH/7_temp/slot_changes.list
HIST=$DEFPATH/7_temp/slot_changes.hist
TMP=$DEFPATH/7_temp/slot_changes.tmp
BODY=$DEFPATH/7_temp/slot_changes.mark

. $DEFPATH/6_misc/global_parameters.list

LIBNR=1

################
# Main Program #
################

touch $TMP $BODY

if [ -e $LIST ]; then
mv $LIST $HIST
else
echo Initial Listfile needed >> $LOG
fi

/opt/openv/volmgr/bin/vmcheckxxx -rt tld -rn $LIBNR -list | awk 'NR>5' | awk '{print $1," ",$3}' > $LIST

if [[ -z `cat $LIST` ]];then
rm $LIST
cp $HIST $LIST
echo $DATE Library $LIBNR: Library functions in progress resulting in vmcheckxxx command being blank >> $LOG
exit 0
fi

for i in `cat $LIST |awk '{print $1}'`
do

##################
# Loop Variables #
##################

CURRTAPE=`grep -w $i $LIST |awk '{print $2}'`
CURRSLOT=`grep -w $i $LIST |awk '{print $1}'`
HISTTAPE=`grep -w $i $HIST |awk '{print $2}'`
HISTSLOT=`grep -w $i $HIST |awk '{print $1}'`

if [[ `echo $CURRTAPE` = "" ]];then
MOVEDTAPESLOT=""
else
MOVEDTAPESLOT=`grep $CURRTAPE $HIST | awk '{print $1}'`
fi

if [[ `echo $HISTTAPE` = "" ]];then
HISTTAPESLOT=""
HISTSLOTMOVE=""
HISTTAPEMOVE=""
else
HISTTAPESLOT=`grep $HISTTAPE $HIST | awk '{print $1}'`
HISTSLOTMOVE=`grep $HISTTAPE $LIST | awk '{print $1}'`
HISTTAPEMOVE=`grep $HISTTAPE $LIST | awk '{print $2}'`
fi

# if the current tape in the slot isn't the same as the tape that was in the slot do:

if [[ `echo $CURRTAPE` != `echo $HISTTAPE` ]];then

# if current slot is empty

  if [[ `echo $CURRTAPE` = "" ]];then

# tape was in the slot, not anymore

    if [[ `echo $HISTTAPE` != "" ]]; then 

# tape was in the slot but is now moved to a different slot

      if [[ `echo $HISTTAPEMOVE` != "" ]]; then
      echo $DATE Library $LIBNR: $HISTTAPE was moved from slot $HISTSLOT to slot $HISTSLOTMOVE >> $LOG
      echo $DATE Library $LIBNR: $HISTTAPE was moved from slot $HISTSLOT to slot $HISTSLOTMOVE >> $BODY

# tape is not found in the current library slots so it was ejected

      else
      echo $DATE Library $LIBNR: $HISTTAPE ejected, from slot $HISTSLOT >> $LOG
      echo $DATE Library $LIBNR: $HISTTAPE ejected, from slot $HISTSLOT >> $BODY
      fi
    fi
  else

# current slot is occupied
# checking if the tape was previously in the library

    if [[ `echo $MOVEDTAPESLOT` = "" ]]; then 

# the tape wasnt in the library previously therefore it is newly injected

    echo $DATE Library $LIBNR: $CURRTAPE loaded into slot $CURRSLOT >> $LOG
    echo $DATE Library $LIBNR: $CURRTAPE loaded into slot $CURRSLOT >> $BODY
    fi

# if hist tape was in the library previously

      if [[ `echo $HISTTAPESLOT` != "" ]]; then

        if [[ `echo $HISTSLOTMOVE` != "" ]]; then

# hist tape was moved from slot in previous library slots to the current slot

        echo $DATE Library $LIBNR: $HISTTAPE moved from slot $HISTSLOTMOVE to slot $CURRSLOT >> $LOG
        echo $DATE Library $LIBNR: $HISTTAPE moved from slot $HISTSLOTMOVE to slot $CURRSLOT >> $BODY

# hist tape not in current slots therefore it is ejected

        else
        echo $DATE Library $LIBNR: $HISTTAPE ejected, from slot $HISTSLOT >> $LOG
        echo $DATE Library $LIBNR: $HISTTAPE ejected, from slot $HISTSLOT >> $BODY
        fi
      fi
  fi
fi

done

        if [[ -z `cat $BODY` ]];then
        echo $DATE stamp >> $LOG
        else
#        cat $BODY | mailx -s "$HOST activity on Library $LIBNR" unixsupport@4cit.co.za
	cat $SDTEMP $BODY | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST activity on Library $LIBNR" $SERVICEDESKMAIL
        fi

rm $TMP $BODY
