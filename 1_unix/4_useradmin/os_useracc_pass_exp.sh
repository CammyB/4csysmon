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
#
#This scripts checks all the user accounts excluding NP,LK and default system accounts   

#############
# Variables #
#############

DEFPATH=/4csysmon/1_unix

LOGDES="os_useracc__pass_exp"
LOG=$DEFPATH/4_useradmin/os_useracc_pass_exp.log
LOGTMP=$DEFPATH/7_temp/4c_passwd.tmp
MARKER=$DEFPATH/7_temp/4c_passwd.tmp1
PASSWD_NOTIF=$DEFPATH/6_misc/password_notification.list

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################
#Today's date (expressed in epoch format)
today=`perl -e 'printf("%d\n", (time/60/60/24))'`
touch $LOGTMP $MARKER

for line in `egrep -v "NP|LK" /etc/shadow`
do

#Loop variables

  USER=`echo $line | awk -F: '{print $1}'`
  DAY_LAST_PASS_CHANGE=`echo $line | awk -F: '{print $3}'`
  DAYS_PASS_VALID=`echo $line | awk -F: '{print $5}'`
  DAYS_SINCE_LAST_PASS_CHANGE=`echo "$today - $DAY_LAST_PASS_CHANGE" |bc`
  DAYS_UNTIL_PASS_EXPIRE=`echo "$DAYS_PASS_VALID - $DAYS_SINCE_LAST_PASS_CHANGE" |bc`
  TAG="Login Expiration User: $USER"

  if [[ $DAYS_UNTIL_PASS_EXPIRE -eq 0 ]]; then
  DAYS_UNTIL_PASS_EXPIRE=0
  fi
	if [ $DAYS_UNTIL_PASS_EXPIRE -gt 0 ]; then
		if [ "$DAYS_UNTIL_PASS_EXPIRE" -lt 6 ]; then
			echo "$USER;$DAYS_UNTIL_PASS_EXPIRE" >> $LOGTMP
			echo "$DATE $HOSTLOGNAME P2 $LOGDES $USER password expires in $DAYS_UNTIL_PASS_EXPIRE days" >> $LOG
			echo "$DATE $HOSTLOGNAME P2 $LOGDES $USER password expires in $DAYS_UNTIL_PASS_EXPIRE days" >> $MASTERLOG
			echo $DATE >> $MARKER
		fi
	fi
done

for line2 in `cat $LOGTMP`
do

USER=`echo $line2|cut -d ';' -f 1`
DAYS_UNTIL_PASS_EXPIRE=`echo $line2|cut -d ';' -f 2`
TAG="Login Expiration User: $USER"
PARAM1=`cat $PASSWD_NOTIF |grep -v '#' | awk '$1 == "'"$USER"'" {print $1}'`
MAIL=`cat $PASSWD_NOTIF |grep -v '#' | awk '$1 == "'"$USER"'" {print $2}'`

mailsend ()
  {
printf "  $ACC
  $SITE
  $MODE
  $REQ
  $REQTYPE
  $GRP
  $OPP
  $TECH
  $CAT
  @@SUBCATEGORY=User Administration & Auditing@@
  $ITEM
  $PRI
  $URG\n\n
The user account $USER on $HOST expires in $DAYS_UNTIL_PASS_EXPIRE days" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: $TAG" $1
#  echo "The user account $USER on $HOST expires in $DAYS_UNTIL_PASS_EXPIRE days" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: $TAG" $1
  }

if [[ $PARAM1 -eq $USER ]]; then
	mailsend $MAIL
else
	mailsend $UXSUPPMAIL
	mailsend $SERVICEDESKMAIL
fi

done

if [[ -z `cat $MARKER` ]]; then
        echo $DATE stamp >> $LOG
fi

rm $LOGTMP $MARKER
