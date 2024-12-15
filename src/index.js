const express = require('express');
const mysql = require('mysql2');
const dotenv = require('dotenv');
const path = require('path');
const todosRouter = require('./routes/todos');

dotenv.config();

const app = express();
const port = 3000;

// Database connection
const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

app.use(express.json());
app.use(express.static(path.join(__dirname, 'views')));

app.use('/api/todos', todosRouter(db));

// Frontend routing
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
