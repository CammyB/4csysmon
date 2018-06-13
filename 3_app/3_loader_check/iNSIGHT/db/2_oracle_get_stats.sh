#!/usr/bin/ksh
#
# Get's called by root: su - oracle -c "/4csysmon/3_app/1_mis/2_Loader_Check/iNSIGHT/db/2_oracle_get_stats.sh"
# run every hour
#
WORKING_DIR="/4csysmon/3_app/1_mis/2_Loader_Check/iNSIGHT/db"
cd $WORKING_DIR
export ORACLE_HOME="/app/oracle/product/11.2.0.3"
export ORACLE_SID="pins"
export ORACLE_BASE="/app/oracle"
export PATH="$PATH:/usr/bin::/usr/local/bin:/usr/local/bin:/app/oracle/bin:/app/oracle/product/11.2.0.3/bin:/usr/sbin"
export ORAENV_ASK="NO"
export LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/bin:/usr/local/lib:/esp/lib:/app/oracle/product/11.2.0.3/lib"
#
sqlplus '/as sysdba' @SQL_SGA_Allocate.sql | awk '/----------/{print;c=1;next}c-->0' | grep -v '\<----------\>' | awk '{print $1}' > SGA_ALLOC
sqlplus '/as sysdba' @SQL_SGA_USED.sql | awk '/----------/{print;c=1;next}c-->0' | grep -v '\<----------\>' | awk '{print $1}' > SGA_USED
sqlplus '/as sysdba' @SQL_RW_IOMB.sql | awk '/----------/{print;c=1;next}c-->0' | grep -v '\<----------\>' | awk '{print $2, $3, $5, $6}' > RWIO_UTIL
sqlplus '/as sysdba' @SQL_DB_WAITSUMM.sql | grep -i "Time Ratio" | awk '{print $NF}' > DB_WAITSUMM
#
#
### FIN ###
