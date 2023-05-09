#!/bin/bash

WORKDIR="../loralog"

FLT_LORAWAN_VALID="(((loratap.flags.crc == 0x01) || ((loratap.flags.crc == 0x04) && ((lorawan.mhdr.ftype == 3) ||
    lorawan.mhdr.ftype == 5))) && !(lorawan.mhdr_error) && !(_ws.expert.group == \"Malformed\"))"

FLT_LORAWAN_CROSSTALK="((loratap.flags.crc == 0x01) && 
    ((loratap.flags.iq_inverted == 0) && ((lorawan.mhdr.ftype == 1) || (lorawan.mhdr.ftype == 3) || (lorawan.mhdr.ftype == 5)) ||
    ((loratap.flags.iq_inverted == 1) && ((lorawan.mhdr.ftype == 0) || (lorawan.mhdr.ftype == 2) || (lorawan.mhdr.ftype == 4)))))"
FLT_LORAWAN_VALID="(($FLT_LORAWAN_VALID) && !($FLT_LORAWAN_CROSSTALK))"

FLT_LORAWAN_VALID_DATA="($FLT_LORAWAN_VALID) && (lorawan.mhdr.ftype == 2 || lorawan.mhdr.ftype == 3 || lorawan.mhdr.ftype == 4 || lorawan.mhdr.ftype == 5)"

FLT_UP="($FLT_LORAWAN_VALID) && (lorawan.mhdr.ftype == 2 || lorawan.mhdr.ftype == 4)"
FLT_DN="($FLT_LORAWAN_VALID) && (lorawan.mhdr.ftype == 3 || lorawan.mhdr.ftype == 5)"
FLT_DN_CRC_OK="($FLT_DN) && (loratap.flags.crc == 0x01)"
FLT_DN_NO_CRC="($FLT_DN) && (loratap.flags.crc == 0x04)"

FLT_UP_ADR="(($FLT_UP)) && (lorawan.fhdr.fctrl.adr == 1)"
FLT_DN_ADR="(($FLT_DN)) && (lorawan.fhdr.fctrl.adr == 1)"

FLT_UP_CLASSB="(($FLT_UP)) && (lorawan.fhdr.fctrl.fpending == 1)"


mkdir $WORKDIR/csv
rm -f $WORKDIR/csv/*.csv

for f in $WORKDIR/pcap/*.pcap; do
  DATASET="$(basename "$f" .pcap)"

  printf "%s valid packets = " $DATASET
  tshark -r "$f" -Y "($FLT_LORAWAN_VALID)" | wc -l

  printf "%s data packets = " $DATASET
  tshark -r "$f" -Y "($FLT_LORAWAN_VALID_DATA)" | wc -l

  printf "%s uplink packets = " $DATASET
  tshark -r "$f" -Y "($FLT_UP)" | wc -l

  printf "%s downlink packets = " $DATASET
  tshark -r "$f" -Y "($FLT_DN)" | wc -l
  printf "    CRC OK = "
  tshark -r "$f" -Y "($FLT_DN_CRC_OK)" | wc -l
  printf "    No CRC = "
  tshark -r "$f" -Y "($FLT_DN_NO_CRC)" | wc -l

  printf "%s uplink packets with ADR = " $DATASET
  tshark -r "$f" -Y "($FLT_UP_ADR)" | wc -l

  printf "%s downlink packets with ADR = " $DATASET
  tshark -r "$f" -Y "($FLT_DN_ADR)" | wc -l

  printf "%s uplink packets with ClassB = " $DATASET
  tshark -r "$f" -Y "($FLT_UP_CLASSB)" | wc -l

done

rm -f data.csv
