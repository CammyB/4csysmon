#!/bin/bash 

## CHECK IF YOU ARE ROOT OR NOT
#
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

## CHECK IF SELECTED.TMP FILE EXITS FROM PREVIOUS RUN AND DELETE
#
if [ -f ./selected.tmp ]; then
	rm ./selected.tmp
fi

## CHECK IF mycron FILE EXITS FROM PREVIOUS RUN AND DELETE
#
if [ -f ./mycron ]; then
	rm ./mycron
fi


## MENU
## ADD MENU OPTIONS HERE
#
clear
options=("4CSysmon Disabled Check"	\
	"CPU Status" 			\
	"CPU Usage - Solaris" 		\
	"CPU Usage - Linux"		\
	"MEM Usage - Solaris" 		\
	"MEM Usage - Linux"		\
	"FS Utilisation - Solaris" 	\
	"FS Utilisation - Linux"	\
	"Inode Utilisation - Solaris"	\
	"Inode Utilisation - Linux"	\
	"Metadevice Health" 		\
	"MNTTAB vs VFSTAB" 		\
	"MNTTAB vs ZONECFG"		\
	"Messages Monitor - Solaris"	\
	"Messages Monitor - Linux"	\
	"NIC Connection Check - Sol10"	\
	"NIC Connection Check - Sol11"	\
	"SMF Service Status"		\
	"User Password Expiry"		\
	"Crontab Queue Check"		\
	"NBU - Tape Drive Status"	\
	"SSH Connection Check"		\
	"SAN Log Collector - VNX"	\
	"SAN Log Collector - NETAPP"	\
	"Thales Check"			\
	"Ora - PMON Check"		\
	"Ora - PMON ASM Check"		\
	"Ora - Trace File Removal"	\
	"Ora - OEM OMS Check"		\
	"Ora - OEM DB DG Stats"	\
	"iNSight RSYNC - insight"	\
	"iNSight RSYNC - ins_user"	\
	"iNSight - Log Check"		\
	"iNSight - Error/DUP Check"	\
	"iNSight DB Archive Backup"	\
	"iNSight CDR Archive Backup"	\
	"iNSight iPG Services Check"	\
	"ShadowBase Check"		\

	
)

menu() {
    echo "Available options:"
    for i in ${!options[@]}; do 
        printf "%3d%s] %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) || {
        msg="Invalid option: $num"; continue
    }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="X"
 clear
done
clear

printf "You selected:"; msg=" nothing"
for i in ${!options[@]}; do 

    [[ "${choices[i]}" ]] && { echo"";printf " %s" "- ${options[i]}"; msg=""; echo ${options[i]} >> selected.tmp; }

done

echo "$msg"

##
echo ""
echo "do you want to INSTALL"
printf 'enter [y/n] '
read ans
case ${ans:=y} in [yY]*) ;; *) exit ;; esac

DIR="/4csysmon"
if [ -d "$DIR" ]; then
	echo -n "$DIR directory exists, do you want to rename it [y/n]"
	read DIR_DEL
		if [ "$DIR_DEL" == "y" ]; then
			mv "$DIR" "$DIR"_`date '+%Y%m%d'`
			echo "$DIR" renamed to "$DIR"_`date '+%Y%m%d'`
		fi
	else
		echo ""
		echo $DIR directory does not exist, continuing...; sleep 3
fi

EXTRACT=`which tar`

if [ `cat /etc/*release | egrep -ci "linux|centos"` -gt 0 ]; then
	
	$EXTRACT xvf 4csm_v1_4.tar -C / > /dev/null 2>&1

else

$EXTRACT Pxvf 4csm_v1_4.tar  > /dev/null 2>&1

fi

chown -R root:root /4csysmon > /dev/null 2>&1
chown -R insight:other /4csysmon/3_app > /dev/null 2>&1
chown -R oracle:oinstall /4csysmon/2_db > /dev/null 2>&1
chown -R ins_user:other /4csysmon/3_app/1_rsync/ins_user > /dev/null 2>&1
chown orca:other /4csysmon/1_unix/3_io/2_network > /dev/null 2>&1
chmod 777 /4csysmon/1_unix/3_io/2_network/*.sh
chmod 777 /4csysmon/1_unix/7_temp/ > /dev/null 2>&1
chmod 777 /4csysmon/1_unix/3_io/2_network/ > /dev/null 2>&1


echo "Modifying script permissions...";sleep 3
echo "Creating 4Csysmon directory structure...";sleep 3
echo "Deploying 4Csysmon scripts...";sleep 3
echo ""


if [[ `cat selected.tmp | grep -c "4CSysmon Disabled Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '## 4CSysmon Automated Deployment v1.4' >> mycron
	echo '#0 * * * * /4csysmon/1_unix/5_sysadmin/4csysmon_disabled.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "CPU Status"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/1_cpu/cpu_status.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "CPU Usage - Solaris"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/1_cpu/cpu_usage.sh > /dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "CPU Usage - Linux"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/1_cpu/cpu_usage_rhel.sh > /dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "MEM Usage - Solaris"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/2_mem/mem_usage.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "MEM Usage - Linux"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/2_mem/mem_usage_rhel.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "FS Utilisation - Solaris"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,15,30,45 8-17 * * * /4csysmon/1_unix/3_io/1_storage/1_fs/fs_utilization.sh >/dev/null 2>&1' >> mycron
	echo '#10 18-7 * * * /4csysmon/1_unix/3_io/1_storage/1_fs/fs_utilization.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron
	echo "INFO: Please update the FS Threshold file -> /4csysmon/1_unix/6_misc/fs_thresholds.list"

fi


if [[ `cat selected.tmp | grep -c "FS Utilisation - Linux"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,15,30,45 8-17 * * * /4csysmon/1_unix/3_io/1_storage/1_fs/fs_utilization_rhel.sh > /dev/null 2>&1' >> mycron
	echo '#10 0-7,18-23  * * * /4csysmon/1_unix/3_io/1_storage/1_fs/fs_utilization_rhel.sh > /dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron
	echo "INFO: Please update the FS Threshold file -> /4csysmon/1_unix/6_misc/fs_thresholds.list"

fi


if [[ `cat selected.tmp | grep -c "Inode Utilisation - Solaris"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/1_unix/3_io/1_storage/1_fs/inode_utilization.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron
	echo "INFO: Please update the INODE Threshold file -> /4csysmon/1_unix/6_misc/inodes_thresholds.list"

fi



if [[ `cat selected.tmp | grep -c "Inode Utilisation - Linux"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/1_unix/3_io/1_storage/1_fs/inode_utilization_rhel.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron
	echo "INFO: Please update the INODE Threshold file -> /4csysmon/1_unix/6_misc/inodes_thresholds_rhel.list"

fi


if [[ `cat selected.tmp | grep -c "Metadevice Health"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/3_io/1_storage/1_fs/metadevice_health.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "MNTTAB vs VFSTAB"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/3_io/1_storage/1_fs/mntab_diff_vfstab.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "MNTTAB vs ZONECFG"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/3_io/1_storage/1_fs/mntab_diff_zonecfg.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "Messages Monitor - Solaris"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/5_sysadmin/messages_monitor.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "Messages Monitor - Linux"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/1_unix/5_sysadmin/messages_monitor_rhel.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "NIC Connection Check - Sol10"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/1_unix/3_io/2_network/nic_connection.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi

if [[ `cat selected.tmp | grep -c "NIC Connection Check - Sol11"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/1_unix/3_io/2_network/nic_connection_sol11.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi

if [[ `cat selected.tmp | grep -c "SMF Service Status"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/1_unix/5_sysadmin/svc_state.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "User Password Expiry"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 1 * * * /4csysmon/1_unix/4_useradmin/os_useracc_pass_exp.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "Crontab Queue Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,30 * * * * /4csysmon/1_unix/5_sysadmin/cron_queue.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "NBU - Tape Drive Status"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,30 * * * * /4csysmon/1_unix/3_io/1_storage/2_tape/tapedrive_status.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "SSH Connection Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,30 * * * * su - orca -c /4csysmon/1_unix/3_io/2_network/ssh_connection.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron
	echo "INFO: SSH Connection Check - Please update /4csysmon/1_unix/6_misc/1_hostlists/<site>.list & setup orca account + SSH Keys"

fi


if [[ `cat selected.tmp | grep -c "Ora - PMON Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/2_db/2_pmon_check/pmon_db_check.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron
	echo "INFO: DB PMON Check - Please update /4csysmon/2_db/2_pmon_check/pmon_db_check.lst with list of SIDs to monitor"

fi


if [[ `cat selected.tmp | grep -c "Ora - PMON ASM Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0,10,20,30,40,50 * * * * /4csysmon/2_db/2_pmon_check/pmon_asm_check.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "Ora - Trace File Removal"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/2_db/3_trace_file_removal/trc_file_remove.sh >/dev/null 2>&1' >> mycron
	echo "INFO: Please update /4csysmon/2_db/3_trace_file_removal/trc_file_remove.sh with the ORACLE_BASE value"
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "Ora - OEM OMS Check"` -eq 1 ]]; then
	
	getent passwd oracle > /dev/null 2>&1
	USTAT=`echo $?`

if [ `cat /etc/*release | grep -ci "linux|centos"` -gt 0 ]; then
	
	if [ $USTAT -gt 0 ]; then
		echo "WARNING: oracle user not found!! - Please fix this manually, the scripts are there"
	else
		/usr/bin/crontab -u oracle -l > ./oracle_cron
		echo '#0 * * * * /4csysmon/2_db/5_oms_check/oms_check.sh > /dev/null 2>&1' >> ./oracle_cron
		echo "INFO: Please confirm ORACLE_SID value within /4csysmon/2_db/5_oms_check/oms_check.sh"
		/usr/bin/crontab -u oracle ./oracle_cron
		rm ./oracle_cron
	fi
else
		if [ $USTAT -gt 0 ]; then
			echo "WARNING: oracle user crontab not found!! - Please fix this manually, the scripts are there"
		else
			cp /var/spool/cron/crontabs/oracle /var/spool/cron/crontabs/oracle_orig > /dev/null 2>&1
			cp /var/spool/cron/crontabs/oracle ./oracle_cron > /dev/null 2>&1
			echo '#0 * * * * /4csysmon/2_db/5_oms_check/oms_check.sh > /dev/null 2>&1' >> ./oracle_cron
			mv ./oracle_cron /var/spool/cron/crontabs/oracle
			echo "INFO: Please confirm ORACLE_SID value within /4csysmon/2_db/5_oms_check/oms_check.sh"
		fi
	
fi
fi


if [[ `cat selected.tmp | grep -c "Ora - OEM DB DG Stats"` -eq 1 ]]; then

	getent passwd oracle > /dev/null 2>&1
	USTAT=`echo $?`

if [ `cat /etc/*release | grep -ci "linux|centos"` -gt 0 ]; then
	
	if [ $USTAT -gt 0 ]; then
		echo "WARNING: oracle user not found!! - Please fix this manually, the scripts are there"

	else
		/usr/bin/crontab -u oracle -l > ./oracle_cron
		echo '#0 * * * * /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh > /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.log 2>&1' >> ./oracle_cron
		echo "INFO: Please confirm ORACLE_SID & ORACLE_HOME value within /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh"
		/usr/bin/crontab -u oracle ./oracle_cron
		chmod 777 /4csysmon/2_db/4_db_stats
	fi
else
	if [ $USTAT -gt 0 ]; then
		echo "WARNING: oracle user crontab not found!! - Please fix this manually, the scripts are there"
	else
		cp /var/spool/cron/crontabs/oracle /var/spool/cron/crontabs/oracle_orig > /dev/null 2>&1
		cp /var/spool/cron/crontabs/oracle ./oracle_cron > /dev/null 2>&1
		echo '#0 * * * * /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh > /4csysmon/2_db/3_db_stats/collect_db_dg_size_stats.log 2>&1' >> ./oracle_cron
		mv ./oracle_cron /var/spool/cron/crontabs/oracle
		echo "INFO: Please confirm ORACLE_SID value within /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh"
	fi
fi
fi


if [[ `cat selected.tmp | grep -c "iNSight RSYNC - insight"` -eq 1 ]]; then

	getent passwd insight > /dev/null 2>&1
	USTAT=`echo $?`

if [ `cat /etc/*release | grep -ci "linux|centos"` -gt 0 ]; then

	if [ $USTAT -gt 0 ]; then
		echo "WARNING: insight user not found!! - Please fix this manually, the scripts are there"
	else
		/usr/bin/crontab -u insight -l > ./insight_cron
		echo '#0 0,12 * * * /4csysmon/3_app/1_rsync/insight/insight_sync_dr.sh >/dev/null 2>&1' >> ./insight_cron
		echo "INFO: insight rsync crontab entry added, but hashed out - Please modify /4csysmon/3_app/1_rsync/insight/insight_sync_dr.sh as needed"
		/usr/bin/crontab -u insight ./insight_cron
	fi
else
	if [ $USTAT -gt 0 ]; then
		echo "WARNING: insight user not found!! - Please fix this manually, the scripts are there"
	else
		cp /var/spool/cron/crontabs/insight /var/spool/cron/crontabs/insight_orig > /dev/null 2>&1
		cp /var/spool/cron/crontabs/insight ./insight_cron > /dev/null 2>&1
		echo '#0 0,12 * * * /4csysmon/3_app/1_rsync/insight/insight_sync_dr.sh >/dev/null 2>&1' >> ./insight_cron
		mv ./insight_cron /var/spool/cron/crontabs/insight
		echo "INFO: insight rsync crontab entry added, but hashed out - Please modify /4csysmon/3_app/1_rsync/insight/insight_sync_dr.sh as needed"
	fi
fi
fi



if [[ `cat selected.tmp | grep -c "iNSight RSYNC - ins_user"` -eq 1 ]]; then

	getent passwd ins_user > /dev/null 2>&1
	USTAT=`echo $?`

if [ `cat /etc/*release | grep -ci "linux|centos"` -gt 0 ]; then

	if [ $USTAT -gt 0 ]; then
		echo "WARNING: ins_user user not found!! - Please fix this manually, the scripts are there"
	else
		chown ins_user /4csysmon/3_app/1_rsync/ins_user/ins_user_sync_dr.sh >/dev/null 2>&1

		/usr/bin/crontab -u ins_user -l > ./ins_user_cron
		echo '#0 0,12 * * * /4csysmon/3_app/1_rsync/ins_user/ins_user_sync_dr.sh >/dev/null 2>&1' >> ./ins_user_cron
		echo "INFO: ins_user rsync crontab entry added, but hashed out - Please modify /4csysmon/3_app/1_rsync/ins_user/ins_user_sync_dr.sh as needed"
		/usr/bin/crontab -u ins_user ./ins_user_cron
	fi
else
	if [ $USTAT -gt 0 ]; then
		echo "WARNING: ins_user user not found!! - Please fix this manually, the scripts are there"
	else
		cp /var/spool/cron/crontabs/ins_user /var/spool/cron/crontabs/ins_user_orig > /dev/null 2>&1
		cp /var/spool/cron/crontabs/ins_user ./ins_user_cron > /dev/null 2>&1
		echo '#0 0,12 * * * /4csysmon/3_app/1_rsync/ins_user/ins_user_sync_dr.sh >/dev/null 2>&1' >> ./ins_user_cron
		mv ./ins_user_cron /var/spool/cron/crontabs/ins_user
		echo "INFO: ins_user rsync crontab entry added, but hashed out - Please modify /4csysmon/3_app/1_rsync/ins_user/ins_user_sync_dr.sh as needed"
	fi
fi
fi




if [[ `cat selected.tmp | grep -c "iNSight - Log Check"` -eq 1 ]]; then

	getent passwd insight > /dev/null 2>&1
	USTAT=`echo $?`

if [ `cat /etc/*release | grep -ci "linux|centos"` -gt 0 ]; then

	if [ $USTAT -gt 0 ]; then
		echo "WARNING: insight user not found!! - Please fix this manually, the scripts are there"
	else
	
		/usr/bin/crontab -u insight -l > ./insight_cron
		echo '#0 * * * * /4csysmon/3_app/5_log_check/insight_log_check.sh 2>&1' >> ./insight_cron
		/usr/bin/crontab -u insight ./insight_cron
	fi
else
	if [ $USTAT -gt 0 ]; then
		echo "WARNING: insight user crontab not found!! - Please fix this manually, the scripts are there"
	else
		cp /var/spool/cron/crontabs/insight /var/spool/cron/crontabs/insight_orig > /dev/null 2>&1
		cp /var/spool/cron/crontabs/insight ./insight_cron > /dev/null 2>&1
		echo '#0 * * * * /4csysmon/3_app/5_log_check/insight_log_check.sh 2>&1' >> ./insight_cron
		mv ./insight_cron /var/spool/cron/crontabs/insight
	fi
fi
fi


if [[ `cat selected.tmp | grep -c "iNSight - Error/DUP Check"` -eq 1 ]]; then

	getent passwd insight > /dev/null 2>&1
	USTAT=`echo $?`

if [ `cat /etc/*release | grep -ci "linux|centos"` -gt 0 ]; then

	if [ $USTAT -gt 0 ]; then
		echo "WARNING: insight user not found!! - Please fix this manually, the scripts are there"
	else
	
		/usr/bin/crontab -u insight -l > ./insight_cron
		echo '#0 * * * * /4csysmon/3_app/4_error_dup_check/insight_error_dup.sh 2>&1' >> ./insight_cron
		/usr/bin/crontab -u insight ./insight_cron
	fi
else
	if [ $USTAT -gt 0 ]; then
		echo "WARNING: insight user crontab not found!! - Please fix this manually, the scripts are there"
	else
		cp /var/spool/cron/crontabs/insight /var/spool/cron/crontabs/insight_orig > /dev/null 2>&1
		cp /var/spool/cron/crontabs/insight ./insight_cron > /dev/null 2>&1
		echo '#0 * * * * /4csysmon/3_app/4_error_dup_check/insight_error_dup.sh 2>&1' >> ./insight_cron
		mv ./insight_cron /var/spool/cron/crontabs/insight
	fi
fi
fi



if [[ `cat selected.tmp | grep -c "SAN Log Collector - VNX"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 1 * * * /4csysmon/1_unix/3_io/3_san/vnx_mess.sh >/dev/null 2>&1' >> mycron
	echo "INFO: Please modify /4csysmon/1_unix/3_io/3_san/vnx_mess.sh with relevant SAN IP detail"
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "SAN Log Collector - NETAPP"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 1 * * * /4csysmon/1_unix/3_io/3_san/netapp.sh >/dev/null 2>&1' >> insight_cron
	echo "INFO: Please modify /4csysmon/1_unix/3_io/3_san/netapp.sh with relevant SAN IP detail"
	/usr/bin/crontab mycron

fi

if [[ `cat selected.tmp | grep -c "Thales Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 1 * * * /4csysmon/1_unix/3_io/2_network/2_thales >/dev/null 2>&1' >> insight_cron
	echo "INFO: Please modify /4csysmon/1_unix/3_io/2_network/2_thales with relevant SAN IP detail"
	/usr/bin/crontab mycron

fi





if [[ `cat selected.tmp | grep -c "iNSight DB Archive Backup"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 4 * * * /4csysmon/4_bckp/1_db_archive/insight_db_archive_backup.sh >/dev/null 2>&1' >> mycron
	echo '#0 12 * * * /4csysmon/4_bckp/1_db_archive/insight_db_archive_backup_check.sh >/dev/null 2>&1' >> mycron
	echo "INFO: Please modify /4csysmon/4_bckp/1_db_archive/insight_db_archive_backup.sh with relevant Backup environment variables"
	/usr/bin/crontab mycron
	rm mycron

fi


if [[ `cat selected.tmp | grep -c "iNSight CDR Archive Backup"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 0,6,12,18 * * * /4csysmon/4_bckp/2_insight_archive/insight_arc_backup.sh >/dev/null 2>&1' >> mycron
	echo '#0 6,12 * * * /4csysmon/4_bckp/2_insight_archive/insight_arc_backup_check.sh >/dev/null 2>&1' >> mycron
	echo "INFO: Please modify /4csysmon/4_bckp/2_insight_archive/insight_arc_backup.sh with relevant Backup environment variables"
	/usr/bin/crontab mycron
	rm mycron

fi



if [[ `cat selected.tmp | grep -c "iNSight iPG Services Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/1_unix/3_io/2_network/3_iPG/ipg_services_check.sh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi






if [[ `cat selected.tmp | grep -c "ShadowBase Check"` -eq 1 ]]; then

	/usr/bin/crontab -l > mycron
	echo '#0 * * * * /4csysmon/3_app/2_shadbase/shadbase_check.ksh >/dev/null 2>&1' >> mycron
	/usr/bin/crontab mycron
	rm mycron

fi


echo "Time to configure..";sleep 2
PS3='Please select your site: '
options=("AA" "Vodacom DRC" "Vodacom MOZ" "Vodacom TZ" "Vodacom VCL" "VMSA" "TNM" "MVNE”)
select opt in "${options[@]}"
do 
   case $opt in
         "AA")
            echo "AA selected"
	    ACC="Achievement Awards"
	    SITE="AA"
	    DB_STATS_SITE="AA"
	    CAT="Unix SLA - AA"
	    DOMAIN="awards.co.za"
	    break
            ;;
        "Vodacom DRC")
            echo "Vodacom DRC selected"
	    ACC="Vodacom DRC"
	    DB_STATS_SITE="VDRC"
	    SITE="DRC"
	    CAT="Unix SLA - DRC"
	    DOMAIN="vodacom.cd"
	    break
            ;;
        "Vodacom MOZ")
            echo "Vodacom MOZ selected"
	    ACC="Vodacom MOZ"
	    SITE="MOZ"
	    DB_STATS_SITE="VMOZ"
	    CAT="Unix SLA - MOZ"
	    DOMAIN="vm.co.mz"
	    break
	    ;;
        "Vodacom TZ")
            echo "Vodacom TZ selected"
	    ACC="Vodacom TZ"
	    SITE="TZ"
	    DB_STATS_SITE="VTZ"
	    CAT="Unix SLA - TZ"
	    DOMAIN="vodacom.co.tz"
	    break
            ;;
        "Vodacom VCL")
            echo "Vodacom VCL selected"
	    ACC="Vodacom VCL"
	    SITE="VCL"
	    DB_STATS_SITE="VCL"
	    CAT="Unix SLA - VCL"
	    DOMAIN="vcl.corp"
	    break
            ;;
        "VMSA")
            echo "VMSA selected"
	    ACC="Virgin Mobile South Africa"
	    SITE="VMSA"
	    DB_STATS_SITE="VMSA"
	    CAT="Unix SLA - VMSA"
	    DOMAIN="virginmobile.co.za"
	    break
            ;;
	 "TNM")
            echo "TNM selected"
	    ACC="Telekom Networks Malawi"
	    SITE="TNM"
	    DB_STATS_SITE="TNM"
	    CAT="Unix SLA - TNM"
	    DOMAIN="tnm.co.mw"
	    break
            ;;
	 "MVNE")
            echo "MVNE selected"
	    ACC="Telekom Networks Malawi"
	    SITE="MVNE"
	    DB_STATS_SITE="MVNE"
	    CAT="Unix SLA - MVNE"
	    DOMAIN="4cgroup.co.za"
	    break
            ;;
        *) echo invalid option;;
    esac
done

echo ""
echo "Adding required crontab entries...";sleep 3

cp /4csysmon/1_unix/6_misc/global_parameters.list /4csysmon/1_unix/6_misc/global_parameters.list_orig
U_SCORE=$(echo "17-`uname -n | wc -m`" |bc)
HOST=`uname -n`
PRE=`printf "%${U_SCORE}s\n"| sed "s/ /_/g"`
sed "s/HOSTLOGNAME=\"________________/HOSTLOGNAME=\"$HOST$PRE/g" /4csysmon/1_unix/6_misc/global_parameters.list_orig > /4csysmon/1_unix/6_misc/global_parameters.list

cp /4csysmon/1_unix/6_misc/SD_template.txt /4csysmon/1_unix/6_misc/SD_template.txt_orig
sed "s/@@ITEM=host@@/@@ITEM=$HOST@@/g" /4csysmon/1_unix/6_misc/SD_template.txt_orig > /4csysmon/1_unix/6_misc/SD_template.txt

cp /4csysmon/1_unix/6_misc/SD_template.txt /4csysmon/1_unix/6_misc/SD_template.txt.tmp1
sed "s/@@ACCOUNT=account@@/@@ACCOUNT=$ACC@@/g" /4csysmon/1_unix/6_misc/SD_template.txt.tmp1 > /4csysmon/1_unix/6_misc/SD_template.txt.tmp2
sed "s/@@SITE=site@@/@@SITE=$SITE@@/g" /4csysmon/1_unix/6_misc/SD_template.txt.tmp2 > /4csysmon/1_unix/6_misc/SD_template.txt.tmp1
sed "s/@@ITEM=host@@/@@ITEM=$HOST@@/g" /4csysmon/1_unix/6_misc/SD_template.txt.tmp1 > /4csysmon/1_unix/6_misc/SD_template.txt.tmp2
sed "s/@@CATEGORY=sla@@/@@CATEGORY=$CAT@@/g" /4csysmon/1_unix/6_misc/SD_template.txt.tmp2 > /4csysmon/1_unix/6_misc/SD_template.txt
rm /4csysmon/1_unix/6_misc/SD_template.txt.tmp1 /4csysmon/1_unix/6_misc/SD_template.txt.tmp2

cp /4csysmon/1_unix/6_misc/global_parameters.list /4csysmon/1_unix/6_misc/global_parameters.list.tmp1
sed "s/@@ACCOUNT=account@@/@@ACCOUNT=$ACC@@/g" /4csysmon/1_unix/6_misc/global_parameters.list.tmp1 > /4csysmon/1_unix/6_misc/global_parameters.list.tmp2
sed "s/@@SITE=site@@/@@SITE=$SITE@@/g" /4csysmon/1_unix/6_misc/global_parameters.list.tmp2 > /4csysmon/1_unix/6_misc/global_parameters.list.tmp1
sed "s/@@ITEM=host@@/@@ITEM=$HOST@@/g" /4csysmon/1_unix/6_misc/global_parameters.list.tmp1 > /4csysmon/1_unix/6_misc/global_parameters.list.tmp2
sed "s/@@CATEGORY=sla@@/@@CATEGORY=$CAT@@/g" /4csysmon/1_unix/6_misc/global_parameters.list.tmp2 > /4csysmon/1_unix/6_misc/global_parameters.list.tmp1
sed "s/4c.monitor@DOMAIN/4c.monitor@$DOMAIN/g" /4csysmon/1_unix/6_misc/global_parameters.list.tmp1 > /4csysmon/1_unix/6_misc/global_parameters.list
rm /4csysmon/1_unix/6_misc/global_parameters.list.tmp1 /4csysmon/1_unix/6_misc/global_parameters.list.tmp2

sed 's/SITE=site/SITE='$DB_STATS_SITE'/g' /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh > /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh.tmp1
mv /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh.tmp1 /4csysmon/2_db/4_db_stats/collect_db_dg_size_stats.sh
sed 's/site/'$DB_STATS_SITE'/g' /4csysmon/2_db/4_db_stats/dg_usage.sql > /4csysmon/2_db/4_db_stats/dg_usage.sql.tmp1
mv /4csysmon/2_db/4_db_stats/dg_usage.sql.tmp1 /4csysmon/2_db/4_db_stats/dg_usage.sql

sed 's/site.list/'$SITE'.list/g' /4csysmon/1_unix/3_io/2_network/ssh_connection.sh > /4csysmon/1_unix/3_io/2_network/ssh_connection.sh.tmp1
mv /4csysmon/1_unix/3_io/2_network/ssh_connection.sh.tmp1 /4csysmon/1_unix/3_io/2_network/ssh_connection.sh


echo "Setting Global parameters...";sleep 3
echo "Setting SD Template parameters...";sleep 3
echo "INFO: Please setup remaining SD Mail Template values, if needed -> /4csysmon/1_unix/6_misc/SD_template.txt";sleep 2



rm selected.tmp

echo "4CSysmon Installation Complete"
