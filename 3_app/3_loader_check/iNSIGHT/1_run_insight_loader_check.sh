#!/usr/bin/sh
# To run 2_insight_loader_check.sh from root cron.
#
# Run in cron every 1 min:
# 0,5,10,15,20,25,30,35,40,45,50,55 * * * * /usr/bin/ksh /4csysmon/3_app/3_loader_check/iNSIGHT/1_run_insight_loader_check.sh > /dev/null 2>&1
#
/4csysmon/3_app/3_loader_check/iNSIGHT/2_insight_loader_check.sh > /dev/null 2>&1
