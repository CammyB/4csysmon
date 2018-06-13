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

LOGDES="mntab__diff___vfstab"
LOG=$DEFPATH/3_io/1_storage/1_fs/mntab_diff_vfstab.log
VOUT=$DEFPATH/7_temp/mntab_diff_vfstab.tmp1
DFOUT=$DEFPATH/7_temp/mntab_diff_vfstab.tmp2
DIFF=$DEFPATH/7_temp/mntab_diff_vfstab.tmp3
FINAL=$DEFPATH/7_temp/mntab_diff_vfstab.tmp4
MARKER=$DEFPATH/7_temp/mntab_diff_vfstab.tmp5
SWAPTMP1=$DEFPATH/7_temp/mntab_diff_vfstab.tmp6
SWAPTMP2=$DEFPATH/7_temp/mntab_diff_vfstab.tmp7
SWAPDIFF=$DEFPATH/7_temp/mntab_diff_vfstab.tmp8

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

# Create the temporary files

touch $FINAL $MARKER

# Capture vfstab to a file with all relevant FS

cat /etc/vfstab |\
                grep -v /net/tzvodasmc01/eis    |\
                grep -v /proc                   |\
                grep -v '#'                     |\
                grep -v swap                    |\
                grep -v /system/contract        |\
                grep -v /system/object          |\
                grep -v /devices                |\
                grep -v /dev/fd                 |\
                grep -v sharetab                |\
                awk '{print $3}'                |\
                sort -n > $VOUT

# Capture df to a file with all relevant FS

df -h   |\
        grep -v /proc                   |\
        grep -v mnttab                  |\
        grep -v cdrom                   |\
        grep -v /net/tzvodasmc01/eis    |\
        grep -v sharetab                |\
        grep -v device                  |\
        grep -v '#'                     |\
        grep -v /system/                |\
        grep -v /dev/fd                 |\
        grep -v swap                    |\
        grep -v /lib/                   |\
        grep -v platform                |\
	grep -v /.alt.			|\
        grep -v Mounted                 |\
        awk '{print $6}'                |\
        sort -n > $DFOUT

# Capture differences between the 2 files

diff $VOUT $DFOUT > $DIFF

# Capture a tag for each difference

        if [[ -n `cat $DIFF |grep ">"` ]]
        then
                cat $DIFF |grep ">" |awk '{print $2" not in vfstab"}' >> $FINAL
        fi

        if [[ -n `cat $DIFF |grep "<"` ]]
        then
                cat $DIFF |grep "<" |awk '{print $2" not in mnttab"}' >> $FINAL
        fi

# If $FINAL is not empty then notify else echo stamp to log file

if [[ -s $FINAL ]]
then
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
  $URG\n\n" | cat - $FINAL | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P1: Check mounted" $SERVICEDESKMAIL

#	cat $FINAL | mailx -s "$HOST P1: Check mounted" $UXSUPPMAIL
	#(sh $SMS $UXSUPPSMS "$HOST P1: Check mounted `wc -l $FINAL` differences")
	cat $FINAL |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P1","'"$LOGDES"'",$0}' >> $LOG
	cat $FINAL |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P1","'"$LOGDES"'",$0}' >> $MASTERLOG
	echo $DATE > $MARKER
fi

# Remove temporary files

rm      $VOUT           \
        $DFOUT          \
        $DIFF



########
# SWAP #
########

# Blank the $FINAL file

> $FINAL

# Capture the swap list output to a file

swap -l | awk 'NR>1' | awk '{print $1}' |sort -rn > $SWAPTMP1

# Capture the swap entries in vfstab to a file

cat /etc/vfstab | grep -v '#' | awk '$4 ~ /swap/ {print $1}' |sort -rn > $SWAPTMP2

# Capture differences between the 2 files

diff $SWAPTMP1 $SWAPTMP2 > $SWAPDIFF

# Capture a tag for each difference

        if [[ -n `cat $SWAPDIFF |grep ">"` ]]
        then
                cat $SWAPDIFF |grep ">" |awk '{print $2" swap slice not in swap list"}' >> $FINAL
        fi

        if [[ -n `cat $SWAPDIFF |grep "<"` ]]
        then
                cat $SWAPDIFF |grep "<" |awk '{print $2" swap slice not in vfstab"}' >> $FINAL
        fi

# If $FINAL is not empty then notify else echo stamp to log file

if [[ -s $FINAL ]]
then
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
  $URG\n\n" | cat - $FINAL | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST P1: Check mounted" $SERVICEDESKMAIL

#        cat $FINAL | mailx -s "$HOST P1: Check mounted" $UXSUPPMAIL
#        (sh $SMS $UXSUPPSMS "$HOST P1: Check mounted `wc -l $FINAL` differences")
        cat $FINAL |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P1","'"$LOGDES"'",$0}' >> $LOG
        cat $FINAL |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P1","'"$LOGDES"'",$0}' >> $MASTERLOG
	echo $DATE >> $MARKER
fi

if [[ -z `cat $MARKER` ]];then
        echo $DATE stamp >> $LOG
fi

# Remove temporary files

rm      $SWAPTMP1	\
        $SWAPTMP2	\
	$SWAPDIFF	\
	$MARKER		\
	$FINAL
