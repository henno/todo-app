USE todo_app2;
-- Average number of todos per user
SELECT
    COUNT(t.id) / COUNT(DISTINCT t.user_id) as avg_todos_per_user
FROM todos t;

-- Number of todos by completion status
SELECT
    is_completed,
    COUNT(*) as todo_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage
FROM todos
GROUP BY is_completed;

-- Average completion time (in hours) for completed tasks
SELECT
    AVG(TIMESTAMPDIFF(HOUR, created_at, completion_date)) as avg_completion_hours
FROM todos
WHERE is_completed = TRUE
    AND completion_date IS NOT NULL;

-- Statistics for active users (with >5 todos), displaying their username, total todo count, number of priority todos, and the percentage of their todos that are priority items.

SELECT
    u.username,
    COUNT(t.id) as total_todos,
    SUM(t.is_priority) as priority_todos,
    (SUM(t.is_priority) * 100.0 / COUNT(t.id)) as priority_percentage
FROM users u
LEFT JOIN todos t ON u.id = t.user_id
WHERE t.deleted_at IS NULL
GROUP BY u.id, u.username
HAVING COUNT(t.id) > 5;

-- Monthly task creation trends
SELECT
    DATE_FORMAT(created_at, '%Y-%m') as month,
    COUNT(*) as new_todos,
    SUM(is_completed) as completed_todos
FROM todos
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;
