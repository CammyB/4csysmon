#!/bin/bash
#
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

###############################################################################################
# Get the VNX Log's
# Need the controler list file (vnx_cntrl.list) with entries like this:
# Hostname      IP Address
#TZVODANETAPP01  10.10.94.17
#
#
# Put it in cron
#0 7,22 * * * /4csysmon/1_unix/3_io/1_storage/3_vnx/vnx_mess.sh > /dev/null 2>&1
#
###############################################################################################
WRKDIR=/4csysmon/1_unix/3_io/1_storage/3_vnx
CNTLR_LIST=vnx_cntrl.list
RCMD="/opt/Navisphere/bin/naviseccli -h"
LOG="`date "+%d-%m-%Y"`.mess"
ERRLOG=NetApp_Storage.err
#
###############################################################################################
cd $WRKDIR
cat $WRKDIR/$CNTLR_LIST | grep -v "#" | while read HOST IP
do
        if [ -f ${HOST}_$LOG ]
                then
                        $RCMD $IP getlog > tmp_mess
                        diff ${HOST}_$LOG tmp_mess |grep -i "> " |sed 's/> //' >> "${HOST}_$LOG"
                else
                        $RCMD $IP getlog > "${HOST}_$LOG"
        fi
done
rm tmp_mess
### FIN ###
