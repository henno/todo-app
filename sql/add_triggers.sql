-- Create audit table for todos
CREATE TABLE todos_audit (
    audit_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    todo_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    old_title VARCHAR(100),
    new_title VARCHAR(100),
    old_description TEXT,
    new_description TEXT,
    old_is_completed BOOLEAN,
    new_is_completed BOOLEAN,
    old_due_date DATETIME,
    new_due_date DATETIME,
    old_is_priority BOOLEAN,
    new_is_priority BOOLEAN,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for INSERT auditing
DELIMITER //
CREATE TRIGGER todos_after_insert
AFTER INSERT ON todos
FOR EACH ROW
BEGIN
    INSERT INTO todos_audit (
        action_type, todo_id, user_id,
        new_title, new_description, new_is_completed,
        new_due_date, new_is_priority
    )
    VALUES (
        'INSERT', NEW.id, NEW.user_id,
        NEW.title, NEW.description, NEW.is_completed,
        NEW.due_date, NEW.is_priority
    );
END//

-- Trigger for UPDATE auditing
CREATE TRIGGER todos_after_update
AFTER UPDATE ON todos
FOR EACH ROW
BEGIN
    INSERT INTO todos_audit (
        action_type, todo_id, user_id,
        old_title, new_title,
        old_description, new_description,
        old_is_completed, new_is_completed,
        old_due_date, new_due_date,
        old_is_priority, new_is_priority
    )
    VALUES (
        'UPDATE', NEW.id, NEW.user_id,
        OLD.title, NEW.title,
        OLD.description, NEW.description,
        OLD.is_completed, NEW.is_completed,
        OLD.due_date, NEW.due_date,
        OLD.is_priority, NEW.is_priority
    );
END//

-- Trigger for DELETE auditing
CREATE TRIGGER todos_after_delete
AFTER DELETE ON todos
FOR EACH ROW
BEGIN
    INSERT INTO todos_audit (
        action_type, todo_id, user_id,
        old_title, old_description, old_is_completed,
        old_due_date, old_is_priority
    )
    VALUES (
        'DELETE', OLD.id, OLD.user_id,
        OLD.title, OLD.description, OLD.is_completed,
        OLD.due_date, OLD.is_priority
    );
END//

-- Data integrity triggers
CREATE TRIGGER todos_before_insert
BEFORE INSERT ON todos
FOR EACH ROW
BEGIN
    -- Check title length (minimum 3 characters)
    IF LENGTH(NEW.title) < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Todo title must be at least 3 characters long';
    END IF;

    -- Check if due_date is not in the past
    IF NEW.due_date < CURRENT_TIMESTAMP THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Due date cannot be in the past';
    END IF;

    -- Set default sort_order if not provided
    IF NEW.sort_order IS NULL THEN
        SET NEW.sort_order = (
            SELECT COALESCE(MAX(sort_order) + 1, 1)
            FROM todos
            WHERE user_id = NEW.user_id
        );
    END IF;
END//

-- Update integrity trigger
CREATE TRIGGER todos_before_update
BEFORE UPDATE ON todos
FOR EACH ROW
BEGIN
    -- Check title length on update
    IF LENGTH(NEW.title) < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Todo title must be at least 3 characters long';
    END IF;

    -- Check if due_date is not in the past (only for new todos)
    IF NEW.due_date < CURRENT_TIMESTAMP AND OLD.due_date != NEW.due_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Due date cannot be in the past';
    END IF;

    -- Set completion_date when item is marked as completed
    IF NEW.is_completed = TRUE AND OLD.is_completed = FALSE THEN
        SET NEW.completion_date = CURRENT_TIMESTAMP;
    END IF;
END//

DELIMITER ;

-- Test too short title
INSERT INTO todos (title, user_id) VALUES ('1', 26);

-- Test due date in the past
INSERT INTO todos (title, due_date, user_id) VALUES ('2ss', '2023-12-01', 26);

