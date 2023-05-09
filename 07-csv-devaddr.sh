#!/bin/bash

WORKDIR="../loralog"

rm -f $WORKDIR/csv/*_devaddr.csv

for f in $WORKDIR/pcap/*.pcap; do
  DATASET="$(basename "$f" .pcap)"
  ./csv-devaddr.py $WORKDIR/csv/${DATASET}_data.csv $WORKDIR/csv/${DATASET}_devaddr.csv
done

