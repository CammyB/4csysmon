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

DEFPATH=/root/bin/nbu_policy_changes

DATE=`date '+%D %T'`
LOG=$DEFPATH/nbu_policy_changes.log
TODAYDIR=$DEFPATH/nbu_policy_changes_today
YESTDIR=$DEFPATH/nbu_policy_changes_yest
BPPLLIST_OUT=$DEFPATH/nbu_policy_changes_bppllist.out
MAILBODY=$DEFPATH/nbu_policy_changes_mail.out
MARKER=$DEFPATH/nbu_policy_changes_policies.tmp



################
# Main Program #
################

# Create the folders, if they exist don't print the error

touch $MARKER
mkdir $TODAYDIR $YESTDIR 2>/dev/null

# Generate a list with all policy names in it

/usr/openv/netbackup/bin/admincmd/bppllist > $BPPLLIST_OUT

# If $TODAYDIR contains stuff then empty $YESTDIR and move the contents of $TODAYDIR to $YESTDIR 

if [ -n `ls $TODAYDIR |head -1` ]; then
rm $YESTDIR/*
mv $TODAYDIR/* $YESTDIR
fi

# Loop round all policy names and capture the policy's attributes

for policy in `cat $BPPLLIST_OUT`
do

   /usr/openv/netbackup/bin/admincmd/bpplinfo $policy -L > $TODAYDIR/$policy
   echo >> $TODAYDIR/$policy
   /usr/openv/netbackup/bin/admincmd/bpplclients $policy >> $TODAYDIR/$policy
   echo >> $TODAYDIR/$policy
   /usr/openv/netbackup/bin/admincmd/bpplsched $policy -U >> $TODAYDIR/$policy

done

# If $YESTDIR is empty then populate it with $TODAYDIR's info so that the script doesn't end in error, it may be empty because it was newly created

if [ -z `ls $YESTDIR |head -1` ]; then
cp $TODAYDIR/* $YESTDIR
fi

echo > $MAILBODY
echo `/usr/openv/netbackup/bin/admincmd/bppllist | wc -l` Policies found: Changes listed below >> $MAILBODY
echo >> $MAILBODY

# Check if policies were added

for currentpolicies in `ls -1 $TODAYDIR`;
do
   if [ `ls $YESTDIR/$currentpolicies 2>/dev/null | wc -l | awk '{ print $1 }'` -eq 0 ];then
        echo "New policy found since yesterday: $currentpolicies" >> $MAILBODY
        echo "$DATE New policy found since yesterday: $currentpolicies" >> $LOG
        echo $DATE >> $MARKER
   fi
done

echo >> $MAILBODY

# Check if policies were removed

for previouspolicies in `ls -1 $YESTDIR` ; do
  if [ `ls $TODAYDIR/$previouspolicies 2>/dev/null | wc -l | awk '{ print $1 }'` -eq 0 ];then
      echo "Policy removed since yesterday: $previouspolicies" >> $MAILBODY
      echo "$DATE Policy removed since yesterday: $previouspolicies" >> $LOG
      echo $DATE >> $MARKER
  fi
done

echo >> $MAILBODY

# Compare the policy attributes between today and yesterday

for policyfile in `ls -1 $TODAYDIR`;do
   
   if [ "`diff $YESTDIR/$policyfile $TODAYDIR/$policyfile 2>/dev/null |egrep '>|<'`" -neq "" ];then
      echo "Change found in policy: $policyfile" >> $MAILBODY
      echo "$DATE Change found in policy: $policyfile" >> $LOG
      echo "===============================================" >> $MAILBODY
      diff $YESTDIR/$policyfile $TODAYDIR/$policyfile >> $MAILBODY
      echo $DATE >> $MARKER
      echo >> $MAILBODY
   fi

done

# If $MARKER is blank then echo a stamp to the log; if $MARKER contains something then mail out $MAILBODY

        if [[ -z `cat $MARKER` ]];then
        echo $DATE stamp >> $LOG
        else
#        cat $MAILBODY | mailx -s "NBU Policy report for $HOST" unixsupport@4cit.co.za
	cat $SDTEMP $MAILBODY | mailx -r "$SYSMONMAIL" -s "NBU Policy report for $HOST" $SERVICEDESKMAIL
        fi

# Remove the temporary file

rm $MARKER
