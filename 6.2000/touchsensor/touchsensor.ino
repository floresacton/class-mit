// 6.200 Lab Code: Capacitive Touch Sensor


// TODO: replace tauThreshold with a threshold of your choosing if tau is
// estimated to be above this value (in microseconds), we will consider the
// touch sensor as being touched and light up an LED.  if tau is estimated to
// be below this value, we assume the sensor is not being touched.  must be an
// integer number of microseconds.
float tauThreshold = 3; // in microseconds


const int NUM_CHANNELS = 5;

void setup() {
  pinMode(11, OUTPUT);
  for (int i=0; i<=NUM_CHANNELS; i++){
    pinMode(2*i, OUTPUT);
    pinMode(18-i, INPUT);
  }
}

const float waveFreq = 100;  // frequency of the input square wave, in Hz
const unsigned int wavePeriodMicros = (unsigned int)(1.0/waveFreq * 1e6);
const unsigned int halfway = wavePeriodMicros/2;

bool laston = false;
bool on = false;

unsigned long riseStart;
unsigned long approxTau;

// we'll only measure one channel each time the square wave turns on, to
// try to get a more accurate measurement of tau.  this variable tracks which
// channel we're measuring.
int which = 0;

void loop() {
  unsigned long nowTime = micros();
  laston = on;
  on = (nowTime % wavePeriodMicros) < halfway;
  if (on && !laston){
    digitalWrite(11, HIGH);
    riseStart = nowTime;
    while (true){
      unsigned long newNow = micros();
      if (newNow - riseStart >= halfway){
         digitalWrite(2*which, true);
         break;
      }
      if (digitalRead(18-which)){
        approxTau = 1.44*(newNow - riseStart);
        digitalWrite(2*which, approxTau > tauThreshold);
        if (which == 0){
          Serial.println(approxTau);
        }
        break;
      }
    }
    which = (which + 1) % NUM_CHANNELS;
  }

   if (!on && laston){
    digitalWrite(11, LOW);
  }
}
