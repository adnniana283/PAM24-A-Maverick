#include <Wire.h>
#include <RTClib.h>
#include <ESP32Servo.h>
#include <NewPing.h>

#define TRIGGER_PIN  12   // Pin Trigger untuk sensor ultrasonik
#define ECHO_PIN     13   // Pin Echo untuk sensor ultrasonik
#define MAX_DISTANCE 200  // Jarak maksimum (dalam cm) yang akan diukur oleh sensor ultrasonik
#define SERVO_PIN    14   // Pin servo pada ESP32
#define OPEN_HOUR    21    // Jam buka pintu (atur sesuai kebutuhan)
#define OPEN_MINUTE  29    // Menit buka pintu (atur sesuai kebutuhan)

NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
RTC_DS3231 rtc;
Servo myServo;

bool isOpen = false;  // Status pintu

void setup() {
  Serial.begin(115200);

  // Inisialisasi RTC
  if (!rtc.begin()) {
    Serial.println("RTC tidak terdeteksi!");
    while (1);
  }
  
  if (rtc.lostPower()) {
    Serial.println("RTC kehilangan daya, atur waktu!");
    // Atur waktu ke waktu kompilasi
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }

  myServo.attach(SERVO_PIN); // Pasang servo pada pin yang ditentukan
  myServo.write(0);           // Posisi awal servo (tertutup)
}

void loop() {
  delay(50);  // Delay untuk stabilitas pembacaan sensor
  unsigned int distance = sonar.ping_cm();  // Mengambil jarak dalam cm
  
  // Tampilkan jarak ke Serial Monitor
  Serial.print("Jarak: ");
  Serial.print(distance);
  Serial.println(" cm");

  // Cek waktu saat ini
  DateTime now = rtc.now();

  // Buka pintu jika waktu saat ini sesuai jadwal
  if (now.hour() == OPEN_HOUR && now.minute() == OPEN_MINUTE && !isOpen) {
    bukaPintu();
    isOpen = true;
    delay(3000);       // Tunggu 3 detik
    tutupPintu();
  }

  // Buka pintu jika jarak dari sensor ultrasonik antara 0 hingga 15 cm
  if (distance > 0 && distance <= 15 && !isOpen) {
    bukaPintu();
    isOpen = true;
    delay(3000);       // Tunggu 3 detik
    tutupPintu();
  }

  // Reset status pintu setelah jadwal lewat
  if (now.minute() != OPEN_MINUTE && distance > 15) {
    isOpen = false;
  }
}

// Fungsi untuk membuka pintu
void bukaPintu() {
  Serial.println("Membuka pintu...");
  myServo.write(90); // Buka servo (posisi 90 derajat)
}

// Fungsi untuk menutup pintu
void tutupPintu() {
  Serial.println("Menutup pintu...");
  myServo.write(0); // Tutup servo (posisi 0 derajat)
}
