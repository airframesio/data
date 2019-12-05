#!/usr/bin/env python3

#
# faa_aircraft_database_importer.py
#
# Downloads, parses and imports the FAA Aircraft database to a local database.
# Database is automatically set up, but to review schema, see GitHub (https://github.com/airframesio/data/tree/master/db/faa).
#
# Maintainer: Kevin Elliott <kevin@welikeinc.com>
# Source: https://github.com/airframesio/data/tree/master/scripts/faa_aircraft_database_importer.py
#

import os
import sys
from pgdb import Connection

# Configuration
# TODO: Make this configurable as CLI options
database_host = 'localhost'
database_port = 5432
database_user = 'kevin'
database_name = 'airframes'

# Filepaths
temp_path = '/tmp'
faa_database_zip_url = 'http://registry.faa.gov/database/ReleasableAircraft.zip'
faa_download_filename = 'FAA_ReleasableAircraft.zip'
faa_download_extract_path = f'{temp_path}/FAA_ReleasableAircraft'
faa_aircraft_registration_master_filepath = f'{faa_download_extract_path}/MASTER.txt'
faa_aircraft_reference_filepath = f'{faa_download_extract_path}/ACFTREF.txt'

print('FAA Database Importer v1.0 by Kevin Elliott <kevin@welikeinc.com>')
print()

print('Configuration')
print('  Database Type: PostgreSQL')
print(f'  Database Host: {database_host}')
print(f'  Database Port: {database_port}')
print(f'  Database USer: {database_user}')
print(f'  Temp Path: {temp_path}')
print(f'  FAA Database URL: {faa_database_zip_url}')

print()

print('Source Data')

# Retrieve FAA registration database
print('  * Retrieving FAA registration database')
output = os.popen(f'wget -q -O {temp_path}/{faa_download_filename} {faa_database_zip_url}').read()

# Uncompress retrieved zip
print('  * Unzipping to temp directory')
output = os.popen(f'unzip -o {temp_path}/{faa_download_filename} -d {faa_download_extract_path}').read()

print()

print('Database Setup')
# Drop tables
# TODO: Make this optional
print('  * Dropping existing database tables')
output = os.popen("psql -h localhost -p 5432 airframes < db/faa/drop.sql").read()

# Create tables
print('  * Creating database tables')
output = os.popen("psql -h localhost -p 5432 airframes < db/faa/create.sql").read()

# Connect to the DB
print('  * Connecting to the database')
connection = Connection(user=database_user, database=database_name, host=database_host, port=database_port)

print()

def clean(str):
  if str:
    str = str.strip()
    if str != '':
      return str
    else:
      return None
  else:
    return None


print('Data Process & Import')

# Import the Master reference
print('  * FAA Aircraft Registration Master File')
with open(faa_aircraft_registration_master_filepath) as f:
  print(f'    - Reading from {faa_aircraft_registration_master_filepath}')
  content = f.readlines()
  count = 0
  print('    - Importing to database')
  for line in content:
    data = line.split(',')
    if count>0:
      insert_args = (
        clean(data[30]),
        clean(data[0]),
        int(data[21].strip()),
        clean(data[34]),
        clean(data[1]),
        clean(data[20]),
        clean(data[2]),
        clean(data[18]),
        int(data[19].strip()),
        clean(data[3]),
        clean(data[31]),
        clean(data[32]),
        clean(data[4]),
        clean(data[5]),
        clean(data[6]),
        clean(data[7]),
        clean(data[8]),
        clean(data[9]),
        clean(data[10]),
        clean(data[12]),
        clean(data[13]),
        clean(data[11]),
        clean(data[14]),
        clean(data[17]),
        clean(data[22]),
        clean(data[24]),
        clean(data[25]),
        clean(data[26]),
        clean(data[27]),
        clean(data[28]),
        clean(data[23]),
        clean(data[16]),
        clean(data[29]),
        clean(data[15])
      )
      connection.execute(
        "INSERT INTO faa_aircraft_registration_master VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
        insert_args
      )
    count = count + 1
    if count % 100 == 0:
      print('.', end = '', flush = True)
  print()
  print(f'    - Inserted {count - 1} records.')

# Import the Aircraft Reference File
print('  * FAA Aircraft Reference File')
with open(faa_aircraft_reference_filepath) as f:
  print(f'    - Reading from {faa_aircraft_reference_filepath}')
  content = f.readlines()
  count = 0
  print('    - Importing to database')
  for line in content:
    data = line.split(',')
    if count>0:
      insert_args = (
        clean(data[0]),
        clean(data[0])[0:3],
        clean(data[0])[3:5],
        clean(data[0])[5:7],
        clean(data[1]),
        clean(data[2]),
        clean(data[3]),
        int(data[4].strip()),
        int(data[5].strip()),
        int(data[6].strip()),
        int(data[7].strip()),
        int(data[8].strip()),
        clean(data[9]),
        int(data[10].strip())
      )
      # print(insert_args)
      connection.execute(
        "INSERT INTO faa_aircraft_reference VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
        insert_args
      )
    count = count + 1
    if count % 100 == 0:
      print('.', end = '', flush = True)
  print()
  print(f'    - Inserted {count - 1} records.')

print()

if (connection):
  connection.close()

print('Complete.')
