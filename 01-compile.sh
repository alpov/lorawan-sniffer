#!/bin/bash

gcc sniffer-to-pcap.c cJSON/cJSON.c -lm -Wall -o log-convert
gcc sniffer-scan.c cJSON/cJSON.c -lm -Wall -o log-scan
sleep 1
#./log-convert v0 log.txt log_v0.pcap
#./log-convert v1 log.txt log_v1.pcap
