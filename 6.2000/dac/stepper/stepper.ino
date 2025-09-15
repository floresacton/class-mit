// 6.200 DAC LAB: STEPPER

// NOTE: tweak this to adjust resolution (feel free to add more bits!)
// use pins 14, 15, ..., 13+DAC_RESOLUTION
// highest pin is LSB.
const uint8_t DAC_RESOLUTION = 6;
// set up some initial variables based on the DAC resolution
const int HIGHEST_VAL = pow(2, DAC_RESOLUTION)-1;
uint8_t PINS[DAC_RESOLUTION] = {0};

const int step_time = 10;  // (milliseconds)
bool output_bits[DAC_RESOLUTION] = {0};
void setPins(int num){
    // loop over the number, store the bits in an array
    // (this preprocessing is so that we can hopefully set the pins faster)
    for (int i=0; i<DAC_RESOLUTION; i++){
        output_bits[i] = ((int)(1<<i) & num) != 0;
    }
    for (int i=0; i<DAC_RESOLUTION; i++){
        digitalWriteFast(PINS[i], output_bits[i]);
    }
}

// this function runs once (at startup time)
void setup() {
  Serial.begin(115200);
  // determine pin numbers and let arduino know we're using them as output
  for (int i=0; i < DAC_RESOLUTION; i++){
    PINS[i] = 13+DAC_RESOLUTION-i;
    pinMode(PINS[i], OUTPUT);
  }
}

void loop() {
    int current = (millis() / step_time) % HIGHEST_VAL;
    Serial.println(current);
    setPins(current);
    delay(10);
}
