select sum(bytes)/1024/1024 " SGA size used in MB" from v$sgastat where name!='free memory';
exit
