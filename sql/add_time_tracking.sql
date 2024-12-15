-- Add time estimation and tracking
ALTER TABLE todos
ADD COLUMN estimated_minutes SMALLINT UNSIGNED NULL,
ADD COLUMN actual_minutes SMALLINT UNSIGNED NULL,
ADD COLUMN started_at TIMESTAMP NULL,
ADD INDEX idx_started_at (started_at);