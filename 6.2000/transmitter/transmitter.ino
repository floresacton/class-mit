// CHANGE THIS TO BE A LAB-APPROPRIATE WORD OF YOUR CHOOSING
// YOU PROBABLY WANT TO KEEP THE \n on the font to make the output a little easier to read.
// (WITHOUT IT, YOU WON'T HAVE A BLANK LINE BETWEEN EACH WORD)
const char MY_WORD[] = "\n(^_^) yay 6.200";
const float FREQUENCY = 500;


// probably no need to change below this point
const int WORD_LENGTH = sizeof(MY_WORD) / sizeof(char);
const int NUM_BITS = WORD_LENGTH * 7;
const unsigned int BIT_PERIOD = 100000; // microseconds;
const double TAU = 2 * 3.141592;

void setup() {
  analogWriteFrequency(14, 1000000);
  pinMode(14, OUTPUT);
  pinMode(15, INPUT);
}

unsigned int bit_index = 0;

void loop() {
  unsigned long now = micros();
  unsigned int bit_index = (now / BIT_PERIOD) % (NUM_BITS+7);

  if (bit_index < 7){
    analogWrite(14, 128);
  }else{
    int which_char = bit_index / 7 - 1;
    int which_bit = bit_index % 7;
    int this_bit = (MY_WORD[which_char] & (1 << (6-which_bit))) >> (6-which_bit);
    float where_in_bit = (float)(now % BIT_PERIOD) / BIT_PERIOD;
    float val = 0.5 + 0.5 * sin(FREQUENCY * TAU * now / 1E6) * (where_in_bit < (this_bit ? 0.25: 0.75));
    analogWrite(14, (int)(val*255));
  }
}
