#!/bin/sh

###############################################################################
#  rotate nginx logs, both access and error logs
#  
#
#  usage:
#      bash rotate.sh
#
###############################################################################

echo 'start at:' `date +'%Y-%m-%d %H:%M:%S'`

LASTDAY_STR=`date +'%Y-%m-%d' -d '-1 day'`

NGX_ROOT="/usr/local/openresty/nginx/"
NGX_LOGS_PATH=${NGX_ROOT}"/logs/"
LOG_TYPE="access error"

NGX_BIN=${NGX_ROOT}"sbin/nginx"

# rename log
for lt in ${LOG_TYPE}
do
    log_file=${NGX_LOGS_PATH}${lt}".log"
    [ -f ${log_file} ] && (mv ${log_file} ${log_file}"."${LASTDAY_STR})
done

# reload nginx service
ngx_pid=`ps aux |grep -E 'nginx: master process'|grep -v 'grep'|awk '{print $2}'`
kill -USR1 ${ngx_pid}
${NGX_BIN} -s reload

sleep 1

# gzip log files
for lt in ${LOG_TYPE}
do
    log_file=${NGX_LOGS_PATH}${lt}".log."${LASTDAY_STR}
    [ -f ${log_file} ]  && (gzip ${log_file})
done

# delte logs that 7 days ago
find ${NGX_LOGS_PATH} -mtime +7 -exec rm {} \;

echo 'end at:' `date +'%Y-%m-%d %H:%M:%S'`
