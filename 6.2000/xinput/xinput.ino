#include <XInput.h>

/* 6.200 Gamepad */

const int numButtons = 16;
int buttonPins[numButtons] = {
  18,
  20,
  19,
  21,
  1,
  22,
  6,
  13,
  2,
  5,
  3,
  4,
  7,
  8,
  0,
  23
};
int buttonNames[numButtons] = {
  BUTTON_A,
  BUTTON_B,
  BUTTON_X,
  BUTTON_Y,
  BUTTON_LB,
  BUTTON_RB,
  BUTTON_BACK,
  BUTTON_START,
  DPAD_UP,
  DPAD_DOWN,
  DPAD_LEFT,
  DPAD_RIGHT,
  BUTTON_L3,
  BUTTON_R3,
  TRIGGER_LEFT,
  TRIGGER_RIGHT
};

void setup() {
  for (int i = 0; i < numButtons; i++) {
    pinMode(buttonPins[i], INPUT_PULLUP);
  }
  XInput.setAutoSend(false);
  XInput.setRange(JOY_LEFT, 0, 1023);
  XInput.setRange(JOY_RIGHT, 0, 1023);
  XInput.begin();
}

void loop() {
  // read 6 analog inputs and use them for the joystick axis
  XInput.setJoystick(JOY_LEFT, 1023 - analogRead(1), analogRead(0));
  XInput.setJoystick(JOY_RIGHT, analogRead(3), 1023 - analogRead(2));

  for (int i = 0; i < numButtons; i++) {
    XInput.setButton(buttonNames[i], !digitalRead(buttonPins[i]));
  }

  XInput.send();

  // a brief delay, so this runs "only" 200 times per second
  delay(5);
}
