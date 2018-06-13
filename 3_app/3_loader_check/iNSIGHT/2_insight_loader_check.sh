#!/usr/bin/ksh
# Check if already running

SCRIPT=`basename $0`
if [ `ps -ef | grep $SCRIPT | grep -v grep | wc -l` -gt 3 ]; then
	echo "already running"
	exit 1
fi

#
### iNSIGHT Loader speed monitor - tested on Solaris 10 #########################
#
# Run in cron every hour:
# 0 * * * * /4csysmon/3_app/3_loader_check/iNSIGHT/2_insight_loader_check.sh > /dev/null 2>&1
#
# Create the RRD for each loader & keep data for        month (44640 minutes)
#                                                       year (525600 minutes)
#
#
#################################################################################
WORKING_DIR="/4csysmon/3_app/3_loader_check/iNSIGHT"
ORAWRKG_DIR="/4csysmon/3_app/3_loader_check/iNSIGHT/db"
cd $WORKING_DIR
ORA_STATS="1_oracle_stats.sh"
LOADERDIR="/insight/log"
LOADERLOG=${LOADERDIR}/load.log
LOADERTMP=tmploader.log
LOADERS=4_insight_loaders.conf
FLE_EXT="_`date +%y_%m_%d.log`"
LOADERDAILY_DONE="LOADERDAILYDONE${FLE_EXT}"
LOADERDAILY_LOG="_LOADERDAILYLOG${FLE_EXT}"
LOADER_RRD="_LOADER.rrd"
RRDTOOL="/usr/local/rrdtool-1.2.19/bin/rrdtool"
UPDATELDR="3_update_rrd.sh"
CNT=1
TMP_LOG="LDRTMP_LOG"
LDRCHK_LOG="insight_loader_check.log"
#################################################################################
###
###
### Check to see if one is running already
PSCNT="`ps -ef |grep -i "insight_loader_check.sh" | grep -iv grep | wc -l | awk '{print $1}'`"
if [ ${PSCNT} -gt 1 ]
        then
                echo "......... ${PSCNT} insight_loader_checks running already `date` ........" >> ${LDRCHK_LOG}
                exit 1
fi
###
###
### Update Loaders that is done.
touch $LOADERTMP
touch ${TMP_LOG}
cp $LOADERLOG $LOADERTMP
#
if [ -f "${LOADERDAILY_DONE}" ]
        then
                cat ${LOADERTMP} | grep -i " Done (" > ${TMP_LOG}
                diff ${LOADERDAILY_DONE} ${TMP_LOG} | grep -i "> " |sed 's/> //' >> ${LOADERDAILY_DONE}
        else
                cat ${LOADERTMP} | grep -i " Done (" > ${LOADERDAILY_DONE}
fi
###
###
### CREATE & UPDATE the Log's & RRD's: ##########################################
export LDRCHK_LOG=${LDRCHK_LOG}
export LOADERDAILY_DONE=${LOADERDAILY_DONE}
export LOADERDAILY_LOG=${LOADERDAILY_LOG}
export LOADER_RRD=${LOADER_RRD}
cat ${LOADERS} | grep -iv "#" | while read FLE LDR
do
        CNT=`expr ${CNT} + 1`
        export CNT=${CNT}
        export FLE=${FLE}
        export LDR=${LDR}
        ${WORKING_DIR}/${UPDATELDR} &
        sleep 1
done
rm ${TMP_LOG}
###
### Get the Oracle stats:
${ORAWRKG_DIR}/${ORA_STATS}
###
### Make sure all RRD's are updated.
RRDPRCS=`ps -ef | grep -i ${UPDATELDR} | grep -v grep | wc -l |awk '{print $1}'`
while [ ${RRDPRCS} -ge 1 ]
do
        sleep 2
        RRDPRCS=`ps -ef | grep -i ${UPDATELDR} | grep -v grep | wc -l |awk '{print $1}'`
done
###
### GRAPH the RRD's:    #########################################################
### Daily total Records per second ###
#
${RRDTOOL} graph Total_Daily_Loader.png \
        -t "`hostname` Total Daily Loader Stat's" -v "Records per Second" \
        --watermark "4CsysMON `date`" \
        --start="-86400" --end="now" \
        --height="180" \
        --width="900" \
        --lower-limit 0 \
        --x-grid HOUR:1:HOUR:2:HOUR:2:0:%R \
        --alt-y-grid --rigid \
        -c "BACK#F2F0FF" \
        -c "SHADEA#D7D7D7" \
        -c "SHADEB#707070" \
        -c "FONT#4D4D4D" \
        -c "CANVAS#E6E2FF" \
        -c "GRID#FFFFFF" \
        -c "MGRID#4D4D4D" \
        -c "FRAME#4D4D4D" \
        -c "ARROW#4D4D4D" \
        "DEF:ldr01=ama4_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr02=ama_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr03=fnb_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr04=iachasta_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr05=icpd_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr06=in_conf_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr07=in_ips_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr08=in_ips_serv_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr09=in_prof_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr10=in_stat_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr11=l500_dl_iccid_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr12=mms_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr13=tap_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr14=tuniexp_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr15=vxv_prof_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr16=vxv_rated_orig_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr17=vxv_rated_rerate_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr18=vxv_sub_event_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr19=vxv_wasp_LOADER.rrd:REC_SECOND:MAX" \
        "AREA:ldr01#525BF0:AMA4 Records per Second" \
        "AREA:ldr02#111781:AMA Records per Second:STACK" \
        "AREA:ldr03#808196:FNB Records per Second:STACK" \
        "AREA:ldr04#9199FC:iachasta Records per Second:STACK" \
        "AREA:ldr05#C8C8C8:icpd Records per Second:STACK" \
        "AREA:ldr06#FFC800:in_conf Records per Second:STACK" \
        "AREA:ldr07#FFFF00:in_ips Records per Second:STACK" \
        "AREA:ldr08#FFFFC8:in_ips_serv Records per Second:STACK" \
        "AREA:ldr09#0000FF:in_prof Records per Second:STACK" \
        "AREA:ldr10#000064:in_stat Records per Second:STACK" \
        "AREA:ldr11#0000C8:l500_dl_iccid Records per Second:STACK" \
        "AREA:ldr12#00FF00:MMS Records per Second:STACK" \
        "AREA:ldr13#00FFC8:TAP Records per Second:STACK" \
        "AREA:ldr14#00FFFF:TunieXP Records per Second:STACK" \
        "AREA:ldr15#3264FF:vxv_prof Records per Second:STACK" \
        "AREA:ldr16#640000:vxv_rated_orig Records per Second:STACK" \
        "AREA:ldr17#646400:vxv_rated_rerate Records per Second:STACK" \
        "AREA:ldr18#6464C8:vxv_sub_event Records per Second:STACK" \
        "AREA:ldr19#6464FF:vxv_wasp Records per Second:STACK"
#
### Weekly total Records per second ###
#
${RRDTOOL} graph Total_Weekly_Loader.png \
        -t "`hostname` Total Weekly Loader Stat's" -v "Records per Second" \
        --watermark "4CsysMON `date`" \
        --start="-1w" --end="now" \
        --height="180" \
        --width="900" \
        --lower-limit 0 \
        --x-grid HOUR:4:HOUR:12:DAY:1:0:%a \
        --alt-y-grid --rigid \
        -c "BACK#F2F0FF" \
        -c "SHADEA#D7D7D7" \
        -c "SHADEB#707070" \
        -c "FONT#4D4D4D" \
        -c "CANVAS#E6E2FF" \
        -c "GRID#FFFFFF" \
        -c "MGRID#4D4D4D" \
        -c "FRAME#4D4D4D" \
        -c "ARROW#4D4D4D" \
        "DEF:ldr01=ama4_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr02=ama_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr03=fnb_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr04=iachasta_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr05=icpd_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr06=in_conf_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr07=in_ips_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr08=in_ips_serv_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr09=in_prof_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr10=in_stat_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr11=l500_dl_iccid_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr12=mms_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr13=tap_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr14=tuniexp_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr15=vxv_prof_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr16=vxv_rated_orig_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr17=vxv_rated_rerate_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr18=vxv_sub_event_LOADER.rrd:REC_SECOND:MAX" \
        "DEF:ldr19=vxv_wasp_LOADER.rrd:REC_SECOND:MAX" \
        "AREA:ldr01#525BF0:AMA4 Records per Second" \
        "AREA:ldr02#111781:AMA Records per Second:STACK" \
        "AREA:ldr03#808196:FNB Records per Second:STACK" \
        "AREA:ldr04#9199FC:iachasta Records per Second:STACK" \
        "AREA:ldr05#C8C8C8:icpd Records per Second:STACK" \
        "AREA:ldr06#FFC800:in_conf Records per Second:STACK" \
        "AREA:ldr07#FFFF00:in_ips Records per Second:STACK" \
        "AREA:ldr08#FFFFC8:in_ips_serv Records per Second:STACK" \
        "AREA:ldr09#0000FF:in_prof Records per Second:STACK" \
        "AREA:ldr10#000064:in_stat Records per Second:STACK" \
        "AREA:ldr11#0000C8:l500_dl_iccid Records per Second:STACK" \
        "AREA:ldr12#00FF00:MMS Records per Second:STACK" \
        "AREA:ldr13#00FFC8:TAP Records per Second:STACK" \
        "AREA:ldr14#00FFFF:TunieXP Records per Second:STACK" \
        "AREA:ldr15#3264FF:vxv_prof Records per Second:STACK" \
        "AREA:ldr16#640000:vxv_rated_orig Records per Second:STACK" \
        "AREA:ldr17#646400:vxv_rated_rerate Records per Second:STACK" \
        "AREA:ldr18#6464C8:vxv_sub_event Records per Second:STACK" \
        "AREA:ldr19#6464FF:vxv_wasp Records per Second:STACK"
#
### Daily Loader Detail Records per second ###
#
cat ${LOADERS} | grep -iv "#" | while read FLE LDR
do
${RRDTOOL} graph ${FLE}_Daily_Loader.png \
        -t "`hostname` ${FLE} Daily Loader Stat's detail" -v "Records per Second" \
        --watermark "4CsysMON `date`" \
        --start="-86400" --end="now" \
        --height="180" \
        --width="900" \
        --lower-limit 0 \
        --x-grid HOUR:1:HOUR:2:HOUR:2:0:%R \
        --alt-y-grid --rigid \
        -c "BACK#F2F0FF" \
        -c "SHADEA#D7D7D7" \
        -c "SHADEB#707070" \
        -c "FONT#4D4D4D" \
        -c "CANVAS#E6E2FF" \
        -c "GRID#FFFFFF" \
        -c "MGRID#4D4D4D" \
        -c "FRAME#4D4D4D" \
        -c "ARROW#4D4D4D" \
        "DEF:rcs=${FLE}${LOADER_RRD}:REC_SECOND:MAX" \
        "AREA:rcs#525BF0:Records per Second\l" \
        "GPRINT:rcs:LAST:Last\: %5.2lf Recs sec\r" \
        "GPRINT:rcs:MAX:Max\: %5.2lf Recs sec\l" \
        "GPRINT:rcs:MIN:Min\: %5.2lf Recs sec\r" \
        "GPRINT:rcs:AVERAGE:Avg\: %5.2lf Recs sec\l"
done
#
#
### Weekly Loader Detail Records per second ###
#
cat ${LOADERS} | grep -iv "#" | while read FLE LDR
do
${RRDTOOL} graph ${FLE}_Weekly_Loader.png \
        -t "`hostname` ${FLE} Weekly Loader Stat's detail" -v "Records per Second" \
        --watermark "4CsysMON `date`" \
        --start="-1w" --end="now" \
        --height="180" \
        --width="900" \
        --lower-limit 0 \
        --x-grid HOUR:4:HOUR:12:DAY:1:0:%a \
        --alt-y-grid --rigid \
        -c "BACK#F2F0FF" \
        -c "SHADEA#D7D7D7" \
        -c "SHADEB#707070" \
        -c "FONT#4D4D4D" \
        -c "CANVAS#E6E2FF" \
        -c "GRID#FFFFFF" \
        -c "MGRID#4D4D4D" \
        -c "FRAME#4D4D4D" \
        -c "ARROW#4D4D4D" \
        "DEF:rcs=${FLE}${LOADER_RRD}:REC_SECOND:MAX" \
        "AREA:rcs#525BF0:Records per Second\l" \
        "GPRINT:rcs:LAST:Last\: %5.2lf Recs sec\r" \
        "GPRINT:rcs:MAX:Max\: %5.2lf Recs sec\l" \
        "GPRINT:rcs:MIN:Min\: %5.2lf Recs sec\r" \
        "GPRINT:rcs:AVERAGE:Avg\: %5.2lf Recs sec\l"
done
# remember to add log rotation......
#find . -name "*.log" -mtime +5 -exec rm -f {} \;
### FIN ###
