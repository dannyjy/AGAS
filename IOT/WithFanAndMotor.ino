#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <Servo.h>

// --- CONFIGURATION ---
const char* ssid = "JD";
const char* password = "J DANNY1230";
const char* serverUrl = "https://backend-agas.vercel.app/api/gas-data";

// --- PINS ---
const int gasSensorPin = A0;
const int buzzerPin = D1;
const int redLedPin = D2;  
const int greenLedPin = D3; 
const int yellowLedPin = D4;
const int relayPin = D5;      // Relay for Fan
const int servoPin = D7;      // Servo Motor

// --- TIMING & STATE ---
unsigned long alertStartTime = 0;
bool gasDetected = false;
Servo exhaustServo;           

void setup() {
  Serial.begin(9600);

  // Pin modes
  pinMode(buzzerPin, OUTPUT);
  pinMode(redLedPin, OUTPUT);
  pinMode(greenLedPin, OUTPUT);
  pinMode(yellowLedPin, OUTPUT);
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW);  // Fan OFF initially

  // Servo
  exhaustServo.attach(servoPin);
  exhaustServo.write(0);         // Start closed

  // Connect WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");
}

void loop() {
  int gasValue = analogRead(gasSensorPin);
  Serial.printf("Gas Level: %d\n", gasValue);

  // Convert analog gas value to a CO2 estimate (example)
  float co2Value = gasValue * 1.2;    
  float gasLevel = gasValue;

  // Detect gas threshold
  if (gasValue > 100) {
    if (!gasDetected) {
      alertStartTime = millis();
      gasDetected = true;
    }

    digitalWrite(greenLedPin, LOW);
    unsigned long duration = millis() - alertStartTime;

    if (duration < 2000) {
      // PHASE 1: WARNING
      digitalWrite(yellowLedPin, HIGH);
      digitalWrite(redLedPin, LOW);
      digitalWrite(relayPin, HIGH);  // Fan OFF
      exhaustServo.write(0);         // Servo CLOSED
      noTone(buzzerPin);

      // Send WARNING data every 2 sec
      static unsigned long lastWarningSend = 0;
      if (millis() - lastWarningSend > 2000) {
        sendData(co2Value, gasLevel);
        lastWarningSend = millis();
      }
    } 
    else {
      // PHASE 2: DANGER
      digitalWrite(yellowLedPin, LOW);
      digitalWrite(redLedPin, HIGH);
      digitalWrite(relayPin, LOW);   // Fan ON
      exhaustServo.write(180);       // Servo OPEN
      tone(buzzerPin, 1000);

      // Send DANGER data every 2 sec
      static unsigned long lastDangerSend = 0;
      if (millis() - lastDangerSend > 2000) {
        sendData(co2Value, gasLevel);
        lastDangerSend = millis();
      }
    }
  } 
  else {
    // SAFE STATE
    gasDetected = false;
    digitalWrite(redLedPin, LOW);
    digitalWrite(yellowLedPin, LOW);
    digitalWrite(relayPin, HIGH);  // Fan OFF
    exhaustServo.write(0);         // Servo CLOSED
    noTone(buzzerPin);

    // Green LED blinking
    if ((millis() / 500) % 2 == 0)
      digitalWrite(greenLedPin, HIGH);
    else
      digitalWrite(greenLedPin, LOW);

    // Send SAFE heartbeat every 10 sec
    static unsigned long lastHeartbeat = 0;
    if (millis() - lastHeartbeat > 10000) {
      sendData(co2Value, gasLevel);
      lastHeartbeat = millis();
    }
  }
  delay(100);
}

// --- Send sensor data to backend ---
void sendData(float co2Value, float gasLevelValue) {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client;
  client.setInsecure();    // Only for testing
  HTTPClient http;

  if (http.begin(client, serverUrl)) {
    http.addHeader("Content-Type", "application/json");

    // JSON payload matching backend schema
    String payload = "{";
    payload += "\"sensorId\":\"SENSOR-001\",";
    payload += "\"co2\":" + String(co2Value, 2) + ",";
    payload += "\"gas_level\":" + String(gasLevelValue, 2);
    payload += "}";

    int code = http.POST(payload);
    if (code > 0) {
      Serial.printf("Data sent! HTTP code: %d\n", code);
      Serial.println("Response: " + http.getString());
    } 
    else {
      Serial.printf("Error sending data: %s\n", http.errorToString(code).c_str());
    }
    http.end();
  }
}