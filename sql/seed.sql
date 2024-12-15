-- First check if completion_date column exists and add it if it doesn't
SET @dbname = 'todo_app2';
SET @tablename = 'todos';
SET @columnname = 'completion_date';
SET @preparedStatement = (SELECT IF(
    (
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = @dbname
        AND TABLE_NAME = @tablename
        AND COLUMN_NAME = @columnname
    ) > 0,
    "SELECT 1",
    "ALTER TABLE todos ADD COLUMN completion_date TIMESTAMP NULL"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Clear existing data (child tables first)
DELETE FROM user_preferences WHERE 1=1;
DELETE FROM todos WHERE 1=1;
DELETE FROM users WHERE 1=1;

-- Insert test users and verify
INSERT INTO users (username, email, password_hash) VALUES
('john_doe', 'john@example.com', '$2y$10$abcdefghijklmnopqrstuv'),
('jane_smith', 'jane@example.com', '$2y$10$abcdefghijklmnopqrstuv'),
('bob_wilson', 'bob@example.com', '$2y$10$abcdefghijklmnopqrstuv'),
('alice_brown', 'alice@example.com', '$2y$10$abcdefghijklmnopqrstuv'),
('mike_jones', 'mike@example.com', '$2y$10$abcdefghijklmnopqrstuv');

-- Verify users were inserted and show their IDs
SELECT id, username FROM users ORDER BY id;

-- Insert todos with varied completion states, priorities, and dates
INSERT INTO todos (user_id, title, description, is_completed, due_date, is_priority, created_at, completion_date)
VALUES
-- John's todos (heavy user, organized)
((SELECT id FROM users WHERE username = 'john_doe'), 'Buy groceries', 'Milk, bread, eggs', TRUE, '2024-01-20', FALSE, '2024-01-15', '2024-01-19'),
((SELECT id FROM users WHERE username = 'john_doe'), 'Finish report', 'Q4 analysis', TRUE, '2024-01-25', TRUE, '2024-01-10', '2024-01-24'),
((SELECT id FROM users WHERE username = 'john_doe'), 'Gym workout', 'Cardio day', TRUE, '2024-01-18', FALSE, '2024-01-18', '2024-01-18'),
((SELECT id FROM users WHERE username = 'john_doe'), 'Team meeting', 'Sprint planning', FALSE, '2024-02-01', TRUE, '2024-01-15', NULL),
((SELECT id FROM users WHERE username = 'john_doe'), 'Call mom', NULL, FALSE, '2024-02-02', FALSE, '2024-01-25', NULL),

-- Jane's todos (active user, mostly work-related)
((SELECT id FROM users WHERE username = 'jane_smith'), 'Project deadline', 'Submit final version', TRUE, '2024-01-15', TRUE, '2024-01-01', '2024-01-14'),
((SELECT id FROM users WHERE username = 'jane_smith'), 'Review code', 'PR #123', TRUE, '2024-01-10', TRUE, '2024-01-05', '2024-01-09'),
((SELECT id FROM users WHERE username = 'jane_smith'), 'Dentist appointment', NULL, FALSE, '2024-02-05', FALSE, '2024-01-20', NULL),

-- Bob's todos (occasional user)
((SELECT id FROM users WHERE username = 'bob_wilson'), 'Car maintenance', 'Oil change', TRUE, '2024-01-05', FALSE, '2024-01-01', '2024-01-04'),
((SELECT id FROM users WHERE username = 'bob_wilson'), 'Birthday gift', 'For Sarah', FALSE, '2024-02-10', TRUE, '2024-01-15', NULL),

-- Alice's todos (new user)
((SELECT id FROM users WHERE username = 'alice_brown'), 'Setup workspace', NULL, FALSE, '2024-02-01', TRUE, '2024-01-25', NULL),

-- Mike's todos (inactive user)
((SELECT id FROM users WHERE username = 'mike_jones'), 'Old task', 'Never completed', FALSE, '2023-12-01', FALSE, '2023-12-01', NULL);

-- Insert historical todos for trending
INSERT INTO todos (user_id, title, is_completed, created_at, completion_date)
SELECT
    (SELECT id FROM users WHERE username = 'john_doe'),
    CONCAT('Historical Task ', n),
    TRUE,
    DATE_SUB(CURRENT_DATE, INTERVAL n DAY),
    DATE_SUB(CURRENT_DATE, INTERVAL n-2 DAY)
FROM (
    SELECT 1 n UNION SELECT 5 UNION SELECT 10 UNION SELECT 15
    UNION SELECT 30 UNION SELECT 45 UNION SELECT 60 UNION SELECT 90
) numbers;

-- Add user preferences
INSERT INTO user_preferences (user_id, sort_by, filter_status)
SELECT id, 'due_date_asc', 'all' FROM users WHERE username = 'john_doe'
UNION ALL
SELECT id, 'priority', 'incomplete' FROM users WHERE username = 'jane_smith'
UNION ALL
SELECT id, 'created_at_desc', 'all' FROM users WHERE username = 'bob_wilson'
UNION ALL
SELECT id, 'created_at_desc', 'all' FROM users WHERE username = 'alice_brown'
UNION ALL
SELECT id, 'created_at_desc', 'all' FROM users WHERE username = 'mike_jones';

-- Add more todos for better statistics
INSERT INTO todos (user_id, title, description, is_completed, due_date, is_priority, created_at, completion_date)
VALUES
-- More todos for John (making him a power user)
((SELECT id FROM users WHERE username = 'john_doe'), 'Weekly planning', 'Plan next sprint', TRUE, '2024-01-05', TRUE, '2024-01-01', '2024-01-04'),
((SELECT id FROM users WHERE username = 'john_doe'), 'Review budget', 'Q1 projections', TRUE, '2024-01-08', TRUE, '2024-01-02', '2024-01-07'),
((SELECT id FROM users WHERE username = 'john_doe'), 'Team lunch', 'Book restaurant', TRUE, '2024-01-12', FALSE, '2024-01-10', '2024-01-11'),
((SELECT id FROM users WHERE username = 'john_doe'), 'Client meeting', 'Prepare presentation', TRUE, '2024-01-15', TRUE, '2024-01-10', '2024-01-14'),
((SELECT id FROM users WHERE username = 'john_doe'), 'Update wiki', 'Add new procedures', FALSE, '2024-02-05', FALSE, '2024-01-25', NULL),

-- More todos for Jane (making her a heavy user too)
((SELECT id FROM users WHERE username = 'jane_smith'), 'Code review', 'Sprint features', TRUE, '2024-01-08', TRUE, '2024-01-02', '2024-01-07'),
((SELECT id FROM users WHERE username = 'jane_smith'), 'Team training', 'New framework intro', TRUE, '2024-01-12', TRUE, '2024-01-05', '2024-01-11'),
((SELECT id FROM users WHERE username = 'jane_smith'), 'Documentation', 'Update API docs', FALSE, '2024-02-01', FALSE, '2024-01-20', NULL),
((SELECT id FROM users WHERE username = 'jane_smith'), 'Security audit', 'Q1 review', FALSE, '2024-02-10', TRUE, '2024-01-25', NULL),
((SELECT id FROM users WHERE username = 'jane_smith'), 'Performance review', 'Team evaluations', FALSE, '2024-02-15', TRUE, '2024-01-25', NULL),

-- More todos for Bob (making him moderately active)
((SELECT id FROM users WHERE username = 'bob_wilson'), 'Home repair', 'Fix leaky faucet', TRUE, '2024-01-10', FALSE, '2024-01-05', '2024-01-09'),
((SELECT id FROM users WHERE username = 'bob_wilson'), 'Grocery shopping', 'Weekly supplies', TRUE, '2024-01-15', FALSE, '2024-01-12', '2024-01-14'),
((SELECT id FROM users WHERE username = 'bob_wilson'), 'Pay bills', 'Utilities due', FALSE, '2024-02-01', TRUE, '2024-01-25', NULL),
((SELECT id FROM users WHERE username = 'bob_wilson'), 'Doctor appointment', 'Annual checkup', FALSE, '2024-02-20', TRUE, '2024-01-25', NULL);

-- Now we can run statistics like:
SELECT
    u.username,
    COUNT(t.id) as total_todos,
    SUM(t.is_priority) as priority_todos,
    ROUND((SUM(t.is_priority) * 100.0 / COUNT(t.id)), 1) as priority_percentage
FROM users u
JOIN todos t ON u.id = t.user_id
GROUP BY u.id, u.username
HAVING COUNT(t.id) > 5
ORDER BY total_todos DESC;
