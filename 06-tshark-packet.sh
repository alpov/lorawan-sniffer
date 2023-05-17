#!/bin/bash

WORKDIR="../loralog"

CSV_FORMAT="-T fields -E separator=,
    -e frame.number -e frame.time_epoch -e frame.len -e loratap.srcgw -e loratap.flags.crc
    -e loratap.rssi.current -e loratap.rssi.snr -e loratap.channel.frequency -e loratap.channel.sf -e loratap.channel.cr
    -e lorawan.mhdr.ftype -e lorawan.fhdr.devaddr -e lorawan.fport -e lorawan.fhdr.fcnt -e loratap.flags"

CSV_FORMAT_JOIN="$CSV_FORMAT -e lorawan.join_request.joineui -e lorawan.join_request.deveui"

FLT_LORAWAN_VALID="(((loratap.flags.crc == 0x01) || ((loratap.flags.crc == 0x04) && ((lorawan.mhdr.ftype == 3) ||
    lorawan.mhdr.ftype == 5))) && !(lorawan.mhdr_error) && !(_ws.expert.group == \"Malformed\"))"

FLT_LORAWAN_CROSSTALK="((loratap.flags.crc == 0x01) &&
    ((loratap.flags.iq_inverted == 0) && ((lorawan.mhdr.ftype == 1) || (lorawan.mhdr.ftype == 3) || (lorawan.mhdr.ftype == 5)) ||
    ((loratap.flags.iq_inverted == 1) && ((lorawan.mhdr.ftype == 0) || (lorawan.mhdr.ftype == 2) || (lorawan.mhdr.ftype == 4)))))"
FLT_LORAWAN_VALID="(($FLT_LORAWAN_VALID) && !($FLT_LORAWAN_CROSSTALK))"

FLT_LORAWAN_VALID_DATA="($FLT_LORAWAN_VALID) && (lorawan.mhdr.ftype == 2 || lorawan.mhdr.ftype == 3 || lorawan.mhdr.ftype == 4 || lorawan.mhdr.ftype == 5)"

FLT_LORAWAN_VALID_JOIN="($FLT_LORAWAN_VALID) && (lorawan.mhdr.ftype == 0)"

FLT_BEACON_ALL="lorawan.msgtype == \"Class-B Beacon\""

FLT_BEACON_VALID="(lorawan.msgtype == \"Class-B Beacon\") && (lorawan.beacon.crc1.status == \"Good\") && 
    (lorawan.beacon.crc2.status == \"Good\")"

FLT_ALL_VALID="($FLT_LORAWAN_VALID) or ($FLT_BEACON_VALID)"

mkdir $WORKDIR/csv
rm -f $WORKDIR/csv/*.csv

for f in $WORKDIR/pcap/*.pcap; do
  DATASET="$(basename "$f" .pcap)"

  tshark -r "$f" $CSV_FORMAT > data.csv
  ./csv-packet.py data.csv $WORKDIR/csv/${DATASET}_all.csv
  printf "%s,TOTAL,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_all.csv`

  tshark -r "$f" $CSV_FORMAT -Y "$FLT_ALL_VALID" > data.csv
  ./csv-packet.py data.csv $WORKDIR/csv/${DATASET}_valid.csv
  printf "%s,VALID,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_valid.csv`

#  tshark -r "$f" $CSV_FORMAT -Y "$FLT_LORAWAN_VALID" > data.csv
#  ./csv-packet.py data.csv $WORKDIR/csv/${DATASET}_lorawan.csv
#  printf "%s,LORAWAN,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_lorawan.csv`

  tshark -r "$f" $CSV_FORMAT -Y "$FLT_LORAWAN_VALID_DATA" > data.csv
  ./csv-packet.py data.csv $WORKDIR/csv/${DATASET}_data.csv
  printf "%s,DATA,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_data.csv`

  tshark -r "$f" $CSV_FORMAT_JOIN -Y "$FLT_LORAWAN_VALID_JOIN" > data.csv
  ./csv-packet.py data.csv $WORKDIR/csv/${DATASET}_join.csv
  printf "%s,JOIN,%d\n" $DATASET `wc -l < $WORKDIR/csv/${DATASET}_join.csv`
done

rm -f data.csv
