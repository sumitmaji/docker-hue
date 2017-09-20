#!/bin/bash
ip_addr=`/sbin/ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`
echo 'host ip address: '$ip_addr
docker build --build-arg REPOSITORY_HOST=http://master:8181 -t sumit/hue:latest .

