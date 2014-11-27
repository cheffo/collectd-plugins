#!/bin/sh
###
# ABOUT  : collectd monitoring script for iostat statistics
# AUTHOR : Matthias Breddin <mb@lunetics.com> (c) 2013
# LICENSE: GNU GPL v3
#
# This script parses disk and partition output of freebsds gstat
#
# Generates output suitable for Exec plugin of collectd.
#
# Requirements:
#   gstat
#   sudo entry for binary (ie. for sys account):
#       sys   ALL = (root) NOPASSWD: /usr/sbin/gstat
#
#
# Typical usage:
#   /usr/local/collectd-plugins/iostat-freebsd/iostat.sh
#
# Typical output:
#   PUTVAL <host>/iostat-da0/iostat_tql interval=10 N:0
#   PUTVAL <host>/iostat-da0/iostat_iops interval=10 N:19:44
#   PUTVAL <host>/iostat-da0/iostat_iops_complex interval=10 N:63
#   PUTVAL <host>/iostat-da0/iostat_transaction_time interval=10 N:1.1:0.3
#   PUTVAL <host>/iostat-da0/iostat_kbps interval=10 N:610304:1926144
#   PUTVAL <host>/iostat-da0/iostat_busy interval=10 N:2.6
#   PUTVAL <host>/iostat-da0p1/iostat_tql interval=10 N:0
#   PUTVAL <host>/iostat-da0p1/iostat_iops interval=10 N:0:0
#   PUTVAL <host>/iostat-da0p1/iostat_iops_complex interval=10 N:0
#   PUTVAL <host>/iostat-da0p1/iostat_transaction_time interval=10 N:0.0:0.0
#   PUTVAL <host>/iostat-da0p1/iostat_kbps interval=10 N:0:0

#   ...
#
###
PATH=/bin:/sbin:/usr/bin/:/usr/sbin:/usr/local/bin/:/usr/local/sbin
if ! [ -z "$*" ];
then
        filter="${@}";
fi;

while true
do
        `which iostat` -xdI $(if ! [ -z "$filter" ]; then echo "$filter"; fi) | sed '1,2d' | awk -v host=${COLLECTD_HOSTNAME:=`hostname -f`} -v interval=${COLLECTD_INTERVAL:-10} '{
            print "PUTVAL " host "/iostat-" $1 "/iostat_read" " interval=" interval  " N:" $2;
            print "PUTVAL " host "/iostat-" $1 "/iostat_write" " interval=" interval  " N:" $3;
            print "PUTVAL " host "/iostat-" $1 "/iostat_kiloreads" " interval=" interval  " N:" $4;
            print "PUTVAL " host "/iostat-" $1 "/iostat_kilowrites" " interval=" interval  " N:" $5;
            print "PUTVAL " host "/iostat-" $1 "/iostat_trn_queue" " interval=" interval  " N:" $6;
            print "PUTVAL " host "/iostat-" $1 "/iostat_total_duration" " interval=" interval  " N:" $7;
	    print "PUTVAL " host "/iostat-" $1 "/iostat_total_wait_in_queue" " interval=" interval  " N:" $8;
        }'
	sleep ${COLLECTD_INTERVAL:-10}
done
