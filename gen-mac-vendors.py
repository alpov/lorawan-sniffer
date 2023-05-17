#!/usr/bin/python3

import csv
import urllib.request

urls = ['https://standards-oui.ieee.org/oui/oui.csv',
        'https://standards-oui.ieee.org/oui28/mam.csv',
        'https://standards-oui.ieee.org/oui36/oui36.csv',
        'https://standards-oui.ieee.org/iab/iab.csv']

# Download the CSV files and combine them into a list of dictionaries
data = []
for url in urls:
    with urllib.request.urlopen(url) as response:
        reader = csv.DictReader(response.read().decode('utf-8').splitlines())
        for row in reader:
            data.append(row)

# Sort the list of dictionaries by the length of the 2nd column and then by the content of the 2nd column
data.sort(key=lambda x: (-len(x['Assignment']), x['Assignment']))

# Write the sorted data to a CSV file
with open('MacVendors_allocation.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, delimiter=';')
    for row in data:
        writer.writerow([row['Assignment'], row['Organization Name']])

    writer.writerow(['', 'Unassigned'])

