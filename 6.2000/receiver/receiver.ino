// little ascii decoder for 6.200 optical communication lab

// BEGIN parameters (feel free to change these if what you're seeing on the scope )
const float VOLTAGE_THRESHOLD = 1.6;  // volts
const int BIT_PERIOD = 100000;
const int DEBOUNCE_TIME = 10000;
// END parameters


void setup() {
  // put your setup code here, to run once:
  pinMode(A0, INPUT);
  pinMode(13, OUTPUT);
  Serial.begin(115200);
}



// additional parameters computed from the other ones
const int BIN_THRESHOLD = (int)(VOLTAGE_THRESHOLD / 3.3 * 1024);
const int ZERO_LENGTH = BIT_PERIOD / 4;
const int ONE_LENGTH = 3 * BIT_PERIOD / 4;

unsigned char get_char(bool inp[7]){
  unsigned char out = 0;
  for (int i=0; i<7; i++){
    if(inp[i]){
      out |= 1 << (6-i);
    }
  }
  return out;
}

bool currentInput[7] = {0};
int currentBit = 0;
int debounceTime = 0;
int startTime = 0;
int stopTime = 0;
bool lastState = 0;
bool realState = 0;
bool awaitingSignal = 1;

void loop() {
  int current = analogRead(A0);
  //Serial.println(current);
  bool state =  current > BIN_THRESHOLD;
  //Serial.println(state);
  digitalWrite(13, state); // set the Teensy's LED on/off

  int currentTime = micros();

  if (state != lastState){
    debounceTime = currentTime;
  }
  lastState = state;

  if (currentTime - debounceTime > DEBOUNCE_TIME){
    // after accounting for debounce, store some info
    realState = state;
    if (realState){
      startTime = debounceTime;
      awaitingSignal = 0;
    }else{
      stopTime = debounceTime;
    }
  }

  if (!realState){
    // signal currently off, so time to see whether what we just got
    // was a 1 or a 0.
    int pauseLength = currentTime - stopTime;
    if (pauseLength > ZERO_LENGTH / 2 && !awaitingSignal){
      int signalLength = stopTime - startTime;
      currentInput[currentBit] = signalLength < ONE_LENGTH / 2;
      if (currentBit == 6){
        Serial.print((char)get_char(currentInput));
        currentBit = 0;
      }else{
        currentBit++;
      }
      awaitingSignal = 1;
    }

    if (pauseLength > 3 * ONE_LENGTH){
      // if pause longer than a few ones, reset the buffer
      currentBit = 0;
    }

  }

}
