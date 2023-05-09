#!/usr/bin/python3

import csv, sys
from LoRaAirTime import LoRaAirTime

fi = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'w')
writer = csv.writer(fo, delimiter=',')

lat = LoRaAirTime()

for line in csv.reader(fi):
    line[2] = int(line[2]) - 35

    if line[3] != '':
        line[3] = line[3][len(line[3])-1]

    if line[4] != '':
        line[4] = int(line[4], 16)

    line[5] = -139 + float(line[5])

    snr = int(line[6])
    if snr > 127:
        snr = snr - 256
    line[6] = snr / 4

    if line[9] == '':
        line[9] = 0

    if line[10] == '' and line[2] == 17 and line[3] == '3' and line[4] == 4:
        line[10] = 65520

    if line[11] == '':
        line[11] = 0
    else:
        line[11] = int(line[11], 0)

    if line[12] == '':
        line[12] = -1
    else:
        line[12] = int(line[12], 0)

    if line[13] == '':
        line[13] = -1

    if line[14] == '':
        line[14] = 0
    else:
        line[14] = int(line[14], 0)

    implicit = True if line[14] & 0b00000100 else False

    lat.preamble_len = 10 if implicit else 8
    lat.payload_len = line[2]
    lat.spreading_factor = int(line[8])
    lat.bandwidth = 125
    lat.coding_rate = int(line[9])
    lat.crc = True if line[4] == 1 or line[4] == 2 else False
    lat.explicit_header = not implicit
    lat.low_data_rate_opt = True if int(line[8]) >= 11 else False

    #for key, value in vars(lat).items():
    #    print(f"{key}: {value}")

    line.append(lat.t_total)

    #print(line)
    writer.writerow(line)
