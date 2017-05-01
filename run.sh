#!/bin/bash

#docker run -d -h node01  --name consul -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 53:53/udp progrium/consul -server -advertise 192.168.1.102 -bootstrap-expect 1

#docker run -d -v /var/run/docker.sock:/tmp/docker.sock --link consul:consul --name registrator -h registrator gliderlabs/registrator:latest consul://192.168.1.102:8500


docker run -d -p 8000:8000 -v /home/sumit/repository:/usr/lib/repository --name hue -h master sumit/hue /etc/bootstrap.sh -d
