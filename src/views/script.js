document.addEventListener('DOMContentLoaded', () => {
    const todoInput = document.querySelector('.todo-input');
    const addButton = document.querySelector('.add-button');
    const todoList = document.querySelector('.todo-list');
    const feedback = document.querySelector('.feedback');

    const showFeedback = (message, isSuccess = true) => {
        feedback.textContent = message;
        feedback.className = `feedback ${isSuccess ? 'success' : 'error'}`;
        feedback.style.display = 'block';
        setTimeout(() => {
            feedback.style.display = 'none';
        }, 3000);
    };

    const createTodo = async (title) => {
        try {
            const response = await fetch('/api/todos', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ title })
            });

            if (!response.ok) {
                showFeedback('Failed to create todo', false);
                return;
            }

            const newTodo = await response.json();

            // Create new item
            const todoItem = document.createElement('div');
            todoItem.className = 'todo-item';
            todoItem.innerHTML = `
                <input type="checkbox" id="todo-${newTodo.id}">
                <label for="todo-${newTodo.id}">${newTodo.title}</label>
            `;

            // Add new item to the top of the list
            todoList.insertBefore(todoItem, todoList.firstChild);

            showFeedback('Todo created successfully!');
            todoInput.value = ''; // Clear input
        } catch (error) {
            showFeedback('Failed to create todo', false);
            console.error('Error:', error);
        }
    };

    // Handle input changes to enable/disable button
    todoInput.addEventListener('input', () => {
        addButton.disabled = !todoInput.value.trim();
    });

    // Handle form submission
    addButton.addEventListener('click', () => {
        const title = todoInput.value.trim();
        if (title) {
            createTodo(title);
        }
    });

    // Handle Enter key
    todoInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            const title = todoInput.value.trim();
            if (title) {
                createTodo(title);
            }
        }
    });

    // Initially disable button
    addButton.disabled = true;
});
