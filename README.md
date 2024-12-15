# Todo App

A simple, modern todo list application built with Node.js, Express, and MySQL that helps users manage their daily tasks effectively.

## Current Features

- View all todos in a clean, organized list
  - Scrollable list display
  - Clear title display
  - State persistence after page refresh
- Create new todo items
  - Input field for todo title
  - Add button for creation
  - Empty todos prevented
  - Visual feedback on creation
  - New todos appear at the top

## Coming Soon

- Mark todos as complete/incomplete
- Delete existing todos
- Add descriptions to todos
- Set due dates for tasks
- Edit existing todos
- Priority flags for important tasks
- Sort todos by due date
- Filter between complete and incomplete todos

## Prerequisites

Before running this application, make sure you have the following installed:
- Node.js (v12 or higher)
- MySQL/MariaDB
- npm (Node Package Manager)

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the root directory with the following variables:
```
DB_HOST=your_database_host
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_NAME=todo_app
```

3. Set up the database:
- Create a new MySQL database named `todo_app`
- Import the schema using the provided `schema.sql` file:
```bash
mysql -u your_username -p todo_app < schema.sql
```

## Running the Application

1. Start the server:
```bash
npm start
```

2. Open your browser and navigate to:
```
http://localhost:3000
```

## Project Structure

```
todo-app/
├── src/
│   ├── views/
│   │   ├── index.html
│   │   └── styles.css
│   ├── routes/
│   │   └── todos.js
│   └── index.js
├── schema.sql
└── README.md
```

## Development Status

This project is in early development. Currently, only the basic todo list viewing functionality is implemented. Check our [UserStories.md](UserStories.md) file for detailed information about planned features and their implementation status.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Express.js team for the excellent web framework
- MySQL team for the reliable database system
