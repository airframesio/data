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

``
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
