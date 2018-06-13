#!/usr/bin/sh
################################################################
#
# Script to ftp xml files to sms server 
#
# SCRipt created by HAno Strauss
# date: Mon Mar 15 17:51:55 EAT 2004
#
#################################################################


sms_host=10.10.96.135
user=eppix
pass=eppix00

clean_up()
{
  rm  -f /tmp/sms.xml.$$
}

create_xml()
{ 
echo "
<gviSmsMessage>\
 <affiliateCode>VOD003</affiliateCode>\
 <authenticationCode> </authenticationCode>\
 <serviceCode>VOD003_4CIT_FILE_SMS</serviceCode>\
 <submitDateTime>\
  `date`\
 </submitDateTime>\
 <messageType>text</messageType>\
 <recipientList>\
  <message>\
   $2 \
  </message>\
  <recipient>\
   <msisdn>\
$1\
</msisdn>\
  </recipient>\
  </recipientList>\
</gviSmsMessage>
" > /tmp/sms.xml.$$
}

send_message()
{
cd /tmp
ftp -n $sms_host << EOF
 user $user $pass
 put sms.xml.$$
 quit
EOF
} 
#
#
# MAIN SCRIPT
# 
number=`echo $1 |sed s/+//g`

if [ $# -eq 2 ] ;then 
 if create_xml $number "$2" ;then
  if send_message ;then
   logger  Message send  to $1
   clean_up 
  else
   logger $0 Failed to send messages to $1 $2
   exit
  fi
 fi
else
 echo "usage: $0 <isdnumber> \"<message>\""
 exit
fi
exit 
