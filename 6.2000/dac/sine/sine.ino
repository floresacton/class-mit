// 6.200 DAC LAB: SINE

const float freq = 800;

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

void loop() {
    float microfreq = freq / 1000000;
    float t = (float)micros();
    int sine_val = floor((0.5*sin(t * tau * microfreq) + 0.5) * HIGHEST_VAL);
    setPins(sine_val);
}
