// 6.200 DAC LAB: SONG

// NOTE: tweak this to adjust resolution (feel free to add more bits!)
// use pins 14, 15, ..., 13+DAC_RESOLUTION
// highest pin is MSB.
const uint8_t DAC_RESOLUTION = 6;

// set up some initial variables based on the DAC resolution and whatnot
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

// bring in the song definitions from elsewhere
// this makes variables called SONG (the samples) and FS (the sampling rate)
#include "song_data_6bit.h"

unsigned int nominalWait = (unsigned int)(1E6/FS);
unsigned int sample = 0;


// this function runs once (at startup time)
void setup() {
  // determine pin numbers and let arduino know we're using them as output
  for (int i=0; i < DAC_RESOLUTION; i++){
    PINS[i] = 13+DAC_RESOLUTION-i;
    pinMode(PINS[i], OUTPUT);
  }
}


//runs repeatedly, as often as possible
void loop() {
    // simply walk through the samples, setting the pins appropriately for each
    // sample
    delayMicroseconds(nominalWait);
    sample = (sample + 1) % SONGLENGTH;
    setPins(SONG[sample]);
}
