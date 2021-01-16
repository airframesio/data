CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS stations (
  id SERIAL PRIMARY KEY,
  uuid UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
  ident VARCHAR(255),
  ip_address VARCHAR(255),
  user_id UUID,
  description TEXT,
  latitude FLOAT,
  longitude FLOAT,
  altitude FLOAT,
  nearest_airport_icao VARCHAR(4),
  source_application VARCHAR(255),
  source_type VARCHAR(255),
  source_protocol VARCHAR(255),
  system_platform VARCHAR(255),
  system_os VARCHAR(255),
  equipment_sdr VARCHAR(255),
  equipment_filters VARCHAR(255),
  equipment_antenna VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  last_report_at TIMESTAMP,
  status VARCHAR(255) NOT NULL DEFAULT 'pending-reception',
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

CREATE TABLE IF NOT EXISTS flight_positions (
  id SERIAL PRIMARY KEY,
  flight_id INTEGER NOT NULL,
  message_id INTEGER NOT NULL,
  latitude FLOAT,
  longitude FLOAT,
  altitude INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS leaderboards (
  id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX index_l_date ON leaderboards (date);

CREATE TABLE IF NOT EXISTS leaderboard_ranks (
  id SERIAL PRIMARY KEY,
  leaderboard_id INTEGER NOT NULL,
  station_id INTEGER NOT NULL,
  points INTEGER NOT NULL DEFAULT 0,
  points_detail JSONB NOT NULL DEFAULT '{}',
  ranking INTEGER NOT NULL DEFAULT -1,
  airframe_all_time_count INTEGER NOT NULL DEFAULT 0,
  airframe_this_month_count INTEGER NOT NULL DEFAULT 0,
  airframe_last_24_hours_count INTEGER NOT NULL DEFAULT 0,
  flight_all_time_count INTEGER NOT NULL DEFAULT 0,
  flight_this_month_count INTEGER NOT NULL DEFAULT 0,
  flight_last_24_hours_count INTEGER NOT NULL DEFAULT 0,
  message_all_time_count INTEGER NOT NULL DEFAULT 0,
  message_this_month_count INTEGER NOT NULL DEFAULT 0,
  message_last_24_hours_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX index_lr_leaderboard_id ON leaderboard_ranks (leaderboard_id);
CREATE INDEX index_lr_ranking ON leaderboard_ranks (ranking);
CREATE UNIQUE INDEX index_lr_lsr ON leaderboard_ranks (leaderboard_id, station_id, ranking);
CREATE INDEX index_lr_points ON leaderboard_ranks (points);
CREATE INDEX index_lr_airframe_all_time_count ON leaderboard_ranks (airframe_all_time_count);
CREATE INDEX index_lr_airframe_this_month_count ON leaderboard_ranks (airframe_this_month_count);
CREATE INDEX index_lr_airframe_last_24_hours_count ON leaderboard_ranks (airframe_last_24_hours_count);
CREATE INDEX index_lr_flight_all_time_count ON leaderboard_ranks (flight_all_time_count);
CREATE INDEX index_lr_flight_this_month_count ON leaderboard_ranks (flight_this_month_count);
CREATE INDEX index_lr_flight_last_24_hours_count ON leaderboard_ranks (flight_last_24_hours_count);
CREATE INDEX index_lr_message_all_time_count ON leaderboard_ranks (message_all_time_count);
CREATE INDEX index_lr_message_this_month_count ON leaderboard_ranks (message_this_month_count);
CREATE INDEX index_lr_message_last_24_hours_count ON leaderboard_ranks(message_last_24_hours_count);

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

CREATE TABLE IF NOT EXISTS message_decodings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id INTEGER NOT NULL,
  decoder_name VARCHAR(30),
  decoder_version VARCHAR(10),
  decoder_type VARCHAR(30),
  decoder_plugin VARCHAR(50),
  decode_level VARCHAR(10),
  result_raw JSONB NOT NULL DEFAULT '{}',
  result_formatted JSONB NOT NULL DEFAULT '{}',
  remaining_undecoded JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS message_reports (
  id SERIAL PRIMARY KEY,
  message_id INTEGER NOT NULL,
  station_id INTEGER NOT NULL,
  first_to_report BOOLEAN NOT NULL DEFAULT false,
  source_name VARCHAR(255),
  source_application VARCHAR(255),
  source_type VARCHAR(255),
  source_protocol VARCHAR(255),
  source_format VARCHAR(255),
  source_network_protocol VARCHAR(255),
  source_remote_ip VARCHAR(255),
  frequency FLOAT,
  channel INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS report_daily_counts (
  id SERIAL PRIMARY KEY,
  station_id INTEGER NOT NULL,
  date DATE,
  airframes_count INTEGER DEFAULT 0,
  flights_count INTEGER DEFAULT 0,
  messages_count INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX index_rdc_station_id_date ON report_daily_counts (station_id, date);

INSERT INTO report_daily_counts (station_id, date, messages_count)
  SELECT station_id, DATE(created_at) as date, COUNT(*) as messages_count
  FROM messages
  WHERE station_id IS NOT NULL AND created_at > current_date - interval '1 month'
  GROUP BY station_id, date
  ORDER BY station_id, date
ON CONFLICT (station_id, date) DO UPDATE
  SET messages_count = excluded.messages_count;


CREATE TABLE IF NOT EXISTS report_hourly_counts (
  id SERIAL PRIMARY KEY,
  station_id INTEGER NOT NULL,
  hour TIMESTAMP,
  airframes_count INTEGER DEFAULT 0,
  flights_count INTEGER DEFAULT 0,
  messages_count INTEGER DEFAULT 0,
  created_at TIME NOT NULL DEFAULT NOW(),
  updated_at TIME NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX index_rhc_station_id_hour ON report_hourly_counts (station_id, hour);

INSERT INTO report_hourly_counts (station_id, hour, messages_count)
  SELECT station_id, DATE_TRUNC('hour', created_at) as hour, COUNT(*) as messages_count
  FROM messages
  WHERE station_id IS NOT NULL AND created_at > current_date - interval '1 day'
  GROUP BY station_id, hour
  ORDER BY station_id, hour
ON CONFLICT (station_id, hour) DO UPDATE
  SET messages_count = excluded.messages_count;

CREATE TABLE IF NOT EXISTS report_monthly_counts (
  id SERIAL PRIMARY KEY,
  station_id INTEGER NOT NULL,
  date DATE,
  airframes_count INTEGER DEFAULT 0,
  flights_count INTEGER DEFAULT 0,
  messages_count INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX index_rmc_station_id_date ON report_monthly_counts (station_id, date);

INSERT INTO report_monthly_counts (station_id, date, messages_count)
  SELECT station_id, DATE_TRUNC('month', created_at) as date, COUNT(*) as messages_count
  FROM messages
  WHERE station_id IS NOT NULL AND created_at > current_date - interval '1 year'
  GROUP BY station_id, date
  ORDER BY station_id, date
ON CONFLICT (station_id, date) DO UPDATE
  SET messages_count = excluded.messages_count;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255),
  encrypted_password VARCHAR(255),
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  api_key TEXT NOT NULL DEFAULT MD5(random()::text),
  status VARCHAR(100) NOT NULL DEFAULT 'pending-confirmation',
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
CREATE INDEX IF NOT EXISTS idx_flights_status ON flights (status);
CREATE INDEX IF NOT EXISTS idx_flights_updated_at ON flights (updated_at);
CREATE INDEX IF NOT EXISTS idx_flight_positions_created_at ON flight_positions (created_at);
CREATE INDEX IF NOT EXISTS idx_flight_positions_flight_id ON flight_positions (flight_id);
CREATE INDEX IF NOT EXISTS idx_flight_positions_message_id ON flight_positions (message_id);
CREATE INDEX IF NOT EXISTS idx_flight_positions_updated_at ON flight_positions (updated_at);
CREATE INDEX IF NOT EXISTS idx_messages_airframe_id ON messages (airframe_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages (created_at);
CREATE INDEX IF NOT EXISTS idx_messages_flight_id ON messages (flight_id);
CREATE INDEX IF NOT EXISTS idx_messages_label ON messages (label);
CREATE INDEX IF NOT EXISTS idx_messages_message_number ON messages (message_number);
CREATE INDEX IF NOT EXISTS idx_messages_source ON messages (source);
CREATE INDEX IF NOT EXISTS idx_messages_source_type ON messages (source_type);
CREATE INDEX IF NOT EXISTS idx_messages_station_id ON messages (station_id);
CREATE INDEX IF NOT EXISTS idx_messages_tail ON messages (tail);
CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages (timestamp);
CREATE INDEX IF NOT EXISTS idx_messages_updated_at ON messages (updated_at);
CREATE INDEX IF NOT EXISTS idx_stations_id ON stations (id);
CREATE INDEX IF NOT EXISTS idx_stations_ident ON stations (ident);
CREATE INDEX IF NOT EXISTS idx_vgs_icao_hex ON vdl_ground_stations (icao_hex);
CREATE INDEX IF NOT EXISTS idx_vgs_icao_int ON vdl_ground_stations (icao_int);
CREATE INDEX IF NOT EXISTS idx_vgs_network ON vdl_ground_stations (network);
CREATE INDEX IF NOT EXISTS idx_vgs_airport_icao ON vdl_ground_stations (airport_icao);
CREATE INDEX IF NOT EXISTS idx_vgs_airport_iata ON vdl_ground_stations (airport_iata);
