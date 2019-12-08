CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS stations (
  id SERIAL PRIMARY KEY,
  uuid UUID NOT NULL DEFAULT uuid_generate_v4(),
  ident VARCHAR(255),
  ip_address VARCHAR(255),
  user_id INTEGER,
  email VARCHAR(255),
  latitude FLOAT,
  longitude FLOAT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  last_report_at TIMESTAMP,
  UNIQUE (ident)
);

CREATE TABLE IF NOT EXISTS airframes (
  id SERIAL PRIMARY KEY,
  tail VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (tail)
);

CREATE TABLE IF NOT EXISTS flights (
  id SERIAL PRIMARY KEY,
  airframe_id INTEGER NOT NULL,
  flight VARCHAR(255),
  departing_airport VARCHAR(10),
  destination_airport VARCHAR(10),
  messages_count INTEGER NOT NULL DEFAULT 0,
  status VARCHAR(255) NOT NULL DEFAULT 'active',
  latitude FLOAT,
  longitude FLOAT,
  altitude INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS flight_coordinates (
  id SERIAL PRIMARY KEY,
  flight_id INTEGER NOT NULL,
  latitude FLOAT,
  longitude FLOAT,
  altitude INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMP,
  source VARCHAR(10),
  source_type VARCHAR(10),
  link_direction VARCHAR(10),
  from_hex VARCHAR(10),
  to_hex VARCHAR(10),
  station_id INTEGER,
  airframe_id INTEGER,
  flight_id INTEGER,
  tail VARCHAR(255),
  flight VARCHAR(255),
  channel INTEGER,
  frequency FLOAT,
  level INTEGER,
  error INTEGER,
  mode VARCHAR(255),
  label VARCHAR(255),
  block_id VARCHAR(255),
  message_number VARCHAR(255),
  ack BOOLEAN,
  data TEXT,
  text TEXT,
  departing_airport VARCHAR(10),
  destination_airport VARCHAR(10),
  latitude FLOAT,
  longitude FLOAT,
  altitude  INTEGER,
  block_end BOOLEAN,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS message_decodes (
  id SERIAL PRIMARY KEY,
  message_id INTEGER NOT NULL,
  decoded_text TEXT,
  decoded_data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vdl_ground_stations (
  id SERIAL PRIMARY KEY,
  icao_hex VARCHAR(10),
  icao_int INTEGER,
  network VARCHAR(10),
  airport_icao VARCHAR(4),
  airport_iata VARCHAR(3),
  airport_name VARCHAR(255),
  airport_city VARCHAR(255),
  airport_region VARCHAR(255),
  airport_country_code VARCHAR(2),
  airport_latitude FLOAT,
  airport_longitude FLOAT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_flights_airframe_id ON flights (airframe_id);
CREATE INDEX IF NOT EXISTS idx_messages_airframe_id ON messages (airframe_id);
CREATE INDEX IF NOT EXISTS idx_messages_flight_id ON messages (flight_id);
CREATE INDEX IF NOT EXISTS idx_messages_label ON messages (label);
CREATE INDEX IF NOT EXISTS idx_messages_source ON messages (source);
CREATE INDEX IF NOT EXISTS idx_messages_source_type ON messages (source_type);
CREATE INDEX IF NOT EXISTS idx_messages_station_id ON messages (station_id);
CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages (timestamp);
CREATE INDEX IF NOT EXISTS idx_stations_id ON stations (id);
CREATE INDEX IF NOT EXISTS idx_stations_ident ON stations (ident);
CREATE INDEX IF NOT EXISTS idx_vgs_icao_hex ON vdl_ground_stations (icao_hex);
CREATE INDEX IF NOT EXISTS idx_vgs_icao_int ON vdl_ground_stations (icao_int);
CREATE INDEX IF NOT EXISTS idx_vgs_network ON vdl_ground_stations (network);
CREATE INDEX IF NOT EXISTS idx_vgs_airport_icao ON vdl_ground_stations (airport_icao);
CREATE INDEX IF NOT EXISTS idx_vgs_airport_iata ON vdl_ground_stations (airport_iata);
