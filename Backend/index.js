const express = require("express");
const mysql = require("mysql2");
const port = 3000;

const app = express();
app.use(express.json());

// Connect to MySQL database
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "PawFeeder",
});

// Tambah akun pengguna
app.post("/tambahAkun", (req, res) => {
  const { username, email, password_hash, nama_lengkap, tanggal_bergabung } = req.body;
  const sql = "INSERT INTO Pengguna (username, email, password_hash, nama_lengkap, tanggal_bergabung) VALUES (?, ?, ?, ?, ?)";
  connection.query(sql, [username, email, password_hash, nama_lengkap, tanggal_bergabung], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    res.status(200).json({ message: "Akun berhasil ditambahkan" });
  });
});

app.get("/pengguna", (req, res) => {
    const sql = "SELECT * FROM Pengguna"; // Mengambil semua pengguna
    connection.query(sql, (err, results) => {
      if (err) {
        return res.status(500).json({ message: "Gagal mengambil data pengguna" });
      }
      return res.status(200).json(results); // Mengembalikan data pengguna
    });
  });  

// Tambah kucing pengguna
app.post("/tambahKucing", (req, res) => {
  const { id_pengguna, nama, usia, berat, kebutuhan_kalori, id_sensor } = req.body;
  const sql = "INSERT INTO KucingPengguna (id_pengguna, nama, usia, berat, kebutuhan_kalori, id_sensor) VALUES (?, ?, ?, ?, ?, ?)";
  connection.query(sql, [id_pengguna, nama, usia, berat, kebutuhan_kalori, id_sensor], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    res.status(200).json({ message: "Kucing pengguna berhasil ditambahkan" });
  });
});

app.get("/kucing/:id", (req, res) => {
    const id_kucing = req.params.id; // Mengambil id_kucing dari parameter URL
    const sql = "SELECT * FROM KucingPengguna WHERE id_kucing = ?"; // Mengambil data kucing tertentu
    connection.query(sql, [id_kucing], (err, results) => {
      if (err) {
        return res.status(500).json({ message: "Gagal mengambil data kucing" });
      }
      if (results.length === 0) {
        return res.status(404).json({ message: "Kucing tidak ditemukan" });
      }
      return res.status(200).json(results[0]); // Mengembalikan data kucing
    });
  });
  

// Tambah artikel kucing
app.post("/tambahArtikel", (req, res) => {
  const { judul, konten, tanggal_publikasi, penulis, foto_artikel } = req.body;
  const sql = "INSERT INTO ArtikelKucing (judul, konten, tanggal_publikasi, penulis, foto_artikel) VALUES (?, ?, ?, ?, ?)";
  connection.query(sql, [judul, konten, tanggal_publikasi, penulis, foto_artikel], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    res.status(200).json({ message: "Artikel kucing berhasil ditambahkan" });
  });
});

// Tambah topik diskusi
app.post("/tambahTopikDiskusi", (req, res) => {
  const { judul_topik, konten_topik, tanggal_post, id_pengguna } = req.body;
  const sql = "INSERT INTO Diskusi (judul_topik, konten_topik, tanggal_post, id_pengguna) VALUES (?, ?, ?, ?)";
  connection.query(sql, [judul_topik, konten_topik, tanggal_post, id_pengguna], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    res.status(200).json({ message: "Topik diskusi berhasil ditambahkan" });
  });
});

// Tambah balasan diskusi
app.post("/tambahBalasan", (req, res) => {
  const { id_topik, konten_balasan, tanggal_balasan, id_pengguna } = req.body;
  const sql = "INSERT INTO Balasan (id_topik, konten_balasan, tanggal_balasan, id_pengguna) VALUES (?, ?, ?, ?)";
  connection.query(sql, [id_topik, konten_balasan, tanggal_balasan, id_pengguna], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    res.status(200).json({ message: "Balasan berhasil ditambahkan" });
  });
});

// Tambah riwayat pemberian makan
app.post("/tambahRiwayatPemberianMakan", (req, res) => {
  const { id_kucing, waktu_makan } = req.body;
  const sql = "INSERT INTO RiwayatPemberianMakan (id_kucing, waktu_makan) VALUES (?, ?)";
  connection.query(sql, [id_kucing, waktu_makan], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    res.status(200).json({ message: "Riwayat pemberian makan berhasil ditambahkan" });
  });
});

app.get("/riwayat/:id_kucing", (req, res) => {
    const id_kucing = req.params.id_kucing; // Mengambil id_kucing dari parameter URL
    const sql = "SELECT * FROM RiwayatPemberianMakan WHERE id_kucing = ?"; // Mengambil riwayat untuk kucing tertentu
    connection.query(sql, [id_kucing], (err, results) => {
      if (err) {
        return res.status(500).json({ message: "Gagal mengambil riwayat pemberian makan" });
      }
      return res.status(200).json(results); // Mengembalikan riwayat
    });
  });

// Tambah kucing untuk adopsi
app.post("/tambahKucingAdopsi", (req, res) => {
  const { nama, usia, kesehatan, lokasi_penampungan, deskripsi, kontak_penampungan, status_adopsi, foto_kucing } = req.body;
  const sql = "INSERT INTO KucingAdopsi (nama, usia, kesehatan, lokasi_penampungan, deskripsi, kontak_penampungan, status_adopsi, foto_kucing) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
  connection.query(sql, [nama, usia, kesehatan, lokasi_penampungan, deskripsi, kontak_penampungan, status_adopsi, foto_kucing], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    res.status(200).json({ message: "Kucing untuk adopsi berhasil ditambahkan" });
  });
});

app.listen(port, () => {
  console.log(`Backend berjalan di http://localhost:${port}`);
});
