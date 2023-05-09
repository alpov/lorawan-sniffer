#!/usr/bin/python3

import csv, sys
from tqdm import tqdm

filename = sys.argv[1]  # Replace with the name of your CSV file
writer = csv.writer(open(sys.argv[2], 'w'), delimiter=',')

ouis = []
with open('MacVendors_allocation.csv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';')
    for row in reader:
        oui = row[0]
        operator = row[1]
        ouis.append({'oui': oui, 'operator': operator, 'count': 0})

with open(filename, 'r') as csvfile:
    lines = len(csvfile.readlines())

with open(filename, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in tqdm(reader, total=lines, desc="Processing rows"):
        s = row[16].replace(':', '').upper()
        for oui in ouis:
            if s.startswith(oui['oui']):
                oui['count'] += 1
                break

sorted_counts = [row for row in ouis if row['count'] > 0]

counts = {}
for row in sorted_counts:
    operator = row['operator']
    counts[operator] = counts.get(operator, 0) + row['count']

result = [{'operator': operator, 'count': count} for operator, count in counts.items()]
result = sorted(result, key=lambda row: row['count'], reverse=True)

for row in result:
    out = [row['operator'], row['count'], round(row['count'] / lines * 100, 3)]
    writer.writerow(out)
