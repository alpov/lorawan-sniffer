#!/bin/bash

WORKDIR="../loralog"

#grep -n "listening on port" -B 3 -A 5 $WORKDIR/log.txt

mkdir $WORKDIR/log
mkdir $WORKDIR/pcap
rm -f $WORKDIR/pcap/*.pcap

awk 'NR>=628 && NR <= 819 { print }' $WORKDIR/log.txt > $WORKDIR/log/00_Test.log
awk 'NR>=150873 && NR <= 529796 { print }' $WORKDIR/log.txt > $WORKDIR/log/01_Brno.log
awk 'NR>=636205 && NR <= 886868 { print }' $WORKDIR/log.txt > $WORKDIR/log/02_Liege.log
awk 'NR>=947787 && NR <= 979382 { print }' $WORKDIR/log.txt > $WORKDIR/log/03_Brno_join.log
awk 'NR>=1015139 && NR <= 1178855 { print }' $WORKDIR/log.txt > $WORKDIR/log/04_Graz.log
awk 'NR>=1179308 && NR <= 3657105 { print }' $WORKDIR/log.txt > $WORKDIR/log/05_Wien.log
#awk 'NR>=3657108 && NR <= 4969648 { print }' $WORKDIR/log.txt > $WORKDIR/log/06_Brno_dirty.log
awk 'NR>=4969648 && NR <= 6919392 { print }' $WORKDIR/log.txt > $WORKDIR/log/07_Brno.log


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/

./log-convert v0 $WORKDIR/log/00_Test.log $WORKDIR/pcap/00_Test_v0.pcap
./log-convert v1 $WORKDIR/log/00_Test.log $WORKDIR/pcap/00_Test_v1.pcap

for f in $WORKDIR/log/*.log; do
  ./log-convert v1 "$f" $WORKDIR/pcap/"$(basename "$f" .log)".pcap
done
