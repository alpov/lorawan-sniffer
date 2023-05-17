#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/
gcc sniffer-to-pcap.c -lcjson -lm -Wall -o log-convert
gcc sniffer-scan.c -lcjson -lm -Wall -o log-scan
sleep 1
#./log-convert v0 log.txt log_v0.pcap
#./log-convert v1 log.txt log_v1.pcap
