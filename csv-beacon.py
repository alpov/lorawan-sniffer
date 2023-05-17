#!/usr/bin/python3

import csv, sys, math

fi = open(sys.argv[1], 'r')
fo = open(sys.argv[2], 'w')
mode = sys.argv[3]
writer = csv.writer(fo, delimiter=',')

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

    payload = line[14]
    b = bytes.fromhex(payload[4:12])
    b = b[::-1]
    b = b.hex()
    epoch1 = int(b, 16) + 315964800 - 18
    epoch2 = float(line[1])
    epochdiff = epoch2 - epoch1

    line.append(epochdiff)
    epochdiff = math.floor(epochdiff)

    if (
            (mode == 'all') or
            (mode == 'invalid' and epochdiff != 0 and epochdiff != 18) or
            (mode == 'valid' and epochdiff == 0) or
            (mode == 'utcshift' and epochdiff == 18)
       ):
        #print(line)
        writer.writerow(line)
