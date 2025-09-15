// 6.200 Homework
// RC Measurement

void setup() {
  pinMode(22, OUTPUT);
  Serial.begin(115200);
}

void readUntil(long unsigned int timeLimit, bool forceZero){
  int startTime = millis();
  while (millis() - startTime < timeLimit){
    Serial.print("UpperLimit:");
    Serial.print(3.3);
    Serial.print(",LowerLimit:");
    Serial.print(0);
    Serial.print(",Measured:");
    Serial.println(forceZero ? 0 : (analogRead(18)*3.3/1024));
    delay(1);
  }
}

void loop() {
  pinMode(18, OUTPUT);
  digitalWrite(18, LOW);
  readUntil(500, true);
  pinMode(18, INPUT);
  digitalWriteFast(22, HIGH);
  readUntil(50, false);
  digitalWriteFast(22, LOW);
  readUntil(50, false);
  digitalWriteFast(22, HIGH);
  readUntil(400, false);
  digitalWriteFast(22, LOW);
  while(true){
  }
}