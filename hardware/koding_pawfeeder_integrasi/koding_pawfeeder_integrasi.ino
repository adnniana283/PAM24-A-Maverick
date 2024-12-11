#include <Wire.h>
#include <RTClib.h>
#include <ESP32Servo.h>
#include <NewPing.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

//#define TRIGGER_PIN_1  5
//#define ECHO_PIN_1     18
#define TRIGGER_PIN_2  5
#define ECHO_PIN_2     18
#define MAX_DISTANCE   200
#define SERVO_PIN      4
//#define JARAK_KUCING   10  // Jarak deteksi kucing (cm)
#define JARAK_PENUH    1   // Jarak deteksi makanan penuh (cm)

RTC_DS3231 rtc;
Servo feederServo;
//NewPing sonar1(TRIGGER_PIN_1, ECHO_PIN_1, MAX_DISTANCE);
NewPing sonar2(TRIGGER_PIN_2, ECHO_PIN_2, MAX_DISTANCE);

// WiFi credentials
const char* ssid = "niyak";
const char* password = "hapeniyaak";

// MQTT server credentials
const char* mqttServer = "broker.emqx.io";
const int mqttPort = 1883;
const char* mqttTopic = "feeder/jadwal";

bool feederAktif = false; // Status feeder (default mati)
const char* mqttStatusTopic = "feeder/status"; // Topic untuk mengatur status feeder
const char* mqttKapasitasTopic = "feeder/kapasitas"; // Topik MQTT untuk kapasitas makanan


WiFiClient espClient;
PubSubClient mqttClient(espClient);

int jumlahJadwal = 0;
int jadwalJam[5];   // Maksimal 5 jadwal makan
int jadwalMenit[5];
int kebutuhanKalori = 0;
int idKucing = 0;
int kaloriPerMakan = 0;
float kaloriPerCm = 32;  // Misalnya, 32 kalori per 1 cm (asumsi kapasitas petuh jika 600 kalori)

float hitungPersentaseKapasitas() {
  float jarakWadahKosong = 20.0;  // Jarak maksimum (kosong)
  float jarakWadahPenuh = 1.0;    // Jarak minimum (penuh)
  
  int jarakSaatIni = sonar2.ping_cm();  // Membaca jarak dari sensor
  
  if (jarakSaatIni <= jarakWadahPenuh) {
    return 100;  // Wadah penuh
  } else if (jarakSaatIni >= jarakWadahKosong) {
    return 0;    // Wadah kosong
  } else {
    // Hitung persentase kapasitas (dengan presisi)
    float kapasitas = ((jarakWadahKosong - jarakSaatIni) / 
                      (jarakWadahKosong - jarakWadahPenuh)) * 100.0;
    return round(kapasitas); // Bulatkan ke bilangan bulat
  }
}



// Menghitung jarak penuh berdasarkan kalori
float hitungJarakBerdasarkanKalori(int kalori) {
  float jarakTarget = 20 - (kalori / kaloriPerCm); // Jarak berkurang seiring bertambahnya makanan
  if (jarakTarget < 1) {
    return 1; // Batas minimal jarak
  }
  return jarakTarget;
}

void setup() {
  Serial.begin(115200);
  feederServo.attach(SERVO_PIN);

  if (!rtc.begin()) {
    Serial.println("RTC not found");
    while (1);
  }

  if (rtc.lostPower()) {
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }

  connectToWiFi();
  setupMQTT();

  // Subscribe untuk menerima jadwal makan dan status feeder via MQTT
  mqttClient.subscribe(mqttTopic);       // Topik untuk jadwal
  mqttClient.subscribe(mqttStatusTopic); // Topik untuk status feeder
 }

void loop() {
  if (!mqttClient.connected()) {
    reconnectMQTT();
  }
  mqttClient.loop();

  checkFeederStatus();

  checkScheduleAndFeed(); 

  // Kirim kapasitas makanan setiap 5 detik
  static unsigned long lastSendTime = 0;
  if (millis() - lastSendTime > 5000) {
    kirimKapasitasMakanan();
    lastSendTime = millis();
  }

  delay(1000); // Interval pengecekan
}

// Fungsi untuk menerima input integer dari pengguna melalui serial
//int getInputInt(String prompt) {
//  int value;
//  Serial.println(prompt);
//  while (Serial.available() == 0);  // Tunggu sampai data masuk
//  value = Serial.parseInt();        // Ambil input sebagai integer
//  return value;
//}

// Fungsi yang dipanggil saat pesan MQTT diterima
void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.print("Pesan diterima pada topik: ");
  Serial.println(topic);
  Serial.print("Isi pesan: ");
  Serial.println(message);

  // Handling for the feeder status topic
  if (String(topic) == mqttStatusTopic) {
    // Handle the feeder status (ON/OFF)
    handleFeederStatus(message);
  }

  // Handling for the feeding schedule topic
  else if (String(topic) == mqttTopic) {
    // Handle the feeding schedule
    handleFeedingSchedule(message);
  }
}

void handleFeederStatus(String message) {
  StaticJsonDocument<200> doc;  // Create a JSON document to store the parsed data
  DeserializationError error = deserializeJson(doc, message);  // Parse the JSON message

  if (error) {
    Serial.print("Gagal mengurai pesan JSON: ");
    Serial.println(error.c_str());
    return;
  }

  // Extract the "status" field from the parsed JSON
  String status = doc["status"];
  
  // Check the status and update feederAktif
  if (status == "ON") {
    feederAktif = true;
    Serial.println("Feeder diaktifkan melalui backend.");
  } else if (status == "OFF") {
    feederAktif = false;
    Serial.println("Feeder dimatikan melalui backend.");
  } else {
    Serial.println("Pesan status feeder tidak valid.");
  }
}

void kirimKapasitasMakanan() {
  float kapasitas = hitungPersentaseKapasitas();
  StaticJsonDocument<200> doc;
  doc["kapasitas"] = kapasitas; // Kapasitas dalam persen

  String output;
  serializeJson(doc, output);

  mqttClient.publish(mqttKapasitasTopic, output.c_str());
  Serial.print("Kapasitas makanan dikirim: ");
  Serial.println(output);
}

// Fungsi untuk menangani jadwal makan
void handleFeedingSchedule(String message) {
  StaticJsonDocument<500> doc;
  DeserializationError error = deserializeJson(doc, message);

  if (error) {
    Serial.print("Gagal mengurai pesan JSON: ");
    Serial.println(error.c_str());
    return;
  }

  // Debugging data yang diterima
  idKucing = doc["id_kucing"];
  kebutuhanKalori = doc["kebutuhan_kalori"];
  jumlahJadwal = doc["berapa_kali_makan"];
  JsonArray waktuMakanArray = doc["waktu_makan"];

  Serial.println("Data yang diterima:");
  Serial.print("id_kucing: ");
  Serial.println(idKucing);
  Serial.print("kebutuhan_kalori: ");
  Serial.println(kebutuhanKalori);
  Serial.print("jumlah_jadwal: ");
  Serial.println(jumlahJadwal);

  // Menghitung kalori per makan
  if (jumlahJadwal > 0) {
    kaloriPerMakan = kebutuhanKalori / jumlahJadwal;
    Serial.print("Kalori per makan: ");
    Serial.println(kaloriPerMakan);
  } else {
    Serial.println("Jumlah jadwal makan tidak valid!");
    return;
  }

  for (int i = 0; i < jumlahJadwal; i++) {
    JsonObject waktuMakanObj = waktuMakanArray[i];
    int jam = waktuMakanObj["jam"];
    int menit = waktuMakanObj["menit"];

    Serial.print("Waktu makan ke-");
    Serial.print(i + 1);
    Serial.print(": ");
    Serial.print(jam);
    Serial.print(":");
    Serial.println(menit);

    // Menyimpan data jadwal
    jadwalJam[i] = jam;
    jadwalMenit[i] = menit;

    Serial.print("Jadwal ke-");
    Serial.print(i + 1);
    Serial.print(": ");
    Serial.print(jam);
    Serial.print(":");
    Serial.println(menit);
  }

  Serial.println("Jadwal makan berhasil diperbarui.");
}
      

// Fungsi untuk menangani input manual melalui serial
//void handleManualInput() {
 // String input = Serial.readStringUntil('\n');
 // if (input.startsWith("set_jadwal")) {
    // Format input manual: set_jadwal 1 2 7 30 500
    // Dimana: 1 = ID Kucing, 2 = Jumlah Jadwal, 7 = Jam, 30 = Menit, 500 = Kebutuhan Kalori
 //   int tempIdKucing, tempJumlahJadwal, tempKebutuhanKalori;
 //   sscanf(input.c_str(), "set_jadwal %d %d %d %d %d", &tempIdKucing, &tempJumlahJadwal, &tempKebutuhanKalori);

 //   idKucing = tempIdKucing;
 //   jumlahJadwal = tempJumlahJadwal;
 //   kebutuhanKalori = tempKebutuhanKalori; // Set kebutuhan kalori dari input manual

  //  for (int i = 0; i < jumlahJadwal; i++) {
  //    int jam, menit;
  //    jam = getInputInt("Masukkan jam jadwal makan ke-" + String(i + 1) + " (0-23): ");
  //    menit = getInputInt("Masukkan menit jadwal makan ke-" + String(i + 1) + " (0-59): ");
  //    jadwalJam[i] = jam;
  //    jadwalMenit[i] = menit;
  //  }

  //  Serial.println("Jadwal makan berhasil diatur!");

    // Kirim jadwal makan ke backend melalui MQTT
  //  publishFeedingSchedule();
 // }
//}

// Fungsi untuk mengirim jadwal makan ke backend melalui MQTT
//void publishFeedingSchedule() {
//  StaticJsonDocument<500> doc;
//  doc["id_kucing"] = idKucing;
//  doc["kebutuhan_kalori"] = kebutuhanKalori;
//  doc["berapa_kali_makan"] = jumlahJadwal;

//  JsonArray waktuMakanArray = doc.createNestedArray("waktu_makan");
  
//  for (int i = 0; i < jumlahJadwal; i++) {
//    JsonObject waktuMakan = waktuMakanArray.createNestedObject();
//    waktuMakan["jam"] = jadwalJam[i];
//    waktuMakan["menit"] = jadwalMenit[i];
//  }

//  String output;
//  serializeJson(doc, output);
  
//  mqttClient.publish(mqttTopic, output.c_str());
//  Serial.println("Jadwal makan dikirim ke backend:");
//  Serial.println(output);
//}

//Skema 1: pengisian manual
void checkFeederStatus() {  
  if (feederAktif) {
    Serial.println("Feeder aktif. Memulai pengisian makanan...");
    feederServo.write(90); // Membuka pintu untuk mengisi makanan
    delay(1000);  // Tunggu agar servo bergerak dengan lancar
  }
  else {
    Serial.println("Feeder dimatikan. Menutup pintu...");
    feederServo.write(0); // Menutup pintu
    delay(1000);  // Tunggu agar servo bergerak dengan lancar
  }
}



// Skema 2: Cek jadwal makan
void checkScheduleAndFeed() {
  DateTime now = rtc.now();
  Serial.print("Waktu saat ini: ");
  Serial.print(now.hour());
  Serial.print(":");
  Serial.println(now.minute());

  for (int i = 0; i < jumlahJadwal; i++) {
    if (now.hour() == jadwalJam[i] && now.minute() == jadwalMenit[i]) {
      Serial.println("Jadwal Tercapai, Membuka Pintu...");
      feederServo.write(90); // Buka pintu
      delay(1000);

      if (kaloriPerMakan > 0) {
        // Menghitung jarak berdasarkan kalori yang diset
        float jarakPenuh = hitungJarakBerdasarkanKalori(kaloriPerMakan);
        while (sonar2.ping_cm() > jarakPenuh) {
          // Distribusi makanan hingga penuh sesuai kalori
          Serial.println("Mengisi makanan...");
          delay(500);
        }
      } else {
        while (sonar2.ping_cm() > JARAK_PENUH) {
          // Distribusi makanan hingga penuh
          Serial.println("Mengisi makanan...");
          delay(500);
        }
      }

      Serial.println("Mangkuk penuh, Menutup pintu...");
      feederServo.write(0); // Tutup pintu
      delay(60000); // Hindari eksekusi ulang dalam 1 menit
    }
  }
}

// Skema 2: Deteksi kucing dengan sensor jarak
//void detectCatAndFeed() {
//  int jarakKucing = sonar1.ping_cm();
//  Serial.print("Jarak kucing: ");
//  Serial.println(jarakKucing);

//  if (jarakKucing > 0 && jarakKucing <= JARAK_KUCING) {
 //   Serial.println("Kucing terdeteksi, Membuka pintu...");
 //   feederServo.write(90); // Buka pintu
 //   delay(1000);

  //  while (sonar2.ping_cm() > JARAK_PENUH) {
  //    Serial.println("Mengisi makanan...");
  //    delay(500);
  //  }

  //  Serial.println("Mangkuk penuh, Menutup pintu...");
  //  feederServo.write(0); // Tutup pintu
  //  delay(5000); // Hindari eksekusi ulang dalam 1 menit
  //} else {
  //  Serial.println("Tidak ada kucing terdeteksi.");
 // }
//}

void connectToWiFi() {
  Serial.println("Mencoba menghubungkan ke WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("Terhubung ke WiFi!");
}

void setupMQTT() {
  mqttClient.setServer(mqttServer, mqttPort);
  mqttClient.setCallback(callback);
  while (!mqttClient.connected()) {
    Serial.print("Mencoba koneksi MQTT...");
    if (mqttClient.connect("FeederClient")) {
      Serial.println("Terhubung ke MQTT Broker!");
    } else {
      Serial.print("Gagal, mencoba lagi dalam 5 detik...");
      delay(5000);
    }
  }
}

void reconnectMQTT() {
  while (!mqttClient.connected()) {
    Serial.print("Mencoba koneksi MQTT...");
    if (mqttClient.connect("FeederClient")) {
      Serial.println("Terhubung ke MQTT Broker!");
      mqttClient.subscribe(mqttTopic);  // Subscribe kembali setelah terhubung
    } else {
      Serial.print("Gagal, mencoba lagi dalam 5 detik...");
      delay(5000);
    }
  }
}
