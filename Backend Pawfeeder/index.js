const express = require("express");
const mysql = require("mysql2");
const moment = require('moment');
const cors = require("cors");
const { body, validationResult } = require("express-validator");
const mqtt = require("mqtt"); // Import MQTT library
const multer = require('multer');
const path = require('path');

// Set up multer storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');  // Save uploaded images to 'uploads' directory
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));  // Create unique file name
  }
});

const upload = multer({ storage: storage });

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Database Connection
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "pawfeeder",
});

connection.connect((err) => {
  if (err) {
    console.error("Database connection failed: " + err.stack);
    return;
  }
  console.log("Connected to database as ID " + connection.threadId);
});

// Variabel untuk menyimpan data kapasitas terbaru
let kapasitasTerakhir = null;

// Setup MQTT Client
const mqttClient = mqtt.connect("mqtt://broker.emqx.io:1883");

mqttClient.on("connect", () => {
  console.log("MQTT Connected");

  // Subscribe ke topik 'feeder/jadwal'
  mqttClient.subscribe("feeder/jadwal", (err) => {
    if (err) {
      console.error("Failed to subscribe to topic: feeder/jadwal");
    } else {
      console.log("Subscribed to topic: feeder/jadwal");
    }
  });

  // Subscribe ke topik 'feeder/status'
  mqttClient.subscribe("feeder/status", (err) => {
    if (err) {
      console.error("Failed to subscribe to topic: feeder/status");
    } else {
      console.log("Subscribed to topic: feeder/status");
    }
  });

  // Subscribe ke topik 'feeder/kapasitas'
  mqttClient.subscribe("feeder/kapasitas", (err) => {
    if (err) {
      console.error("Failed to subscribe to topic: feeder/kapasitas");
    } else {
      console.log("Subscribed to topic: feeder/kapasitas");
    }
  });
});

// Ketika menerima pesan dari topik MQTT
mqttClient.on('message', (topic, message) => {
  try {
    const data = JSON.parse(message.toString());

    // Tangani data kapasitas
    if (topic === "feeder/kapasitas" && typeof data.kapasitas === 'number') {
      kapasitasTerakhir = data.kapasitas;
      console.log(`Kapasitas diperbarui: ${kapasitasTerakhir}%`);
    }

    // Anda bisa menambahkan logika untuk topik lainnya jika perlu
    if (topic === "feeder/status") {
      console.log("Status diterima: ", data);
    }
    
  } catch (err) {
    console.error('Gagal memproses pesan MQTT:', err);
  }
});

// Endpoint untuk memberikan data kapasitas ke frontend
app.get('/kapasitas', (req, res) => {
  if (kapasitasTerakhir === null) {
    return res.status(204).json({ message: 'Belum ada data kapasitas.' });
  }

  res.status(200).json({ kapasitas: kapasitasTerakhir });
});

// Mengambil data dari MQTT dan menyimpannya ke database
// mqttClient.on("message", (topic, message) => {
//   console.log(`Received message on topic ${topic}: ${message.toString()}`);

//   if (topic === "feeder/jadwal") {
//     try {
//       const data = JSON.parse(message.toString());
//       const { id_kucing, waktu_makan, berapa_kali_makan, kebutuhan_kalori } = data;

//       // Pastikan waktu_makan adalah array
//       if (!Array.isArray(waktu_makan)) {
//         throw new Error("Invalid data: waktu_makan should be an array");
//       }

//       // Hitung jumlah makanan per kali makan (dalam gram)
//       const foodPerFeeding = kebutuhan_kalori
//         ? kebutuhan_kalori / berapa_kali_makan
//         : 100; // Default 100 gram jika kebutuhan kalori tidak ada
//       const todayDate = moment().format("YYYY-MM-DD"); // Format tanggal

//       // Loop melalui waktu_makan dan simpan ke database
//       const insertPromises = waktu_makan.map(waktu => {
//         const query =
//           "INSERT INTO JadwalPemberianMakan (id_kucing, waktu_makan, berapa_kali_makan, kebutuhan_kalori) VALUES (?, ?, ?, ?)";
//         return new Promise((resolve, reject) => {
//           connection.execute(
//             query,
//             [id_kucing, waktu, berapa_kali_makan, foodPerFeeding],
//             (err, results) => {
//               if (err) return reject(err);

//               // Masukkan ke tabel RiwayatPemberianMakan
//               const riwayatQuery =
//                 "INSERT INTO RiwayatPemberianMakan (id_kucing, waktu_makan, jumlah_pemberian) VALUES (?, ?, ?)";
//               const riwayatWaktuMakan = `${todayDate} ${waktu}`; // Gabungkan tanggal dengan waktu makan

//               connection.execute(
//                 riwayatQuery,
//                 [id_kucing, riwayatWaktuMakan, foodPerFeeding],
//                 (err, riwayatResults) => {
//                   if (err) return reject(err);
//                   console.log(
//                     `For cat ID ${id_kucing}, at time ${riwayatWaktuMakan}, dispense ${foodPerFeeding} grams of food.`
//                   );
//                   resolve({
//                     id_detail: results.insertId,
//                     id_riwayat: riwayatResults.insertId,
//                     waktu_makan: riwayatWaktuMakan,
//                     foodPerFeeding,
//                   });
//                 }
//               );
//             }
//           );
//         });
//       });

//       // Tunggu semua data tersimpan
//       Promise.all(insertPromises)
//         .then(results => {
//           console.log("Schedules and history inserted successfully");
//         })
//         .catch(err => {
//           console.error("Error inserting schedules or history: ", err);
//         });
//     } catch (error) {
//       console.error("Error parsing message: " + error.message);
//     }
//   }
// });


/** PENGGUNA **/
app.get("/pengguna", (req, res) => {
    const query = "SELECT * FROM Pengguna";
    connection.query(query, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json(results);
    });
  });
  
  app.post('/pengguna', (req, res) => {
    const { username, email, password_hash, nama_lengkap } = req.body;
  
    // Check if this is a login request (only email and password are provided)
    if (email && password_hash && !username && !nama_lengkap) {
      const query = 'SELECT * FROM Pengguna WHERE email = ? AND password_hash = ?';
      connection.query(query, [email, password_hash], (err, results) => {
        if (err) {
          return res.status(500).json({ message: 'Database error.', error: err });
        }
  
        if (results.length === 0) {
          return res.status(401).json({ message: 'Invalid email or password.' });
        }
  
        // Login successful
        const user = results[0];
        return res.status(200).json({
          id: user.id_pengguna,
          name: user.nama_lengkap,
          email: user.email,
        });
      });
      return;
    }
  
    // If username and nama_lengkap are provided, it's a sign-up request
    if (username && email && password_hash && nama_lengkap) {
      const query =
        'INSERT INTO Pengguna (username, email, password_hash, nama_lengkap) VALUES (?, ?, ?, ?)';
      connection.query(
        query,
        [username, email, password_hash, nama_lengkap],
        (err, results) => {
          if (err) {
            return res.status(500).json({ error: err.message });
          }
          res
            .status(201)
            .json({ message: 'Pengguna added successfully', id_pengguna: results.insertId });
        }
      );
    } else {
      res.status(400).json({ message: 'Invalid request payload.' });
    }
  });
  
  
  app.post('/kucing',  upload.single('foto_kucing'), [

    body("nama").isString(),
    body("jenis").isString(),
    body("tipe_kucing").isIn(["pengguna", "adopsi"]),
    body("usia").isInt(),
    body("berat").isFloat(),
    body("id_sensor").optional().isInt(),
    body("gender").isIn(["jantan", "betina"]),
    body("tipe_kucing").custom((value, { req }) => {
      if (value === 'pengguna') {
        return true;
      } else if (value === 'adopsi') {
        if (!req.body.kesehatan) {
          throw new Error("Kesehatan harus diisi untuk kucing adopsi");
        }
        if (!req.body.lokasi_penampungan) {
          throw new Error("Lokasi penampungan harus diisi untuk kucing adopsi");
        }
        if (!req.body.deskripsi) {
          throw new Error("Deskripsi harus diisi untuk kucing adopsi");
        }
        if (!req.body.kontak_penampungan) {
          throw new Error("Kontak penampungan harus diisi untuk kucing adopsi");
        }
        return true;
      }
      return true;
    }),
    body("kesehatan").optional().isString(),
    body("lokasi_penampungan").optional().isString(),
    body("deskripsi").optional().isString(),
    body("kontak_penampungan").optional().isString(),
    body("status_adopsi").optional().isBoolean(),
    body("foto_kucing").optional().isString(),
    body("id_pengguna").isInt() // Ensure id_pengguna is provided and valid
  ], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
  
    const {
      nama,
      jenis,
      tipe_kucing,
      usia,
      berat,
      id_sensor,
      gender,
      kesehatan,
      lokasi_penampungan,
      deskripsi,
      kontak_penampungan,
      status_adopsi,
      foto_kucing,
      id_pengguna // Retrieve id_pengguna from the request
    } = req.body;
  
    const sensorId = id_sensor || null; // Replace undefined with null
    const health = tipe_kucing === 'adopsi' ? kesehatan || null : null;
    const location = tipe_kucing === 'adopsi' ? lokasi_penampungan || null : null;
    const description = tipe_kucing === 'adopsi' ? deskripsi || null : null;
    const contact = tipe_kucing === 'adopsi' ? kontak_penampungan || null : null;
    const status = tipe_kucing === 'adopsi' ? status_adopsi || null : null;
    // Handle missing or undefined fields
    const fotoKucingPath = foto_kucing ? foto_kucing : null; // Ensure null if not provided

    
    const query = `
      INSERT INTO Kucing (nama, jenis, tipe_kucing, usia, berat, id_sensor, gender, kesehatan, lokasi_penampungan, deskripsi, kontak_penampungan, status_adopsi, foto_kucing, id_pengguna)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
  
    connection.execute(query, [
      nama,
      jenis,
      tipe_kucing,
      usia,
      berat,
      sensorId,       // id_sensor or null
      gender,
      health,         // Will be null if not 'adopsi'
      location,       // Will be null if not 'adopsi'
      description,    // Will be null if not 'adopsi'
      contact,        // Will be null if not 'adopsi'
      status,
      fotoKucingPath,
      id_pengguna     // Provide the actual user ID here
    ], (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ message: 'Kucing berhasil ditambahkan', data: results });
    });
  });
  
  
  app.get("/jadwal-makan", (req, res) => {
    // Jika ingin menyaring berdasarkan ID kucing, kamu bisa menggunakan parameter `id_kucing`
    const idKucing = req.query.id_kucing;  // Ambil id_kucing dari query parameter
  
    let query = "SELECT * FROM JadwalPemberianMakan";
    if (idKucing) {
      query += " WHERE id_kucing = ?";
    }
  
    // Jalankan query
    connection.query(query, [idKucing], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
  
      // Jika data ditemukan, formatkan dengan struktur yang lebih jelas
      if (results.length > 0) {
        // Misalnya, jika kamu ingin data dalam format seperti berikut:
        // { "jadwal": [{ id_kucing: 1, waktu_makan: "07:00", berapa_kali_makan: 3, kebutuhan_kalori: 200 }, ...] }
  
        const formattedResults = results.map(item => ({
          id_kucing: item.id_kucing,
          waktu_makan: item.waktu_makan,
          berapa_kali_makan: item.berapa_kali_makan,
          kebutuhan_kalori: item.kebutuhan_kalori,
        }));
  
        res.status(200).json({ jadwal: formattedResults });
      } else {
        res.status(404).json({ message: "Jadwal tidak ditemukan" });
      }
    });
  });
  
  
  app.get("/riwayat-makan", (req, res) => {
    const query = "SELECT * FROM RiwayatPemberianMakan";
    connection.query(query, (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      // Pastikan results tidak kosong
      if (results.length === 0) {
        return res.status(404).json({ message: 'No data found' });
      }
      res.status(200).json(results);
    });
  });
  
  

  app.post('/jadwal-makan', [
    body('id_kucing').isInt(),
    body('waktu_makan').isArray(),
    body('berapa_kali_makan').isInt(),
    body('kebutuhan_kalori').optional().isInt(),
], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { id_kucing, waktu_makan, berapa_kali_makan, kebutuhan_kalori } = req.body;

    // Hitung jumlah makanan per pemberian (dalam gram)
    const foodPerFeeding = kebutuhan_kalori ? (kebutuhan_kalori / berapa_kali_makan) : 100; // Default 100 gram per pemberian jika kebutuhan kalori tidak ada

    // Mendapatkan tanggal hari ini
    const todayDate = moment().format('YYYY-MM-DD'); // Format tanggal: 'YYYY-MM-DD'

    // Masukkan jadwal makan ke dalam database (tabel JadwalPemberianMakan)
    const insertPromises = waktu_makan.map(waktu => {
        const query = 'INSERT INTO JadwalPemberianMakan (id_kucing, waktu_makan, berapa_kali_makan, kebutuhan_kalori) VALUES (?, ?, ?, ?)';
        return new Promise((resolve, reject) => {
            connection.execute(query, [id_kucing, waktu, berapa_kali_makan, foodPerFeeding], (err, results) => {
                if (err) return reject(err);

                // Setelah jadwal makan dimasukkan, insert ke RiwayatPemberianMakan dengan tanggal hari ini
                const riwayatQuery = 'INSERT INTO RiwayatPemberianMakan (id_kucing, waktu_makan, jumlah_pemberian) VALUES (?, ?, ?)';
                const riwayatWaktuMakan = `${todayDate} ${waktu}`; // Gabungkan tanggal hari ini dengan waktu makan untuk RiwayatPemberianMakan

                connection.execute(riwayatQuery, [id_kucing, riwayatWaktuMakan, foodPerFeeding], (err, riwayatResults) => {
                    if (err) return reject(err);
                    console.log(`For cat ID ${id_kucing}, at time ${riwayatWaktuMakan}, dispense ${foodPerFeeding} grams of food.`);
                    resolve({
                        id_detail: results.insertId,
                        id_riwayat: riwayatResults.insertId,
                        waktu_makan: riwayatWaktuMakan,
                        foodPerFeeding,
                    });
                });
            });
        });
    });

    // Kirim jadwal ke ESP32 melalui MQTT setelah semua data berhasil dimasukkan
    Promise.all(insertPromises)
        .then(results => {
            const feedingSchedule = {
                id_kucing,
                kebutuhan_kalori,
                berapa_kali_makan,
                waktu_makan: waktu_makan.map(waktu => {
                    const [jam, menit] = waktu.split(':');
                    return { jam: parseInt(jam), menit: parseInt(menit) }; // Kirim hanya jam dan menit
                }),
            };

            mqttClient.publish('feeder/jadwal', JSON.stringify(feedingSchedule), (err) => {
                if (err) {
                    console.error('Error sending schedule to ESP32:', err);
                    return res.status(500).json({ error: 'Failed to send schedule to feeder.' });
                }
                console.log('Schedule sent to ESP32:', feedingSchedule);
                res.status(200).json({ message: 'Jadwal berhasil ditambahkan.', details: results });
            });
        })
        .catch(err => {
            console.error('Error inserting schedules or history:', err);
            res.status(500).json({ error: 'Failed to add schedules or history.', details: err });
        });
});

  
// API untuk mengambil daftar artikel
app.get("/artikel", (req, res) => {
  const query = "SELECT * FROM ArtikelKucing ORDER BY tanggal_publikasi DESC"; // Mengurutkan berdasarkan tanggal terbaru
  connection.execute(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json(results); // Mengirim daftar artikel
  });
});
  
app.post("/artikel", upload.single('foto_artikel'), [
  body("judul").isString().notEmpty(),
  body("konten").isString().notEmpty(),
  body("tanggal_publikasi").isISO8601(),
  body("penulis").isString().notEmpty(),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { judul, konten, tanggal_publikasi, penulis } = req.body;
  const foto_artikel = req.file ? req.file.path : null; // Get file path

  const query = "INSERT INTO ArtikelKucing (judul, konten, tanggal_publikasi, penulis, foto_artikel) VALUES (?, ?, ?, ?, ?)";
  connection.execute(
    query,
    [judul, konten, tanggal_publikasi, penulis, foto_artikel],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(201).json({ id_artikel: results.insertId });
    }
  );
});
  
    // Mendapatkan list diskusi
  app.get("/diskusi", (req, res) => {
    const query = "SELECT * FROM Diskusi";
    connection.query(query, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json(results); // Mengembalikan data dalam format JSON
    });
  });

  // Menambahkan diskusi baru
  app.post("/diskusi", [
    body("konten_topik").isString().notEmpty(),
    body("waktu_post").isISO8601(),
    body("id_pengguna").isInt(),
  ], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { konten_topik, waktu_post, id_pengguna } = req.body;
    const query = "INSERT INTO Diskusi (konten_topik, waktu_post, id_pengguna) VALUES (?, ?, ?)";
    connection.query(query, [konten_topik, waktu_post, id_pengguna], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(201).json({ id_topik: results.insertId });  // Mengembalikan ID topik yang baru dibuat
    });
  });

  // Mendapatkan balasan untuk diskusi tertentu
  app.get("/balasan", (req, res) => {
    const query = "SELECT * FROM Balasan WHERE id_topik = ?";
    const { id_topik } = req.query;
    connection.query(query, [id_topik], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json(results); // Mengembalikan list balasan
    });
  });

  // Menambahkan balasan baru
  app.post('/balasan', [
    body('id_topik').isInt(), // Validasi id_topik
    // Perubahan di backend untuk validasi id_parent_balasan
    body('id_parent_balasan').optional().custom(value => {
      if (value !== null && !Number.isInteger(value)) {
        throw new Error('id_parent_balasan must be an integer or null');
      }
      return true;
    }),
    body('waktu_balasan').isISO8601().withMessage('Invalid ISO8601 format for waktu_balasan'),
    body('id_pengguna').isInt(), // Validasi id_pengguna
    
  ], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });  // Mengembalikan kesalahan jika validasi gagal
    }
  
    const { id_topik, id_parent_balasan, konten_balasan, waktu_balasan, id_pengguna } = req.body;
    
    // Query untuk memasukkan data balasan
        const query = 'INSERT INTO Balasan (id_topik, id_parent_balasan, konten_balasan, waktu_balasan, id_pengguna) VALUES (?, ?, ?, ?, ?)';
    connection.query(query, [id_topik, id_parent_balasan, konten_balasan, waktu_balasan, id_pengguna], (err, results) => {
      if (err) {
        console.error('Error inserting balasan: ', err);
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ id_balasan: results.insertId });
    });
  });
  


  // Endpoint untuk mengirimkan perintah ke feeder
  app.post('/status', (req, res) => {
    const status = req.body.status.toUpperCase(); // Mengambil status dari request body
    
    if (status === 'ON' || status === 'OFF') {
      // Mengirim status ke feeder melalui MQTT menggunakan mqttClient
      mqttClient.publish('feeder/status', JSON.stringify({ status: status }), (err) => {
        if (err) {
          console.error('Error publishing MQTT message:', err);
          return res.status(500).json({ error: 'Failed to send message to feeder' });
        }
        console.log(`Sent to ESP32: ${status}`);
        res.status(200).json({ message: `Perintah ${status} berhasil dikirim ke feeder.` });
      });
    } else {
      res.status(400).send('Perintah tidak valid, hanya "ON" atau "OFF" yang diterima.');
    }
  });

// Start the server
app.listen(port, () => {
  console.log(`Backend berjalan di http://localhost:${port}`);
});
