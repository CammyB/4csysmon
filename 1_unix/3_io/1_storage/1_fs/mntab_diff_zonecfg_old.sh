#!/bin/bash

######################
# Info and Changelog #
######################
# C. White, 2011
#
#When customising this script all you need to change is :
#       1.the ZONE variable to the zone you need to monitor, must be the name used in zoneadm list.
#       2.add a number for I, such as 1, so that if this script runs at the same time as another zone mount checking script they wont share the same temporary files causing inacurate data.
#       3. the section of df -hZ; the command sed 's/........................\(.*\)/\1/'   the many dots in between are the amount of characters from character 1 it will not display so if a df -hZ displays /lun1/zone1/var, all you really want is /var, just change the amount of dots to 11 dots.
#       4. Have a look at the grep -v  entries to add or remove if you are getting alerts for unimportant filesystems.

#############
# Variables #
#############

ZONE=drcvodaoem01
I=1

DEFPATH=/4csysmon/1_unix

LOGDES="mntab__diff__zonecfg"
LOG=$DEFPATH/3_io/1_storage/1_fs/mntab_diff_zonecfg$I.log
ZOUT=$DEFPATH/7_temp/zonecfg$I.out
DFOUT=$DEFPATH/7_temp/df$I.out
DIFF=$DEFPATH/7_temp/differ$I.out
FINAL=$DEFPATH/7_temp/differfinal$I.out
ZROOTFS=`zoneadm list -ivc|grep $ZONE|egrep -v 'ID|global'|awk '{print $4}'|xargs -l df -h $1|grep -v Filesystem|awk '{print $1}'`

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

# Create the temporary files

touch $FINAL$1

# Capture zonecfg to a file with all relevant FS

zonecfg -z $ZONE info   |\
                grep -w dir            |\
		grep -v inherit-pkg-dir|\
                grep -v cdrom          |\
		grep -v /lib           |\
		grep -v /platform      |\
		grep -v /sbin          |\
                grep -v /usr           |\
                grep -v /usr/openv     |\
                awk '{print $2}'       |\
                sort -n > $ZOUT

# Capture df to a file with all relevant FS

df -Zh |\
        grep $ZONE      |\
        grep -v $ZROOTFS                |\
        awk '{print $6}'                |\
        sed 's/........................\(.*\)/\1/'    |\
        grep -v cdrom                   |\
        grep -v mnttab                  |\
        grep -v swap                    |\
        grep -v /dev/fd                 |\
        grep -v /proc                   |\
        grep -v /dev                    |\
        grep -v /etc/svc/volatile       |\
        grep -v /system/contract        |\
        grep -v /system/object          |\
	grep -v /platform		|\
	grep -v /usr			|\
        grep -v /tmp                    |\
	grep -v /sbin			|\
	grep -v /lib			|\
        grep -v /var/run                |\
        sort -n > $DFOUT                        

# Capture differences between the 2 files

diff $ZOUT $DFOUT > $DIFF

# Capture a tag for each difference

        if [[ -n `cat $DIFF |grep ">"` ]]
        then
                cat $DIFF |grep ">" |awk '{print $2" not in zonecfg"}' >> $FINAL
        fi

        if [[ -n `cat $DIFF |grep "<"` ]]
        then
                cat $DIFF |grep "<" |awk '{print $2" not in mnttab"}' >> $FINAL
        fi

# If $FINAL is not empty then notify else echo stamp to log file

if [[ -s $FINAL ]]
then
        cat $FINAL | mailx -s "$HOST P1: Check mounted" $UXSUPPMAIL
	(sh $SMS $UXSUPPSMS "$HOST P1: Check mounted `wc -l $FINAL` differences")
	cat $FINAL |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P1","'"$LOGDES"'","'"$ZONE"'",$0}' >> $LOG
	cat $FINAL |awk '{print "'"$DATE"'","'"$HOSTLOGNAME"'","P1","'"$LOGDES"'","'"$ZONE"'",$0}' >> $MASTERLOG

else
        echo $DATE stamp >> $LOG
fi

# Remove temporary files

rm      $ZOUT           \
        $DFOUT          \
        $DIFF           \
        $FINAL          \
