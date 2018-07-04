#!/bin/bash
i=0
echo -n "Waiting for logstash to stop"
while (true); do
    echo -n .; sleep 1
    i=$((i+1))
    [ $i -gt 30 ] && exit
done