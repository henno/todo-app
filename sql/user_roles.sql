-- Documentation:
-- CREATE [OR REPLACE] ROLE [IF NOT EXISTS] role
-- [WITH ADMIN
--    {CURRENT_USER | CURRENT_ROLE | user | role}]

-- Create roles
CREATE ROLE IF NOT EXISTS 'todo_admin';
CREATE ROLE IF NOT EXISTS 'todo_user';

-- Admin permissions (full access)
GRANT ALL PRIVILEGES ON todo_app2.* TO 'todo_admin';

-- User permissions (limited access)
GRANT SELECT, INSERT, UPDATE ON todo_app2.todos TO 'todo_user';
GRANT SELECT ON todo_app2.users TO 'todo_user';
GRANT SELECT, UPDATE ON todo_app2.user_preferences TO 'todo_user';
GRANT SELECT ON todo_app2.todos_audit TO 'todo_user';

-- Create test users with different roles
CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'admin_pass123';
CREATE USER IF NOT EXISTS 'regular_user2'@'localhost' IDENTIFIED BY 'user_pass123';

-- Assign roles to users
GRANT 'todo_admin' TO 'admin_user'@'localhost';
GRANT 'todo_user' TO 'regular_user2'@'localhost';

-- Test users with specific permissions
CREATE USER IF NOT EXISTS 'test_admin'@'localhost' IDENTIFIED BY 'test_admin_pass';
CREATE USER IF NOT EXISTS 'test_user'@'localhost' IDENTIFIED BY 'test_user_pass';

-- Grant specific permissions to test users
GRANT ALL PRIVILEGES ON todo_app2.* TO 'test_admin'@'localhost';
GRANT SELECT, INSERT, UPDATE ON todo_app2.todos TO 'test_user'@'localhost';
GRANT SELECT ON todo_app2.users TO 'test_user'@'localhost';

-- Test users with limited permissions
-- Log in as test_user and try to delete all todos
-- DELETE FROM todos WHERE 1;
SELECT * FROM mysql.roles_mapping;
SELECT * FROM information_schema.applicable_roles;



-- Additional security measures
REVOKE ALL PRIVILEGES ON *.* FROM 'regular_user'@'localhost';
REVOKE ALL PRIVILEGES ON *.* FROM 'test_user'@'localhost';

-- Force users to change password on first login
ALTER USER 'admin_user'@'localhost' PASSWORD EXPIRE;
ALTER USER 'regular_user'@'localhost' PASSWORD EXPIRE;

-- Verify setup with these queries:
SHOW GRANTS FOR 'admin_user'@'localhost';
SHOW GRANTS FOR 'regular_user'@'localhost';
