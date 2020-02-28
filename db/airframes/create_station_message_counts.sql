BEGIN;

DROP TRIGGER IF EXISTS station_message_count ON messages;
DROP TABLE IF EXISTS station_message_counts;
DROP FUNCTION IF EXISTS adjust_station_message_count;

CREATE TABLE station_message_counts (
  id SERIAL PRIMARY KEY,
  station_id int DEFAULT 0 UNIQUE,
  messages_count bigint
);

INSERT INTO station_message_counts (station_id, messages_count)
SELECT station_id, count(*) FROM messages GROUP BY station_id;

CREATE OR REPLACE FUNCTION adjust_station_message_count()
RETURNS TRIGGER AS
$$
   BEGIN
   IF TG_OP = 'INSERT' THEN
     EXECUTE 'INSERT INTO station_message_counts (station_id, messages_count) VALUES ($1, 0) ON CONFLICT DO NOTHING' USING NEW.station_id;
     EXECUTE 'UPDATE station_message_counts set messages_count=messages_count +1 where station_id = $1' USING NEW.station_id;
     RETURN NEW;
   ELSIF TG_OP = 'DELETE' THEN
	 EXECUTE 'INSERT INTO station_message_counts (station_id, messages_count) VALUES ($1, 1) ON CONFLICT DO NOTHING' USING OLD.station_id;
     EXECUTE 'UPDATE station_message_counts set messages_count=messages_count -1 where station_id = $1' USING OLD.station_id;
     RETURN OLD;
   END IF;
   END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER station_message_count BEFORE INSERT OR DELETE ON messages
  FOR EACH ROW EXECUTE PROCEDURE adjust_station_message_count();

COMMIT;

GRANT ALL ON TABLE station_message_counts TO airframes;
GRANT ALL ON TABLE station_message_counts TO airframes_aggregator;
GRANT ALL ON TABLE station_message_counts TO airframes_backend;
GRANT ALL ON TABLE station_message_counts TO airframes_backend_readonly;

GRANT ALL ON SEQUENCE station_message_counts_id_seq TO airframes;
GRANT ALL ON SEQUENCE station_message_counts_id_seq TO airframes_aggregator;
GRANT ALL ON SEQUENCE station_message_counts_id_seq TO airframes_backend;
GRANT ALL ON SEQUENCE station_message_counts_id_seq TO airframes_backend_readonly;
