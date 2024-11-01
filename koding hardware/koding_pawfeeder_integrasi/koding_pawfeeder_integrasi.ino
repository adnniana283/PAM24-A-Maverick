#include <Wire.h>
#include <RTClib.h>
#include <ESP32Servo.h>
#include <NewPing.h>

#define TRIGGER_PIN_1  5  // Trigger pin for ultrasonic sensor 1 (cat detection)
#define ECHO_PIN_1     18  // Echo pin for ultrasonic sensor 1

#define TRIGGER_PIN_2  19  // Trigger pin for ultrasonic sensor 2 (food level)
#define ECHO_PIN_2     21  // Echo pin for ultrasonic sensor 2

#define MAX_DISTANCE   200 // Maximum distance (cm) for ultrasonic sensors
#define SERVO_PIN      22  // Pin for servo motor

RTC_DS3231 rtc; // Create RTC object
Servo feederServo; // Create servo object

NewPing sonar1(TRIGGER_PIN_1, ECHO_PIN_1, MAX_DISTANCE); // Ultrasonic sensor 1
NewPing sonar2(TRIGGER_PIN_2, ECHO_PIN_2, MAX_DISTANCE); // Ultrasonic sensor 2

int feedingHour = 0;   // Hour of feeding time
int feedingMinute = 0; // Minute of feeding time
bool isFeedingScheduled = false;

int calorieInput = 0; // User input for calories
bool calorieInputSet = false;

// Caloric density (calories per gram)
const float caloricDensity = 3.5; // Adjust this based on the type of food

void setup() {
  Serial.begin(115200);
  feederServo.attach(SERVO_PIN); // Attach servo to pin

  // Initialize RTC
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }

  if (rtc.lostPower()) {
    // Set the date and time if the RTC is lost
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }

  Serial.println("Set feeding schedule: Enter hour (0-23) and minute (0-59) separated by a space.");
  Serial.println("Input calorie requirement (grams) followed by ENTER.");
}

void loop() {
  DateTime now = rtc.now();

  // Check if feeding time has been set
  if (isFeedingScheduled) {
    // Check if it's time to feed the cat
    if (now.hour() == feedingHour && now.minute() == feedingMinute) {
      openFeeder();
      isFeedingScheduled = false; // Reset feeding schedule after feeding
      Serial.println("Feeding complete. Schedule reset.");
    }
  }

  // Check for cat presence
  int distanceCat = sonar1.ping_cm();
  int distanceFood = sonar2.ping_cm();

  // Open the door if a cat is detected and food is empty
  if (distanceCat > 0 && distanceCat <= 10 && distanceFood > 20) { // Check food level (>20 cm means food is present)
    openFeeder();
  }

  // Close the feeder door based on calorie input or if the container is full
  if (calorieInputSet) {
    int requiredFoodHeight = convertCaloriesToHeight(calorieInput); // Convert calorie input to height
    if (distanceFood <= requiredFoodHeight) {
      closeFeeder();
      calorieInputSet = false; // Reset calorie input after closing
      Serial.println("Feeder closed based on calorie input.");
    }
  } else if (distanceFood <= 5) { // Assuming 5 cm is the full mark
    closeFeeder();
    Serial.println("Feeder closed because the container is full.");
  }

  // Handle user input
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    int spaceIndex = input.indexOf(' ');

    // If there's a space, assume it's hour and minute
    if (spaceIndex > 0) {
      feedingHour = input.substring(0, spaceIndex).toInt();
      feedingMinute = input.substring(spaceIndex + 1).toInt();
      isFeedingScheduled = true; // Set the schedule to active
      Serial.print("Feeding scheduled at ");
      Serial.print(feedingHour);
      Serial.print(":");
      Serial.println(feedingMinute);
    } 
    // If no space, assume it's calorie input
    else {
      calorieInput = input.toInt();
      calorieInputSet = true; // Set calorie input
      Serial.print("Calorie input set to: ");
      Serial.println(calorieInput);
    }
  }
}

void openFeeder() {
  Serial.println("Opening feeder...");
  feederServo.write(90); // Adjust angle as needed for opening
}

void closeFeeder() {
  Serial.println("Closing feeder...");
  feederServo.write(0); // Adjust angle as needed for closing
}

// Function to convert calories to height (in cm)
// Assuming caloric density is 3.5 calories per gram
int convertCaloriesToHeight(int calories) {
  // Convert calories to grams and then to height in cm
  float weightInGrams = calories / caloricDensity; // Convert calories to grams
  return static_cast<int>(weightInGrams); // Return height in cm
}
