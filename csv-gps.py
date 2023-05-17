#!/usr/bin/python3

import csv, sys
from datetime import datetime

def cf_coords_lat_custom(value):
    coord_int = value if value < 0x00800000 else value - 0x01000000
    coord_double = coord_int * 90. / 0x00800000

    return f"{abs(coord_double):.5f}{'N' if coord_double >= 0 else 'S'}"


def cf_coords_lng_custom(value):
    coord_int = value if value < 0x00800000 else value - 0x01000000
    coord_double = coord_int * 180. / 0x00800000

    return f"{abs(coord_double):.5f}{'E' if coord_double >= 0 else 'W'}"


filename = sys.argv[1]  # replace with your CSV file
output_file = sys.argv[2]

unique_gps = {}

with open(filename, 'r') as csvfile:
    reader = csv.reader(csvfile)
    #next(reader)  # skip header row
    for row in reader:
        latitude = cf_coords_lat_custom(int(row[15]))
        longitude = cf_coords_lng_custom(int(row[16]))
        gps_pair = (latitude, longitude)
        unique_gps[gps_pair] = unique_gps.get(gps_pair, 0) + 1


with open(output_file, "w") as f:
    f.write(
        '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>\n'
        '<gpx xmlns="http://www.topografix.com/GPX/1/1" '
        'creator="Python GPX Library - https://github.com/tkrajina/gpxpy" '
        'version="1.1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
        'http://www.topografix.com/GPX/1/1/gpx.xsd">\n'
    )
    for gps_pair, count in unique_gps.items():
        print(f"{gps_pair[0]}, {gps_pair[1]}: {count} occurrences")
        description1 = f"{gps_pair[0]}, {gps_pair[1]}"
        description2 = f"{count} occurrences"
        f.write(
            f'<wpt lat="{gps_pair[0]}" lon="{gps_pair[1]}">\n'
            f'    <name>{description1}</name>\n'
            f'    <desc>{description2}</desc>\n'
            f'</wpt>\n'
        )
    f.write('</gpx>\n')
