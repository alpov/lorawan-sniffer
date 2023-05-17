#!/bin/bash

WORKDIR="../loralog"

CSV_FORMAT="-T fields -E separator=,
    -e frame.number -e frame.time_epoch -e frame.len -e loratap.srcgw -e loratap.flags.crc
    -e loratap.rssi.current -e loratap.rssi.snr -e loratap.channel.frequency -e loratap.channel.sf -e loratap.channel.cr
    -e lorawan.mhdr.ftype -e lorawan.fhdr.devaddr -e lorawan.fport -e lorawan.fhdr.fcnt -e loratap.payload"

CSV_FORMAT_GPS="$CSV_FORMAT -e lorawan.beacon.gwspecific.lat -e lorawan.beacon.gwspecific.lng"

FLT_BEACON_ALL="(lorawan.msgtype == \"Class-B Beacon\") && (lorawan.beacon.crc1.status == \"Good\") && 
    (lorawan.beacon.crc2.status == \"Good\")"

FLT_BEACON_VALID="(lorawan.msgtype == \"Class-B Beacon\") && (lorawan.beacon.crc1.status == \"Good\") && 
    (lorawan.beacon.crc2.status == \"Good\") && (lorawan.beacon.time < \"2030-01-01\")"

FLT_BEACON_GPS="(lorawan.msgtype == \"Class-B Beacon\") && (lorawan.beacon.crc1.status == \"Good\") && 
    (lorawan.beacon.crc2.status == \"Good\") && (lorawan.beacon.time < \"2030-01-01\" && !(frame[43:7] == 00:00:00:00:00:00:00))"

FLT_BEACON_UNIX="(lorawan.msgtype == \"Class-B Beacon\") && (lorawan.beacon.crc1.status == \"Good\") && 
    (lorawan.beacon.crc2.status == \"Good\") && (lorawan.beacon.time > \"2030-01-01\")"

mkdir $WORKDIR/csv
rm -f $WORKDIR/csv/*_beacon*.csv

for f in $WORKDIR/pcap/*.pcap; do
  DATASET="$(basename "$f" .pcap)"

  tshark -r "$f" $CSV_FORMAT -Y "$FLT_BEACON_ALL" > data.csv
  ./csv-beacon.py data.csv $WORKDIR/csv/${DATASET}_beacon_all.csv all
  printf "%s,BEACON_ALL,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_beacon_all.csv`

  tshark -r "$f" $CSV_FORMAT -Y "$FLT_BEACON_VALID" > data.csv
  ./csv-beacon.py data.csv $WORKDIR/csv/${DATASET}_beacon_valid.csv valid
  printf "%s,BEACON_VALID,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_beacon_valid.csv`

  ./csv-beacon.py data.csv $WORKDIR/csv/${DATASET}_beacon_invalid.csv invalid
  printf "%s,BEACON_INVALID,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_beacon_invalid.csv`
  ./csv-beacon.py data.csv $WORKDIR/csv/${DATASET}_beacon_utcshift.csv utcshift
  printf "%s,BEACON_UTC_SHIFT,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_beacon_utcshift.csv`

  tshark -r "$f" $CSV_FORMAT -Y "$FLT_BEACON_UNIX" > data.csv
  ./csv-beacon.py data.csv $WORKDIR/csv/${DATASET}_beacon_unix.csv all
  printf "%s,BEACON_UNIX,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_beacon_unix.csv`

  tshark -r "$f" $CSV_FORMAT_GPS -Y "$FLT_BEACON_GPS" > data.csv
  ./csv-beacon.py data.csv $WORKDIR/csv/${DATASET}_beacon_gps.csv valid
  ./csv-gps.py data.csv $WORKDIR/csv/${DATASET}_beacon_gps.gpx
  printf "%s,BEACON_GPS,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_beacon_gps.csv`

done

rm -f data.csv
