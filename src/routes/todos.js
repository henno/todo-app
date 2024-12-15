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

  router.patch('/:id', (req, res) => {
    const { id } = req.params;
    const { completed } = req.body;

    if (typeof completed !== 'boolean') {
      return res.status(400).json({ error: 'Completed status must be a boolean' });
    }

    db.query(
      'UPDATE todos SET completed = ? WHERE id = ?',
      [completed, id],
      (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Todo not found' });
        
        db.query('SELECT * FROM todos WHERE id = ?', [id], (err, results) => {
          if (err) return res.status(500).json({ error: err.message });
          res.json(results[0]);
        });
      }
    );
  });

  return router;
};
