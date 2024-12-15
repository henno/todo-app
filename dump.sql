-- Create the database
CREATE DATABASE todo_app;
USE todo_app;

-- Create users table
CREATE TABLE users (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash CHAR(60) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL
);

-- Create the todos table with user FK
CREATE TABLE todos (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    due_date DATETIME,
    is_priority BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    sort_order SMALLINT UNSIGNED,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for common queries
CREATE INDEX idx_is_completed ON todos(is_completed);
CREATE INDEX idx_due_date ON todos(due_date);
CREATE INDEX idx_is_priority ON todos(is_priority);
CREATE INDEX idx_created_at ON todos(created_at);
CREATE INDEX idx_deleted_at ON todos(deleted_at);
CREATE INDEX idx_user_todos ON todos(user_id);

-- Create table for user preferences with user FK
CREATE TABLE user_preferences (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    sort_by ENUM('due_date_asc', 'due_date_desc', 'created_at_asc', 'created_at_desc', 'priority') DEFAULT 'created_at_desc',
    filter_status ENUM('all', 'complete', 'incomplete') DEFAULT 'all',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);