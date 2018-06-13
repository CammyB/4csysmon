#!/usr/bin/ksh
#
# As root get all Oracle stat's
# run every hour
#
WORKING_DIR="/4csysmon/3_app/1_mis/2_Loader_Check/iNSIGHT/db"
cd $WORKING_DIR
GETORA_STATS="2_oracle_get_stats.sh"
RRDTOOL="/usr/local/rrdtool-1.2.19/bin/rrdtool"
ORA_SGA_RRD="oracle_sga.rrd"
ORA_RWIO_RRD="Oracle_RWI.rrd"
ORA_WAITSUM_RRD="Oracle_WSUM.rrd"
#
#
#
su - oracle -c "${WORKING_DIR}/${GETORA_STATS}"
### SGA Utilization:
#####################################################################
if [ -f "${ORA_SGA_RRD}" ]
	then
		${RRDTOOL} update ${ORA_SGA_RRD} --template SGA_ALLC:SGA_USED N:`cat SGA_ALLOC`:`cat SGA_USED`
	else
		${RRDTOOL} create ${ORA_SGA_RRD} --step 3600 DS:SGA_ALLC:GAUGE:7200:0:200000 DS:SGA_USED:GAUGE:7200:0:200000 RRA:MAX:0.5:1:525600
		${RRDTOOL} update ${ORA_SGA_RRD} --template SGA_ALLC:SGA_USED N:`cat SGA_ALLOC`:`cat SGA_USED`
fi
#
#
${RRDTOOL} graph Oracle_SGA_Daily.png \
        -t "`hostname` Oracle SGA Daily Utilization" -v "SGA Utilization MB/s" \
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
	"DEF:allocated=${ORA_SGA_RRD}:SGA_ALLC:MAX" \
        "DEF:used=${ORA_SGA_RRD}:SGA_USED:MAX" \
	"AREA:allocated#00FFC8:Allocated SGA\l" \
	"AREA:used#525BF0:Used SGA\l" \
	"GPRINT:used:LAST:Last\: %5.2lf MB" \
        "GPRINT:used:MIN:Min\: %5.2lf MB" \
        "GPRINT:used:MAX:Max\: %5.2lf MB" \
        "GPRINT:used:AVERAGE:Avg\: %5.2lf MB"
#
#
${RRDTOOL} graph Oracle_SGA_Weekly.png \
        -t "`hostname` Oracle SGA Weekly Utilization" -v "SGA Utilization MB/s" \
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
	"DEF:allocated=${ORA_SGA_RRD}:SGA_ALLC:MAX" \
        "DEF:used=${ORA_SGA_RRD}:SGA_USED:MAX" \
	"AREA:allocated#00FFC8:Allocated SGA\l" \
	"AREA:used#525BF0:Used SGA\l" \
	"GPRINT:used:LAST:Last\: %5.2lf MB" \
        "GPRINT:used:MIN:Min\: %5.2lf MB" \
        "GPRINT:used:MAX:Max\: %5.2lf MB" \
        "GPRINT:used:AVERAGE:Avg\: %5.2lf MB"
#
#
### Physical R/W's & IOP/s:
#####################################################################
if [ -f "${ORA_RWIO_RRD}" ]
	then
		${RRDTOOL} update ${ORA_RWIO_RRD} --template RKBPS:ROPS:WKBPS:WOPS N:`cat RWIO_UTIL | awk '{print $1}'`:`cat RWIO_UTIL | awk '{print $2}'`:`cat RWIO_UTIL | awk '{print $3}'`:`cat RWIO_UTIL | awk '{print $4}'`
	else
		${RRDTOOL} create ${ORA_RWIO_RRD} --step 3600 DS:RKBPS:GAUGE:7200:0:20000000 DS:ROPS:GAUGE:7200:0:20000000 DS:WKBPS:GAUGE:7200:0:20000000 DS:WOPS:GAUGE:7200:0:20000000 RRA:MAX:0.5:1:525600
		${RRDTOOL} update ${ORA_RWIO_RRD} --template RKBPS:ROPS:WKBPS:WOPS N:`cat RWIO_UTIL | awk '{print $1}'`:`cat RWIO_UTIL | awk '{print $2}'`:`cat RWIO_UTIL | awk '{print $3}'`:`cat RWIO_UTIL | awk '{print $4}'`
fi
#
#
### Read Writes:
${RRDTOOL} graph Oracle_RW_Daily.png \
        -t "`hostname` Oracle R/W Daily Utilization" -v "KB/s" \
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
	"DEF:rkbs=${ORA_RWIO_RRD}:RKBPS:MAX" \
	"DEF:wkbs=${ORA_RWIO_RRD}:WKBPS:MAX" \
	"AREA:rkbs#525BF0:Read KB/s\l" \
	"AREA:wkbs#00FFC8:Write KB/s\l"
#
#
### Read Writes:
${RRDTOOL} graph Oracle_RW_Weekly.png \
        -t "`hostname` Oracle R/W Weekly Utilization" -v "KB/s" \
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
	"DEF:rkbs=${ORA_RWIO_RRD}:RKBPS:MAX" \
	"DEF:wkbs=${ORA_RWIO_RRD}:WKBPS:MAX" \
	"AREA:rkbs#525BF0:Read KB/s\l" \
	"AREA:wkbs#00FFC8:Write KB/s\l"
#
#
### IOP's
${RRDTOOL} graph Oracle_IO_Daily.png \
        -t "`hostname` Oracle IOP/s Daily Utilization" -v "IO/s" \
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
        "DEF:riop=${ORA_RWIO_RRD}:ROPS:MAX" \
        "DEF:wiop=${ORA_RWIO_RRD}:WOPS:MAX" \
	"AREA:riop#525BF0:Read IOP/s\l" \
	"AREA:wiop#00FFC8:Write IOP/s\l"
#
#
### IOP's
${RRDTOOL} graph Oracle_IO_Weekly.png \
        -t "`hostname` Oracle IOP/s Weekly Utilization" -v "IO/s" \
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
        "DEF:riop=${ORA_RWIO_RRD}:ROPS:MAX" \
        "DEF:wiop=${ORA_RWIO_RRD}:WOPS:MAX" \
	"AREA:riop#525BF0:Read IOP/s\l" \
	"AREA:wiop#00FFC8:Write IOP/s\l"
#
### Database Wait Summary:
#####################################################################
DBWWAIT=`head -1 DB_WAITSUMM`
DBWCPUT=`tail -1 DB_WAITSUMM`
if [ -f "${ORA_WAITSUM_RRD}" ]
	then
		${RRDTOOL} update ${ORA_WAITSUM_RRD} --template DBW_WAT:DBW_CPU N:$DBWWAIT:$DBWCPUT
	else
		${RRDTOOL} create ${ORA_WAITSUM_RRD} --step 3600 DS:DBW_WAT:GAUGE:7200:0:200000 DS:DBW_CPU:GAUGE:7200:0:200000 RRA:MAX:0.5:1:525600
		${RRDTOOL} update ${ORA_WAITSUM_RRD} --template DBW_WAT:DBW_CPU N:$DBWWAIT:$DBWCPUT
fi
#
#
${RRDTOOL} graph Oracle_DBWSUMM_Daily.png \
        -t "`hostname` Oracle Daily Database % Wait Summary" -v "Percentage DB Time" \
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
        "DEF:cpu=${ORA_WAITSUM_RRD}:DBW_CPU:MAX" \
	"DEF:wait=${ORA_WAITSUM_RRD}:DBW_WAT:MAX" \
	"AREA:cpu#525BF0:DB % CPU Time" \
	"AREA:wait#00FFC8:DB % Wait Time:STACK" \
	"GPRINT:wait:LAST:Last\: %5.2lf Waits" \
        "GPRINT:wait:MIN:Min\: %5.2lf Waits" \
        "GPRINT:wait:MAX:Max\: %5.2lf Waits" \
        "GPRINT:wait:AVERAGE:Avg\: %5.2lf Waits"
#
#
${RRDTOOL} graph Oracle_DBWSUMM_Weekly.png \
        -t "`hostname` Oracle Weekly Database % Wait Summary" -v "Percentage DB Time" \
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
        "DEF:cpu=${ORA_WAITSUM_RRD}:DBW_CPU:MAX" \
	"DEF:wait=${ORA_WAITSUM_RRD}:DBW_WAT:MAX" \
	"AREA:cpu#525BF0:DB % CPU Time" \
	"AREA:wait#00FFC8:DB % Wait Time:STACK" \
	"GPRINT:wait:LAST:Last\: %5.2lf Waits" \
        "GPRINT:wait:MIN:Min\: %5.2lf Waits" \
        "GPRINT:wait:MAX:Max\: %5.2lf Waits" \
        "GPRINT:wait:AVERAGE:Avg\: %5.2lf Waits"
#
#
rm SGA_ALLOC
rm SGA_USED
rm RWIO_UTIL
rm DB_WAITSUMM
### FIN ###
