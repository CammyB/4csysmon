#!/bin/bash
#
#
DEFPATH=/4csysmon/1_unix
APPDEFPATH=/4csysmon/3_app/4_error_dup_check
. $DEFPATH/6_misc/global_parameters.list

LOC=/insight/locate/data/

find $LOC -name error -type d  >> $APPDEFPATH/insight.errorlog.list
find $LOC -name dup -type d  >> $APPDEFPATH/insight.duplog.list
xemails="servicedesk@4cgroup.co.za,faeez.isaacs@4cgroup.co.za,Phillip.DeBeer@4cgroup.co.za,Aston.Kerchhoff@4cgroup.co.za,Applicationsupport@4cit.co.za"


for j in `cat $APPDEFPATH/insight.errorlog.list`;do find $j -type f -name '*' -mtime 0;done >> $APPDEFPATH/insight.errorlog2.list 

req_val=0
req_val2=1
wc=`cat $APPDEFPATH/insight.errorlog2.list |wc -l` 

if [ $wc -eq $req_val ] ; then echo -e "----------";echo "equal" ; else cat $APPDEFPATH/insight.errorlog2.list | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST ERROR FILES FOUND" $xemails; fi;

for j in `cat $APPDEFPATH/insight.errorlog.list`;do line=`ls -l $j| wc -l`;if [ $line -eq $req_val2 ] ;\
then echo "$j has No Error Files"; else echo "ERROR FILES FOUND" ;cd $j;echo -e 'Moving the Following Files \n';ls -l |awk '{print $9}';mv ./* ../;fi;done


for j in `cat $APPDEFPATH/insight.duplog.list`;do find $j -type f -name '*' -mtime 0;done >> $APPDEFPATH/insight.duplog2.list 
req_val=0
req_val2=1
wc=`cat $APPDEFPATH/insight.duplog2.list |wc -l` 

if [ $wc -eq $req_val ] ; then echo -e "----------";echo "equal" ; else cat $APPDEFPATH/insight.duplog2.list | mailx -r "$SYSMONMAIL" -s "@4CSD@$HOST DUP FILES FOUND" $xemails; fi;

for j in `cat $APPDEFPATH/insight.duplog.list`;do line=`ls -l $j| wc -l`;if [ $line -eq $req_val2 ] ;\
then echo "$j has No Error Files"; else echo "DUP FILES FOUND" ;cd $j;echo -e 'Moving the Following Files \n';ls -l |awk '{print $9}';mv ./* ../;fi;done


rm $APPDEFPATH/insight.errorlog*
rm $APPDEFPATH/insight.duplog*
