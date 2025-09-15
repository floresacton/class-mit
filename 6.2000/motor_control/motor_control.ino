// 6.200 MOTOR CONTROL LAB

// NOTE: tweak this to adjust resolution (feel free to add more bits!)
// use pins 14, 15, ..., 13+DAC_RESOLUTION
// highest pin is LSB.
const uint8_t DAC_RESOLUTION = 6;


// set up some initial variables based on the DAC resolution and whatnot
const float tau = 6.28318;
const int HIGHEST_VAL = pow(2, DAC_RESOLUTION)-1;
uint8_t PINS[DAC_RESOLUTION] = {0};
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
  // determine pin numbers and let arduino know we're using them as output
  for (int i=0; i < DAC_RESOLUTION; i++){
    PINS[i] = 13+DAC_RESOLUTION-i;
    pinMode(PINS[i], OUTPUT);
  }
}

const unsigned long microperiod = 5000000;

void loop() {
    float t = micros() % microperiod;

    int val;
    if (t <= (microperiod/2)){
      val = floor(t / microperiod * 2 * HIGHEST_VAL);
    }else{
      val = floor((microperiod-t) / microperiod * 2 * HIGHEST_VAL);
    }
    setPins(val);
}
