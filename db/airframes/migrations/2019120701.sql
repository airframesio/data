ALTER TABLE messages
ADD COLUMN source_type VARCHAR(10);

CREATE INDEX IF NOT EXISTS idx_messages_source_type ON messages (source_type);
