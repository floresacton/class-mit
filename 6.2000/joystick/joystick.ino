const int numButtons = 16;
int buttonPins[numButtons] = {18, 20, 19, 21, 1, 22, 6, 13, 2, 5, 3, 4, 7, 8, 0, 23};
int buttonNums[numButtons] = {
    1, 2, 3, 4, // ABXY
    5, 6, // LB RB
    9, 10, // BACK START
    13, 14, 15, 16, // D-PAD UDLR
    11, 12, // LS RS
    7, 8, // LT RT
};


void setup() {
  for (int i=0; i<numButtons; i++) {
    pinMode(buttonPins[i], INPUT_PULLUP);
  }
  Joystick.useManualSend(true);
}

void loop() {
  // read analog inputs and set X-Y position
  Joystick.X(1023 - analogRead(1));
  Joystick.Y(analogRead(0));
  Joystick.Z(analogRead(3));
  Joystick.Zrotate(1023-analogRead(2));

  // read the digital inputs and set the buttons
  for (int i=0; i<numButtons; i++) {
    Joystick.button(buttonNums[i], !digitalRead(buttonPins[i]));
  }

  Joystick.send_now();

  // a brief delay, so this runs 200 times per second
  delay(5);
}
