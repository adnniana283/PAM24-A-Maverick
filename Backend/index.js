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
  database: "perpusgue",
});

app.get("/listBuku", (req, res) => {
  const sql = "SELECT * FROM books";
  connection.query(sql, (err, result) => {
    if (err) {
      return res.status(500).json({ message: "Database sedang offline" });
    }
    return res.status(200).json(result);
  });
});

app.post("/tambahBuku", (req, res) => {
  const { title, author, year, pages } = req.body;
  const sql = "INSERT INTO books (title, author, year, pages) VALUES (?,?,?,?)";
  connection.query(sql, [title, author, year, pages], (err, result) => {
    if (err) {
      return res.status(500).json({ message: "Database sedang offline" });
    }
    return res.status(200).json({ message: "Buku berhasil ditambahkan" });
  });
});

app.get("/cariBuku", (req, res) => {
  const { author, title } = req.body; // Changed to read from req.body

  let sql = "SELECT title, author, year, pages FROM books WHERE 1=1";
  const params = [];

  if (author) {
    sql += " AND author LIKE ?";
    params.push(`%${author}%`);
  }
  if (title) {
    sql += " AND title LIKE ?";
    params.push(`%${title}%`);
  }

  // Execute the query
  connection.query(sql, params, (err, result) => {
    if (err) {
      return res.status(500).json({ message: "Database sedang offline" });
    }
    return res.status(200).json(result);
  });
});

app.listen(port, () => {
  console.log(`Backend berjalan di http://localhost:${port}`);
});
