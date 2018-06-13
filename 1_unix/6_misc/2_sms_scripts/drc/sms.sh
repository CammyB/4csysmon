#!/usr/bin/sh

sms_host=10.200.8.230

if [ $# -eq 2 ]
  then
    cd /mis/bin
    /usr/bin/java SendDrcSms $sms_host $1 $2
else
    echo "usage: $0 msisdn \"message\""
fi
