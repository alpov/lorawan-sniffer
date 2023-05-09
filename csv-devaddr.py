#!/usr/bin/python3

import csv, sys
from tqdm import tqdm

filename = sys.argv[1]  # Replace with the name of your CSV file
writer = csv.writer(open(sys.argv[2], 'w'), delimiter=',')

devaddrs = []
with open('DevAddr_allocation.csv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';')
    for row in reader:
        netid = int(row[0], 16)
        operator = row[1]
        devaddr, netmask = row[2].split('/')
        devaddr = int(devaddr, 16)
        netmask = (1 << 32) - (1 << (32 - int(netmask)))
        devaddrs.append({'netid': netid, 'operator': operator, 'devaddr': devaddr, 'netmask': netmask, 'count': 0})

with open(filename, 'r') as csvfile:
    lines = len(csvfile.readlines())

with open(filename, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in tqdm(reader, total=lines, desc="Processing rows"):
        for devaddr in devaddrs:
            if (int(row[11]) & devaddr['netmask'] == devaddr['devaddr']):
                devaddr['count'] += 1

sorted_counts = [row for row in devaddrs if row['count'] > 0]

counts = {}
for row in sorted_counts:
    operator = row['operator']
    counts[operator] = counts.get(operator, 0) + row['count']

result = [{'operator': operator, 'count': count} for operator, count in counts.items()]
result = sorted(result, key=lambda row: row['count'], reverse=True)

for row in result:
    out = [row['operator'], row['count'], round(row['count'] / lines * 100, 3)]
    writer.writerow(out)
