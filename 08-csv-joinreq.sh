#!/bin/bash

WORKDIR="../loralog"

rm -f $WORKDIR/csv/*_joinreq.csv

./gen-mac-vendors.py

for f in $WORKDIR/pcap/*.pcap; do
  DATASET="$(basename "$f" .pcap)"
  ./csv-joinreq.py $WORKDIR/csv/${DATASET}_join.csv $WORKDIR/csv/${DATASET}_joinreq.csv
done

