const express = require('express');
const router = express.Router();

module.exports = (db) => {
  router.get('/', (req, res) => {
    db.query('SELECT * FROM todos', (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    });
  });

  router.post('/', (req, res) => {
    const { title } = req.body;

    if (!title || !title.trim()) {
      return res.status(400).json({ error: 'Title is required' });
    }

    db.query(
      'INSERT INTO todos (title) VALUES (?)',
      [title.trim()],
      (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Retun the newly created item
        db.query(
          'SELECT * FROM todos WHERE id = ?',
          [result.insertId],
          (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(201).json(results[0]);
          }
        );
      }
    );
  });

  return router;
};
