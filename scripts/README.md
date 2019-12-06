# Scripts

## FAA Aircraft Data Import

Import data from the FAA Aircraft database, which contains:
* aircraft registrations
* aircraft reference data
* engine reference data
* reserved N-Numbers
* aircraft deregistrations

### Installation & Usage

1. Clone this whole repository

```
git clone https://github.com/airframesio/data.git
```

2. Enter the new `data` directory

```
cd data
```

3. Customize the script's configuration (database params, etc) **Will be CLI options in future**

```
vi scripts/faa_aircraft_database_importer.py
```

4. Run it

```
scripts/faa_aircraft_database_importer.py
```

It is important to run it in this manner at this time since it uses SQL files to drop and create the DB in relative paths.
I will consider an alternative approach in the future.

### Example Output

```
FAA Database Importer v1.0

Configuration

Database Type    : postgres
Database Host    : localhost
Database Port    : 5432
Database USer    : kevin
Temp Path        : /tmp
FAA Database URL : http://registry.faa.gov/database/ReleasableAircraft.zip

Source Data
  * Retrieving FAA registration database
  * Unzipping to temp directory

Database Setup
  * Dropping existing database tables
  * Creating database tables
  * Connecting to the database

Data Process & Import
  * FAA Aircraft Registration Master File
    - Reading from /tmp/FAA_ReleasableAircraft/MASTER.txt
    - Importing to database
..................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
    - Inserted 289891 records.
  * FAA Aircraft Reference File
    - Reading from /tmp/FAA_ReleasableAircraft/ACFTREF.txt
    - Importing to database
................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
    - Inserted 86422 records.

Complete.
```


### TODO

Lots of stuff to do here still. I will try to improve as time permits. Feel free to submit a pull request!

* CLI options to set the config
  * optional DB drop
  * optional DB create
  * choose which datasets to import
  * database connection details
  * database table names
  * log output / suppression
* Extract into classes/methods to encourage code reuse and cleaner implementation to replace the hack job I put in quick
