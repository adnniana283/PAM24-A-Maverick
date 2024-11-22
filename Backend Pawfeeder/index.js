const express = require("express");
const mysql = require("mysql2");
const moment = require('moment');
const { body, validationResult } = require("express-validator");
const mqtt = require("mqtt"); // Import MQTT library

const app = express();
const port = 3000;

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

// MQTT Client setup
const mqttClient = mqtt.connect("mqtt://broker.emqx.io:1883");

// MQTT client connection event
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

  // Subscribe ke topik 'feeder/command'
  mqttClient.subscribe("feeder/status", (err) => {
    if (err) {
      console.error("Failed to subscribe to topic: feeder/status");
    } else {
      console.log("Subscribed to topic: feeder/status");
    }
  });
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
  
  app.post("/pengguna", [
    body("username").isString(),
    body("email").isEmail(),
    body("password_hash").isString(),
    body("nama_lengkap").isString(),
  ], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
  
    const { username, email, password_hash, nama_lengkap } = req.body;
    const query = 'INSERT INTO Pengguna (username, email, password_hash, nama_lengkap) VALUES (?, ?, ?, ?)';
    connection.execute(query, [username, email, password_hash, nama_lengkap], (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ message: 'Pengguna added successfully', id_pengguna: results.insertId });
    });
  });
  
  
  app.post('/kucing', [
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
  
    const health = tipe_kucing === 'adopsi' ? kesehatan : null;
    const location = tipe_kucing === 'adopsi' ? lokasi_penampungan : null;
    const description = tipe_kucing === 'adopsi' ? deskripsi : null;
    const contact = tipe_kucing === 'adopsi' ? kontak_penampungan : null;
    const status = tipe_kucing === 'adopsi' ? status_adopsi : null;
  
    const sensorId = id_sensor || null;
  
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
      foto_kucing,
      id_pengguna     // Provide the actual user ID here
    ], (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ message: 'Kucing berhasil ditambahkan', data: results });
    });
  });
  
  
  /** JADWAL PEMBERIAN MAKAN **/
  app.get("/jadwal-makan", (req, res) => {
    const query = "SELECT * FROM JadwalPemberianMakan";
    connection.query(query, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json(results);
    });
  });
  
  /** RIWAYAT PEMBERIAN MAKAN **/
  app.get("/riwayat-makan", (req, res) => {
    const query = "SELECT * FROM RiwayatPemberianMakan";
    connection.query(query, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
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

  
  /** ARTIKEL KUCING **/
  app.get("/artikel", (req, res) => {
    const query = "SELECT * FROM ArtikelKucing";
    connection.query(query, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json(results);
    });
  });
  
  app.post(
    "/artikel",
    [
      body("judul").isString().notEmpty(),
      body("konten").isString().notEmpty(),
      body("tanggal_publikasi").isISO8601(),
      body("penulis").isString().notEmpty(),
      body("foto_artikel").optional().isString(),
    ],
    (req, res) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const { judul, konten, tanggal_publikasi, penulis, foto_artikel } =
        req.body;
      const query =
        "INSERT INTO ArtikelKucing (judul, konten, tanggal_publikasi, penulis, foto_artikel) VALUES (?, ?, ?, ?, ?)";
      connection.execute(
        query,
        [judul, konten, tanggal_publikasi, penulis, foto_artikel],
        (err, results) => {
          if (err) return res.status(500).json({ error: err.message });
          res.status(201).json({ id_artikel: results.insertId });
        }
      );
    }
  );
  
  /** DISKUSI **/
  app.get("/diskusi", (req, res) => {
    const query = "SELECT * FROM Diskusi";
    connection.query(query, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json(results);
    });
  });
  
  app.post(
    "/diskusi",
    [
      body("konten_topik").isString().notEmpty(),
      body("waktu_post").isISO8601(),
      body("id_pengguna").isInt(),
    ],
    (req, res) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const { konten_topik, waktu_post, id_pengguna } = req.body;
      const query =
        "INSERT INTO Diskusi (konten_topik, waktu_post, id_pengguna) VALUES (?, ?, ?)";
      connection.execute(
        query,
        [konten_topik, waktu_post, id_pengguna],
        (err, results) => {
          if (err) return res.status(500).json({ error: err.message });
          res.status(201).json({ id_topik: results.insertId });
        }
      );
    }
  );
  
  /** BALASAN **/
  app.get("/balasan", (req, res) => {
    const query = "SELECT * FROM Balasan";
    connection.query(query, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json(results);
    });
  });
  
  app.post('/balasan', [
    body('id_topik').isInt(),
    body('id_parent_balasan').optional().custom(value => {
      if (value !== null && !Number.isInteger(value)) {
        throw new Error('id_parent_balasan must be an integer or null');
      }
      return true; // Indicate success
    }),
    body('konten_balasan').isString().notEmpty(),
    body('waktu_balasan').isDate(),
    body('id_pengguna').isInt(),
  ], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
  
    const { id_topik, id_parent_balasan, konten_balasan, waktu_balasan, id_pengguna } = req.body;
    const query = 'INSERT INTO balasan (id_topik, id_parent_balasan, konten_balasan, waktu_balasan, id_pengguna) VALUES (?, ?, ?, ?, ?)';
    connection.execute(query, [id_topik, id_parent_balasan, konten_balasan, waktu_balasan, id_pengguna], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
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
