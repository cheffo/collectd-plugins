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
# Typical output:
#   PUTVAL <host>/iostat-ada0/iostat_trns interval=10 N:188796:1038994
#   PUTVAL <host>/iostat-ada0/iostat_kb interval=10 N:4858526:18003804
#   PUTVAL <host>/iostat-ada0/iostat_qlen interval=10 N:0
#   PUTVAL <host>/iostat-ada0/iostat_total interval=10 N:2785:589
#   PUTVAL <host>/iostat-ada1/iostat_trns interval=10 N:62952:1256020
#   PUTVAL <host>/iostat-ada1/iostat_kb interval=10 N:1448817:40299916
#   PUTVAL <host>/iostat-ada1/iostat_qlen interval=10 N:0
#   PUTVAL <host>/iostat-ada1/iostat_total interval=10 N:3470:626

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
        `which iostat` -xdI $(if ! [ -z "$filter" ]; then echo "$filter"; fi) | \
	 sed '1,2d' | awk -v host=${COLLECTD_HOSTNAME:=`hostname -f`} -v interval=${COLLECTD_INTERVAL:-10} '{
            print "PUTVAL " host "/iostat-" $1 "/iostat_trns" " interval=" interval  " N:" int($2) ":" int($3);
            print "PUTVAL " host "/iostat-" $1 "/iostat_kb" " interval=" interval  " N:" int($4) ":" int($5);
            print "PUTVAL " host "/iostat-" $1 "/iostat_qlen" " interval=" interval  " N:" int($6);
            print "PUTVAL " host "/iostat-" $1 "/iostat_total" " interval=" interval  " N:" int($7) ":" int($8);
        }'
	sleep ${COLLECTD_INTERVAL:-10}
done
