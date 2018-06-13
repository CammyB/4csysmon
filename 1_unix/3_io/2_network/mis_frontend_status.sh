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

IP=10.10.96.51
PORT=80

DEFPATH=/4csysmon/1_unix

LOG=$DEFPATH/3_io/2_network/mis_frontend_status.log

. $DEFPATH/6_misc/global_parameters.list

################
# Main Program #
################

# Ping IP and notify if failed

        if [ `/usr/sbin/ping $IP |awk '{print $3}'` != "alive" ]
                then

		echo "Please check Mis Frontend System IP:$IP" | mailx -4 "$SYSMONMAIL" -s "$HOST P1: Failure mis-frontend Ping" $SERVICEDESKMAIL
#               echo "Please check Mis Frontend System IP:$IP" | mailx -s "$HOST P1: Failure mis-frontend Ping" $UXSUPPMAIL
#               (sh $SMS $UXSUPPSMS "$HOST P1: Failure mis-frontend Ping to $IP")
                echo $DATE $HOSTLOGNAME P1 mis__frontend_status ping FAILURE $IP >> $LOG
		else
                echo $DATE Ping stamp >> $LOG
        fi

# Check if port $PORT on $IP is up, if not, then notify.

exec 3>/dev/tcp/$IP/$PORT

if [[ `echo $?` != 0 ]]
	then
	echo "Please check Web services Port $PORT" | mailx -r "$SYSMONMAIL" -s "$HOST P1: Webservices mis-frontend down" $SERVICEDESKMAIL
#        echo "Please check Web services Port $PORT" | mailx -s "$HOST P1: Webservices mis-frontend down" $UXSUPPMAIL $VTLSUPPMAIL
#        (sh $SMS $UXSUPPSMS "$HOST P1: Please check webservices for mis-frontend Port $PORT")
        echo $DATE $HOSTLOGNAME P1 mis__frontend_status port $PORT DOWN >> $LOG
	else
        echo $DATE Port stamp >> $LOG
fi
