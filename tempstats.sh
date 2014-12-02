#!/bin/sh
PATH=/bin:/sbin:/usr/bin/:/usr/sbin:/usr/local/bin/:/usr/local/sbin

sensors="hw.acpi.thermal.tz0.temperature hw.acpi.thermal.tz1.temperature"
cpus="dev.cpu.0.temperature dev.cpu.1.temperature dev.cpu.2.temperature dev.cpu.3.temperature"

while true
do
        for i in $cpus
        do
                TZ=`echo $i|awk -F "." '{print $3}'`
                /sbin/sysctl ${i} | awk -v TZ=${TZ} -v host=${COLLECTD_HOSTNAME:=`hostname -f`} -v interval=${COLLECTD_INTERVAL:-10} '{
                        print "PUTVAL " host "/thermal/temperature-cpu" TZ " interval=" interval  " N:" int($2)
                }'
        done
        /sbin/sysctl hw.acpi.thermal.tz0.temperature | awk -v host=${COLLECTD_HOSTNAME:=`hostname -f`} -v interval=${COLLECTD_INTERVAL:-10} '{
                print "PUTVAL " host "/thermal/temperature-tz0" " interval=" interval  " N:" int($2)
        }'
        /sbin/sysctl hw.acpi.thermal.tz1.temperature | awk -v host=${COLLECTD_HOSTNAME:=`hostname -f`} -v interval=${COLLECTD_INTERVAL:-10} '{
                print "PUTVAL " host "/thermal/temperature-tz1" " interval=" interval  " N:" int($2)
        }'
        sleep ${COLLECTD_INTERVAL:-10}
done
