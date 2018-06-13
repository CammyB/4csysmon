#!/usr/bin/ksh
#
# Spawned from 2_insight_loader_check.sh to update the RRD's every hour.
# Note the variable dependancies here.
#
WORKING_DIR="/4csysmon/3_app/3_loader_check/iNSIGHT"
cd $WORKING_DIR
export RDFLE=${FLE}
export RDLDR=${LDR}
TMP_LOG=${CNT}_TMPLOG
RCD_TME=${CNT}_RCD_TME
RCD_CNT=${CNT}_RCD_CNT
RCD_LOD=${CNT}_RCD_LOD
RRDTOOL="/usr/local/rrdtool-1.2.19/bin/rrdtool"
#
#
#
touch ${TMP_LOG}
touch ${RCD_TME}
touch ${RCD_CNT}
touch ${RCD_LOD}
###
### Create the log's & values.
###
        if [ -f "${RDFLE}${LOADERDAILY_LOG}" ]
                then
                        cat ${LOADERDAILY_DONE} | grep -i "${RDLDR}" |awk -F"(" '{print $1, $NF}' | awk '{print $1, $5, $6}' | while read one two three
                        do
                                echo ${one} `echo ${two}|sed 's/.\(.*\).../\1/'` `echo ${three}|sed 's/....\(.*\)./\1/'` >> $TMP_LOG
                        done
                        diff ${RDFLE}${LOADERDAILY_LOG} $TMP_LOG | grep -i "> " |sed 's/> //' | awk '{sum += $2} END {print sum/1000;}' > ${RCD_TME}
                        diff ${RDFLE}${LOADERDAILY_LOG} $TMP_LOG | grep -i "> " |sed 's/> //' | awk '{sum += $3} END {print sum}' > ${RCD_CNT}
                        diff ${RDFLE}${LOADERDAILY_LOG} $TMP_LOG | grep -i "> " |sed 's/> //' >> ${RDFLE}${LOADERDAILY_LOG}
                        RCD_TME_CNT="`cat ${RCD_TME}`"
                        RCD_CNT_CNT="`cat ${RCD_CNT}`"
                        if [ "${RCD_TME_CNT}" -lt 1 ]
                                then
                                        echo 1 > ${RCD_TME}
                        fi
                        if [ "${RCD_CNT_CNT}" -lt 1 ]
                                then
                                        echo 1 > ${RCD_CNT}
                        fi
                        echo "scale=2; `cat ${RCD_CNT}` / `cat ${RCD_TME}`" | bc | grep -iv divide | awk '{print $1}' > ${RCD_LOD}
                        RCD_LOD_CNT="`cat ${RCD_LOD}`"
                else
                        cat ${LOADERDAILY_DONE} | grep -i "${RDLDR}" |awk -F"(" '{print $1, $NF}' | awk '{print $1, $5, $6}' | while read one two three
                        do
                                echo ${one} `echo ${two}|sed 's/.\(.*\).../\1/'` `echo ${three}|sed 's/....\(.*\)./\1/'` >>  ${RDFLE}${LOADERDAILY_LOG}
                        done
                        cat ${RDFLE}${LOADERDAILY_LOG} | awk '{sum += $2} END {print sum/1000;}' > ${RCD_TME}
                        cat ${RDFLE}${LOADERDAILY_LOG} | awk '{sum += $3} END {print sum}' > ${RCD_CNT}
                        RCD_TME_CNT="`cat ${RCD_TME}`"
                        RCD_CNT_CNT="`cat ${RCD_CNT}`"
                        if [ "${RCD_TME_CNT}" -lt 1 ]
                                then
                                        echo 1 > ${RCD_TME}
                        fi
                        if [ "${RCD_CNT_CNT}" -lt 1 ]
                                then
                                        echo 1 > ${RCD_CNT}
                        fi
                        echo "scale=2; `cat ${RCD_CNT}` / `cat ${RCD_TME}`" | bc | grep -iv divide | awk '{print $1}' > ${RCD_LOD}
                        RCD_LOD_CNT="`cat ${RCD_LOD}`"
        fi
###
### Update the RRD's
###
        if [ -f "${RDFLE}${LOADER_RRD}" ]
                then
                        echo "update ${RDFLE}${LOADER_RRD} `cat ${RCD_CNT}`    `cat ${RCD_TME}`    `cat ${RCD_LOD}`" >> ${LDRCHK_LOG}
                        ${RRDTOOL} update ${RDFLE}${LOADER_RRD} --template RECORDS:REC_TIME:REC_SECOND N:`cat ${RCD_CNT}`:`cat ${RCD_TME}`:`cat ${RCD_LOD}`
                else
                        ${RRDTOOL} create ${RDFLE}${LOADER_RRD} --step 3600 DS:RECORDS:GAUGE:7200:0:200000 DS:REC_TIME:GAUGE:7200:0:200000 DS:REC_SECOND:GAUGE:7200:0:200000 RRA:MAX:0.5:1:525600
                        echo "update ${RDFLE}${LOADER_RRD} `cat ${RCD_CNT}`    `cat ${RCD_TME}`    `cat ${RCD_LOD}`" >> ${LDRCHK_LOG}
                        ${RRDTOOL} update ${RDFLE}${LOADER_RRD} --template RECORDS:REC_TIME:REC_SECOND N:`cat ${RCD_CNT}`:`cat ${RCD_TME}`:`cat ${RCD_LOD}`
        fi
#
rm ${TMP_LOG}
rm ${RCD_TME}
rm ${RCD_CNT}
rm ${RCD_LOD}
#
### FIN ###
