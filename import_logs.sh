#!/bin/sh

TraceID=$(date +%Y%m%d-%H%M%S)

mkdir -p ./logs/$TraceID/
ln -sfT $TraceID ./logs/latest

ssh isucon8final-a sudo pkill -HUP isucoin
scp isucon8final-a:/var/log/nginx/access.log \
    isucon8final-a:/tmp/cpu.pprof \
    isucon8final-a:/tmp/perf.log \
    isucon8final-a:/tmp/sql.log \
    isucon8final-a:/tmp/webroute.log \
    ./logs/$TraceID/

#ssh isu10q-a sudo chmod 644 /tmp/mysql-slow.log
#scp isu10q-a:/tmp/mysql-slow.log \
#    ./logs/$TraceID/
