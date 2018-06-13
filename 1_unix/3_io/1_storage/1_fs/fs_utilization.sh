#!/bin/bash

######################
# Info and Changelog #
######################
# C. White, 2011
#
# run this command to add fsystems to initially set up the threshold file
#
# df -h |egrep -v '^/devices|^ctfs|^proc|^mnttab|^swap|^objfs|^sharefs|^/usr/lib/libc/|^fd|^swap|^Filesystem' |awk '{print $6}' > /4csysmon/1_unix/6_misc/fs_thresholds.list
#
# the file's format should look like this: threshold ; alerting party ; filesystem
#
# 60    UXMAIL;UXSMS            /
# 80    UXMAIL;ORASUPP;VTLSUPP  /app
#
# available alerting parties are listed from line 110'ish and onwards
#
# Cool idea is "chown root:oinstall $FSTHRESH" so that the DBA's can change thresholds

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

LOGDES="fs_______utilization"
LOG=$DEFPATH/3_io/1_storage/1_fs/fs_utilization.log
FSTHRESH=$DEFPATH/6_misc/fs_thresholds.list
DFTMP=$DEFPATH/7_temp/dfout.tmp
MARKER=$DEFPATH/7_temp/fs_utilization.tmp

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

# Create list of filesystems to monitor.
# If you wish to exclude some mountpoints, do so by adding a grep -v line as done below.

df -k                                           |\
                grep -v ^/devices               |\
                grep -v ^ctfs                   |\
                grep -v /platform/sun4u         |\
                grep -v ^/platform/sun4v        |\
                grep -v ^proc                   |\
                grep -v ^mnttab                 |\
                grep -v /cdrom/                 |\
                grep -v /dev/lofi/              |\
	        grep -v /var/share              |\
                grep -v volatile                |\
                grep -v ^swap                   |\
                grep -v /.alt.                  |\
		grep -v ^/.SUN			|\
                grep -v ^objfs                  |\
                grep -v ^sharefs                |\
                grep -v ^/usr/lib/libc/         |\
                grep -v ^fd                     |\
                grep -v /a/                     |\
                grep -v ^Filesystem             |\
                awk '{print $4,$5,$6}' > $DFTMP

# Create the temporary files

touch $MARKER

# Loop through all filesystems to be monitored

for FS in `cat $DFTMP |awk '{print $3}'`
do

# Loop Variables

AVAIL=`awk '$3 == "'"$FS"'" {print $1}' $DFTMP`
AVAILMB=`echo "$AVAIL / 1024" | bc`
CURPERC=`awk '$3 == "'"$FS"'" {print $2}' $DFTMP`

# If there is no entry for the fs in the threshold file, notify us

if [[ `cat $FSTHRESH |grep -v '#' |awk '$3 == "'"$FS"'" {print $3}'` == "" ]]; then

printf "%s\n" "  $ACC
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
$HOST $FS at $CURPERC $AVAILMB MB Available: FS not in threshold file" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2 fs_util : $FS thresh err" $SERVICEDESKMAIL

#echo $HOST $FS at $CURPERC $AVAILMB"MB Available: FS not in threshold file" | mailx -r "$SYSMONMAIL" -s "$HOST P2 fs_util : $FS thresh err" $UXSUPPMAIL
echo $DATE $HOSTLOGNAME P2 $LOGDES $FS at $CURPERC $AVAILMB"MB available : FS not in threshold file" >> $LOG
echo $DATE $HOSTLOGNAME P2 $LOGDES $FS at $CURPERC $AVAILMB"MB available : FS not in threshold file" >> $MASTERLOG
echo $DATE $HOSTLOGNAME $FS at $CURPERC $AVAILMB"MB available" >> $MARKER
else

# Loop Variables

THRESHMB=`cat $FSTHRESH |grep -v '#' |awk '$3 == "'"$FS"'" {print $1}'`
THRESH=`echo "$THRESHMB * 1000" |bc`
COUNTER="/tmp/count`cat $FSTHRESH |grep -v '#' |awk '$3 == "'"$FS"'" {print NF}'`"

# If current percentage is greater than the percentage in the threshold file, do the following:

  if [[ $THRESH -gt $AVAIL ]]; then

# Log alerts to a log file

    echo $DATE $HOSTLOGNAME P2 $LOGDES $FS at $CURPERC $AVAILMB"MB available" >> $LOG
    echo $DATE $HOSTLOGNAME P2 $LOGDES $FS at $CURPERC $AVAILMB"MB available" >> $MASTERLOG
    echo $DATE $HOSTLOGNAME $FS at $CURPERC $AVAILMB"MB available" >> $MARKER

# Makes an entry in $COUNTER if this fs' threshold was hit, this is used for escalation purposes by counting number of occurences.

   echo $DATE >> $COUNTER

#########################################################################################

# Function for the notification field of the relevent FS

  notifield ()
  {
  cat $FSTHRESH |grep -v '#' |awk '$3 == "'"$FS"'" {print $2}' |grep $1
  }

# Function to mail to make adding new alerting parties easier.

  mailsend ()
  {
  #echo "$FS at $CURPERC $AVAILMB"MB available"" | mailx -s "@4CSD@$HOST P2: fs_util $FS $CURPERC" $1
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
$FS at $CURPERC% $AVAILMB MB available" | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P2: fs_util $FS $CURPERC" $1
  }

# Function to sms to make adding new alerting parties easier.

  smssend ()
  {
	echo "nothing to do"
#  (sh $SMS $1 "$HOST P2 $FS at $CURPERC $AVAILMB MB available")
  }

#########################################################################################

# Loop through the threshold file for parties to be alerted with the following actions

        if [[ `notifield UXSUPPMS` != "" ]];then
#                smssend $UXSUPPSMS
                mailsend $UXSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield UXSUPPMAIL` != "" ]];then
                mailsend $UXSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield ORASUPPMS` != "" ]];then
#                smssend $ORASUPPSMS
                mailsend $ORASUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield ORASUPPMAIL` != "" ]];then
#                mailsend $ORASUPPMAIL
		TECH="@@TECHNICIAN=4C Support - Oracle Standby Technician@@"	
		mailsend $ORASUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield DRCSUPPMS` != "" ]];then
#                smssend $DRCSUPPSMS
#                mailsend $DRCSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield DRCSUPPMAIL` != "" ]];then
#                mailsend $DRCSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield VTLSUPPMS` != "" ]];then
#                smssend $VTLSUPPSMS
#                mailsend $VTLSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield VTLSUPPMAIL` != "" ]];then
#                mailsend $VTLSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield VMSASUPPMS` != "" ]];then
#                smssend $VMSASUPPSMS
#                mailsend $VMSASUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield VMSASUPPMAIL` != "" ]];then
#                mailsend $VMSASUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield BCXSMS` != "" ]];then
#                smssend $BCXSMS
		 echo "do nothing"
        fi

        if [[ `notifield BILLAPPTZMS` != "" ]];then
#                smssend $BILLAPPTZSMS
                mailsend $BILLAPPTZMAIL
        fi

        if [[ `notifield BILLAPPTZMAIL` != "" ]];then
                mailsend $BILLAPPTZMAIL
        fi

        if [[ `notifield VMZSUPPMS` != "" ]];then
#                smssend $VMZSUPPSMS
                mailsend $VMZSUPPMAIL
        fi

        if [[ `notifield VMZSUPPMAIL` != "" ]];then
                mailsend $VMZSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi              

        if [[ `notifield VCLSUPPMS` != "" ]];then
#                smssend $VCLSUPPSMS
#                mailsend $VCLSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi

        if [[ `notifield VCLSUPPMAIL` != "" ]];then
#                mailsend $VCLZSUPPMAIL
                mailsend $SERVICEDESKMAIL
        fi
       
# If the alert has been logged more than 5 times send an sms to Oscar as an escalation

    if [ `cat $COUNTER | wc -l | awk '{ print $1 }'` -gt 5 ];then

# If the $COUNTER file for the FS is /tmp/count that means there was no entry for it in the threshold file, otherwise it would be /tmp/count{number}

      if [ $COUNTER != "/tmp/count" ]; then
	echo "do nothing"
      #(sh $SMS $OSCARSMS "$HOST P2 $FS at $CURPERC $AVAILMB"MB available"")
#      smssend $OSCARSMS
      rm $COUNTER
      fi
          
    fi
  fi
fi
done

# If no errors are found create a time stamp in the log

if [[ -z `cat $MARKER` ]];then
        echo $DATE stamp >> $LOG
fi

# Remove temporary files

rm $MARKER $DFTMP
