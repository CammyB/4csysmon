#!/bin/bash
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi
#
# This script collects the the backup environment policy configuration detail
#
#
PATH=$PATH:/usr/local/bin:/usr/openv/netbackup/bin:/usr/openv/volmgr/bin:/usr/openv/netbackup/bin/admincmd/
DEFPATH=/4csysmon/1_unix/5_sysadmin/1_nbu/1_stats

OUTPUT=$DEFPATH/config_pol.out
SCHEDLIST_OUT=$DEFPATH/schedlist.out

if [ -f $DEFPATH/config_pol.out ]; then
        rm $OUTPUT
fi

if [ -f $DEFPATH/shedlist.out ]; then
        rm $SCHEDLIST_OUT
fi

SITE="VCL"
FILEDATE=`date +"%Y%m%d%H%M%S"`
#MAILOUTPUT="$DEFPATH/BCKP_CONF_POL_$FILEDATE_$SITE"
MAILOUTPUT=BCK_CONF_POL_"$FILEDATE"_"$SITE"
DATE=`date +"%a %b %d %H:%M:%S %Y"`

echo "Record Date|Site|Record Type|Policy Name|Policy Type|Policy Enabled|Policy Residence|Volume Pool|Client|OS|Schedule Count|Schedule Name|Schedule Type|is Calender Schedule|is Frequency Schedule|Run Times" > $OUTPUT

#for j in `/usr/openv/netbackup/bin/admincmd/bppllist |  head -5`; do

for j in `/usr/openv/netbackup/bin/admincmd/bppllist`; do
        POLNAME=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Policy Name:" | awk {'print $3'}`
        POLTYPE=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Policy Type:" | awk {'print $3'}`
        POLENABLED=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Active:" | awk {'print $2'}`
        POLRES=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Residence:" | awk {'print $2'} | head -1`
        POLPOOL=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Volume Pool:" | awk {'print $3'} | head -1`


        if [ `/usr/openv/netbackup/bin/admincmd/bppllist $j -U | egrep "Clients:|Client:" | awk '{print $NF}'` == "defined)" ]; then
                CLIENT="N/A"
                CLIENTOS="N/A"
                else
                        CLIENT=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | egrep "Clients:|Client:" | awk '{print $NF}'`
                        CLIENTOS=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Client:" | awk {'print $2" "$3'}`
        fi

        SCHEDCOUNT=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Schedule:" | wc -l`
        SCHEDLIST=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | grep "Schedule:" | awk {'print $2'} >> $SCHEDLIST_OUT`

        for ((i=1;i<=$SCHEDCOUNT;i++));
        do
                SCHEDLIST_OUT="$DEFPATH/schedlist.out"
                SCHEDNAME=`sed -n "$i"p $SCHEDLIST_OUT`
                SCHEDTYPE=`/usr/openv/netbackup/bin/admincmd/bppllist $j -U | /usr/sfw/bin/ggrep -A4 $SCHEDNAME | grep "Type:" |tail -1|awk '{$1=""; print $0}'`

                if [ `/usr/openv/netbackup/bin/admincmd/bppllist $j -U | /usr/sfw/bin/ggrep -A22 $SCHEDNAME | grep  -c "Calendar sched: Enabled"` -gt 0 ]; then

                        SCHEDCAL="Y"
                        SCHEDFREQ="N"

                        COUNT=`bpplsched $j -label  $SCHEDNAME -U | /usr/sfw/bin/ggrep -A25 "Daily Windows:" | cat -n | tail -1 | awk {'print $1'}`
                        LCOUNT=$(bc <<< "$COUNT-1")

                        SCHEDRUNDAY=`bpplsched $j -label  $SCHEDNAME -U | /usr/sfw/bin/ggrep -A25 "Daily Windows:" | tail -$LCOUNT`


                elif [ `/usr/openv/netbackup/bin/admincmd/bppllist $j -U | /usr/sfw/bin/ggrep -A22 $SCHEDNAME | grep  -c "Frequency:"` -gt 0 ]; then

                        SCHEDCAL="N"
                        SCHEDFREQ="Y"
                        SCHEDRUNDAY=`bpplsched $j -label  $SCHEDNAME -U | /usr/sfw/bin/ggrep -A25 "Daily Windows:" | tail -$LCOUNT`

                elif [ `/usr/openv/netbackup/bin/admincmd/bppllist $j -U | /usr/sfw/bin/ggrep -A22 $SCHEDNAME | grep  -c "Frequency:"` -eq 0 ]; then

                        SCHEDFREQ="N/A"
                if [ `/usr/openv/netbackup/bin/admincmd/bppllist $j -U | /usr/sfw/bin/ggrep -A22 $SCHEDNAME | grep  -c "Calendar sched: Enabled"` -eq 0 ]; then
                        SCHEDCAL="N/A"
                fi

                fi




echo "`echo $FILEDATE`|`echo $SITE`|`echo PolicyConfig`|`echo $POLNAME`|`echo $POLTYPE`|`echo $POLENABLED`|`echo $POLRES`|`echo $POLPOOL`|`echo $CLIENT`|`echo $CLIENTOS`|`echo $SCHEDCOUNT`|`echo $SCHEDNAME`|`echo $SCHEDTYPE`|`echo $SCHEDCAL`|`echo $SCHEDFREQ`|`echo $SCHEDRUNDAY`" >> $OUTPUT

done
rm $SCHEDLIST_OUT
done

cd $DEFPATH
cp $OUTPUT $MAILOUTPUT
#/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "$SITE NBU Policy Configuration Stats" laramy.starbuck@4cgroup.co.za
/usr/bin/uuencode $MAILOUTPUT $MAILOUTPUT | /usr/bin/mailx -s "Performance Monitor" monitor@4cgroup.co.za

rm $OUTPUT
