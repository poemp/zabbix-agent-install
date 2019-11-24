#!/usr/bin/env bash
# vim /etc/zabbix/script/mysql_status.sh    //编辑脚本
#!/bin/bash
#Desc：zabbix 监控 MySQL 状态
#Date：2019-5-6
#by：Lee-YJ

#主机
HOST="localhost"
#用户
USER="root"
#密码
PASSWORD="123456"
#端口
PORT="3306"
#MySQL连接
CONNECTION="mysqladmin -h ${HOST} -u ${USER} -P ${PORT} -p${PASSWORD}"

if [ $# -ne "1" ];then
    echo "arg error!"
fi

case $1 in
    Uptime)
        result=`${CONNECTION} status 2>/dev/null |awk '{print $2}'`
        echo $result
        ;;
    Questions)
        result=`${CONNECTION} status 2>/dev/null |awk '{print $6}'`
        echo $result
        ;;
    Com_update)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Com_update" |awk '{print $4}'`
        echo $result
        ;;
    Slow_queries)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Slow_queries" |awk '{print $4}'`
        echo $result
        ;;
    Com_select)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Com_select" |awk '{print $4}'`
        echo $result
        ;;
    Com_rollback)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Com_rollback" |awk '{print $4}'`
        echo $result
        ;;
    Com_insert)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Com_insert" |awk '{print $4}'`
        echo $result
        ;;
    Com_delete)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Com_delete" |awk '{print $4}'`
        echo $result
        ;;
    Com_commit)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Com_commit" |awk '{print $4}'`
        echo $result
        ;;
    Bytes_sent)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Bytes_sent" |awk '{print $4}'`
        echo $result
        ;;
    Bytes_received)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Bytes_received" |awk '{print $4}'`
        echo $result
        ;;
    Com_begin)
        result=`${CONNECTION} extended-status 2>/dev/null |grep -w "Com_begin" |awk '{print $4}'`
        echo $result
        ;;*)
        echo "Usage:$0(Uptime|Questions|Com_update|Slow_queries|Com_select|Com_rollback|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|Com_begin)"
        ;;
esac