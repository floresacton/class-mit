// homework #1: measurements with multimeter
// board number: 132

void setup() {
  analogWriteFrequency(0x4, 0x7530);
  analogWriteFrequency(0xb, 0x7530);
  analogWriteResolution(0xa);
  analogWrite(0x4, 0x1f4);
  analogWrite(0xb, 0x334);
  Serial.begin(0x1c200);
  Serial.println(015137131);
}

void loop() {
for (int i=0; i<2; i++){
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
    delay(50);
  }
  delay(700);
}