#!/bin/bash
#
# Solaris 10 certified
# File name:    latancy_check.sh
# Syntax:       latancy_check.sh
# Prereq's:     rrdtool
#               system.list file looking like this:
# VTZN Host Latancy to be checked
# -------------------------------
# IP Address    Hostname_RRD
# -------------------------------
### NSN ###
#172.16.43.10    NSN_CUA.rrd
#
# Put in cron every 5 min:
#/4csysmon/1_unix/3_io/2_network/1_latency_check/latancy_check.sh
##########################################################
#
WRDIR="/4csysmon/1_unix/3_io/2_network/1_latency_check"
cd $WRDIR
SYSTEMS=system.lst
PING=/usr/sbin/ping
RRDTOOL="/usr/local/rrdtool-1.2.19/bin/rrdtool"
#
##########################################################
### Check to see if one is running already
PSCNT="`ps -ef |grep -i "latancy_check.sh" | grep -iv grep | wc -l | awk '{print $1}'`"
if [ ${PSCNT} -gt 4 ]
        then
                echo "......... ${PSCNT} Latancy Check running already `date` ........"
                exit 1
fi
###
if [[ -f "$SYSTEMS" ]]
        then
                echo "$SYSTEMS is there"
        else
                exit 1
fi
##########################################################
PING_HOST() {
OUTPT=$($PING -s $IPADDR 64 4 2>&1)
L_PL=$(echo "$OUTPT" | awk '/packets transmitted/{print $7+0}')
L_RTT=$(echo "$OUTPT" | grep -i avg |awk -F"/" '{print $6}')
}
##########################################################
cat $SYSTEMS | grep -iv "#" | while read IPADDR HOSTNM
do
PING_HOST $IPADDR
if [[ -f "$HOSTNM" ]]
        then
                $RRDTOOL update $HOSTNM --template pl:rrt N:$L_PL:$L_RTT
        else
                $RRDTOOL create $HOSTNM --step 300 DS:pl:GAUGE:600:0:100 DS:rrt:GAUGE:600:0:10000000 RRA:AVERAGE:0.5:1:800 RRA:AVERAGE:0.5:6:800 RRA:AVERAGE:0.5:24:800 RRA:AVERAGE:0.5:288:800 RRA:MAX:0.5:1:800 RRA:MAX:0.5:6:800 RRA:MAX:0.5:24:800 RRA:MAX:0.5:288:800
                $RRDTOOL update $HOSTNM --template pl:rrt N:$L_PL:$L_RTT
fi
done
##########################################################
cat $SYSTEMS | grep -iv "#" | while read IPADDR HOSTNM
do
HOSTNMM=$(echo "$HOSTNM" | sed 's/\(.*\)..../\1/')
echo $HOSTNMM
### Daily Graph ###
/usr/local/rrdtool-1.2.19/bin/rrdtool graph $HOSTNMM.daily_latency.png \
-w 800 -h 160 -a PNG \
--slope-mode \
--start -86400 --end now \
--font DEFAULT:7: \
--title "$HOSTNMM Daily Latency" \
--watermark "`date`" \
--vertical-label "latency(ms)" \
--lower-limit 0 \
--x-grid MINUTE:10:HOUR:1:MINUTE:120:0:%R \
--alt-y-grid --rigid \
DEF:roundtrip=$HOSTNMM.rrd:rrt:MAX \
DEF:packetloss=$HOSTNMM.rrd:pl:MAX \
CDEF:PLNone=packetloss,0,0,LIMIT,UN,UNKN,INF,IF \
CDEF:PL10=packetloss,1,10,LIMIT,UN,UNKN,INF,IF \
CDEF:PL25=packetloss,10,25,LIMIT,UN,UNKN,INF,IF \
CDEF:PL50=packetloss,25,50,LIMIT,UN,UNKN,INF,IF \
CDEF:PL100=packetloss,50,100,LIMIT,UN,UNKN,INF,IF \
LINE1:roundtrip#0000FF:"latency(ms)" \
GPRINT:roundtrip:LAST:"Cur\: %5.2lf" \
GPRINT:roundtrip:AVERAGE:"Avg\: %5.2lf" \
GPRINT:roundtrip:MAX:"Max\: %5.2lf" \
GPRINT:roundtrip:MIN:"Min\: %5.2lf\t\t\t" \
COMMENT:"pkt loss\:" \
AREA:PLNone#FFFFFF:"0%":STACK \
AREA:PL10#FFFF00:"1-10%":STACK \
AREA:PL25#FFCC00:"10-25%":STACK \
AREA:PL50#FF8000:"25-50%":STACK \
AREA:PL100#FF0000:"50-100%":STACK
done
##########################################################
### FIN ###
