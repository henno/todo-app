-- Prevent duplicate items
ALTER TABLE todos
    ADD UNIQUE INDEX idx_user_title (user_id, title);
