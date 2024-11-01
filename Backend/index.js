const express = require("express");
const mysql = require("mysql2");
const port = process.env.PORT || 3000;
const { body, validationResult } = require('express-validator');

const app = express();
app.use(express.json());

// Connect to MySQL database
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "PawFeeder",
});

// Connect to the database
connection.connect((err) => {
  if (err) {
    console.error("Database connection failed: " + err.stack);
    return;
  }
  console.log("Connected to database as ID " + connection.threadId);
});

// Routes for Pengguna (Users)
app.post('/pengguna', [
  body('username').isString().notEmpty(),
  body('email').isEmail(),
  body('password_hash').isString().notEmpty(),
  body('nama_lengkap').isString().notEmpty(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { username, email, password_hash, nama_lengkap } = req.body;
  const query = 'INSERT INTO Pengguna (username, email, password_hash, nama_lengkap) VALUES (?, ?, ?, ?)';
  connection.execute(query, [username, email, password_hash, nama_lengkap], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id_pengguna: results.insertId });
  });
});

// GET all users
app.get('/pengguna', (req, res) => {
  const query = 'SELECT * FROM Pengguna';
  connection.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Routes for KucingPengguna (User Cats)
app.post('/kucing', [
  body('id_pengguna').isInt(),
  body('nama').isString().notEmpty(),
  body('jenis').isString().notEmpty(),
  body('usia').isInt(),
  body('berat').isDecimal(),
  body('kebutuhan_kalori').optional().isInt(),
  body('id_sensor').isString().notEmpty(),
  body('foto_kucing').optional().isString(),
  body('status').isString().isIn(['active', 'inactive']),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id_pengguna, nama, jenis, usia, berat, kebutuhan_kalori, id_sensor, foto_kucing, status } = req.body;
  const query = 'INSERT INTO KucingPengguna (id_pengguna, nama, jenis, usia, berat, kebutuhan_kalori, id_sensor, foto_kucing, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
  connection.execute(query, [id_pengguna, nama, jenis, usia, berat, kebutuhan_kalori, id_sensor, foto_kucing, status], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id_kucing: results.insertId });
  });
});

// GET all cats for a specific user
app.get('/kucing/:id_pengguna', (req, res) => {
  const { id_pengguna } = req.params;
  const query = 'SELECT * FROM KucingPengguna WHERE id_pengguna = ?';
  connection.query(query, [id_pengguna], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Route to create a feeding schedule with varying times
app.post('/jadwal-makan', [
  body('id_kucing').isInt(),
  body('waktu_makan_array').isArray().notEmpty(),
  body('jumlah_pemberian').isInt(),
  body('kebutuhan_kalori').optional().isInt(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id_kucing, waktu_makan_array, jumlah_pemberian, kebutuhan_kalori } = req.body;

  // Calculate the amount of food needed per feeding
  let foodPerFeeding = kebutuhan_kalori ? (kebutuhan_kalori / jumlah_pemberian) : 100; // Default if no calorie requirement

  // Insert feeding schedule for each specified feeding time
  const insertPromises = waktu_makan_array.map(waktu_makan => {
    const query = 'INSERT INTO JadwalPemberianMakan (id_kucing, waktu_makan) VALUES (?, ?)';
    return new Promise((resolve, reject) => {
      connection.execute(query, [id_kucing, waktu_makan], (err, results) => {
        if (err) return reject(err);
        // Log the food amount calculated for each feeding schedule
        console.log(`For cat ID ${id_kucing}, at time ${waktu_makan}, dispense ${foodPerFeeding} grams of food.`);
        resolve({
          id_detail: results.insertId,
          waktu_makan,
          foodPerFeeding,
        });
      });
    });
  });

  // Wait for all inserts to complete
  Promise.all(insertPromises)
    .then(results => {
      res.status(201).json({
        message: 'Feeding schedule created successfully',
        schedules: results,
      });
    })
    .catch(err => {
      res.status(500).json({ error: err.message });
    });
});

// GET feeding schedule for a specific cat
app.get('/jadwal-makan/:id_kucing', (req, res) => {
  const { id_kucing } = req.params;
  const query = 'SELECT * FROM JadwalPemberianMakan WHERE id_kucing = ?';
  connection.query(query, [id_kucing], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Routes for ArtikelKucing (Cat Articles)
app.post('/artikel', [
  body('judul').isString().notEmpty(),
  body('konten').isString().notEmpty(),
  body('tanggal_publikasi').isDate(),
  body('penulis').isString().notEmpty(),
  body('foto_artikel').optional().isString(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { judul, konten, tanggal_publikasi, penulis, foto_artikel } = req.body;
  const query = 'INSERT INTO ArtikelKucing (judul, konten, tanggal_publikasi, penulis, foto_artikel) VALUES (?, ?, ?, ?, ?)';
  connection.execute(query, [judul, konten, tanggal_publikasi, penulis, foto_artikel], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id_artikel: results.insertId });
  });
});

// GET all articles
app.get('/artikel', (req, res) => {
  const query = 'SELECT * FROM ArtikelKucing';
  connection.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Routes for Diskusi (Discussion Topics)
app.post('/diskusi', [
  body('konten_topik').isString().notEmpty(),
  body('tanggal_post').isDate(),
  body('id_pengguna').isInt(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { konten_topik, tanggal_post, id_pengguna } = req.body;
  const query = 'INSERT INTO Diskusi (konten_topik, tanggal_post, id_pengguna) VALUES (?, ?, ?)';
  connection.execute(query, [konten_topik, tanggal_post, id_pengguna], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id_topik: results.insertId });
  });
});

// GET all discussion topics
app.get('/diskusi', (req, res) => {
  const query = 'SELECT * FROM Diskusi';
  connection.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Routes for Balasan (Replies)
app.post('/balasan', [
  body('id_topik').isInt(),
  body('id_parent_balasan').optional().isInt(),
  body('konten_balasan').isString().notEmpty(),
  body('tanggal_balasan').isDate(),
  body('id_pengguna').isInt(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id_topik, id_parent_balasan, konten_balasan, tanggal_balasan, id_pengguna } = req.body;
  const query = 'INSERT INTO Balasan (id_topik, id_parent_balasan, konten_balasan, tanggal_balasan, id_pengguna) VALUES (?, ?, ?, ?, ?)';
  connection.execute(query, [id_topik, id_parent_balasan, konten_balasan, tanggal_balasan, id_pengguna], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id_balasan: results.insertId });
  });
});

// GET replies for a specific discussion topic
app.get('/balasan/:id_topik', (req, res) => {
  const { id_topik } = req.params;
  const query = 'SELECT * FROM Balasan WHERE id_topik = ?';
  connection.query(query, [id_topik], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Routes for RiwayatPemberianMakan (Feeding History)
app.post('/riwayat-pemberian', [
  body('id_kucing').isInt(),
  body('tanggal_pemberian').isDate(),
  body('jumlah_pemberian').isInt(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id_kucing, tanggal_pemberian, jumlah_pemberian } = req.body;
  const query = 'INSERT INTO RiwayatPemberianMakan (id_kucing, tanggal_pemberian, jumlah_pemberian) VALUES (?, ?, ?)';
  connection.execute(query, [id_kucing, tanggal_pemberian, jumlah_pemberian], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id_riwayat: results.insertId });
  });
});

// GET feeding history for a specific cat
app.get('/riwayat-pemberian/:id_kucing', (req, res) => {
  const { id_kucing } = req.params;
  const query = 'SELECT * FROM RiwayatPemberianMakan WHERE id_kucing = ?';
  connection.query(query, [id_kucing], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Routes for KucingDiadopsi (Adopted Cats)
app.post('/kucing-diadopsi', [
  body('id_kucing').isInt(),
  body('tanggal_adopsi').isDate(),
  body('nama_adopter').isString().notEmpty(),
  body('id_pengguna').isInt(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id_kucing, tanggal_adopsi, nama_adopter, id_pengguna } = req.body;
  const query = 'INSERT INTO KucingDiadopsi (id_kucing, tanggal_adopsi, nama_adopter, id_pengguna) VALUES (?, ?, ?, ?)';
  connection.execute(query, [id_kucing, tanggal_adopsi, nama_adopter, id_pengguna], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id_kucing_diadopsi: results.insertId });
  });
});

// GET all adopted cats
app.get('/kucing-diadopsi', (req, res) => {
  const query = 'SELECT * FROM KucingDiadopsi';
  connection.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results);
  });
});

// Centralized error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack); // Log error details for debugging
  res.status(500).json({ message: 'Something went wrong!' });
});

// Start the server
app.listen(port, () => {
  console.log(`Backend berjalan di http://localhost:${port}`);
});