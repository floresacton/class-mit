#include "src/defines.h"
#include "src/utils.h"
#include "src/image_digits.h"
#include "src/model.h"


// change this number to be 0 to 20 
#ifndef NUM_TEST_TO_RUN
#define NUM_TEST_TO_RUN 1
#endif

// define FAST to use the wrong inference
// #define INFER_FAST

int main(int argc, char* argv[]) {
    int8_t ret = 0;
    int8_t* in_buffer  = getInput();
    int8_t* out_buffer = getOutput(); 
    for(int test_no = 0; test_no < NUM_TEST_TO_RUN; test_no ++)  {
        print_string("Input ");
        print_int(test_no);
        print_string(":\n");
        for(int i = 0; i < IMAGE_SIZE; i ++){
            in_buffer[i] = (int)mnist_images[test_no][i] - 128;
        }

        for(int i = 0; i < 28; i++) {
            for(int j = 0; j < 28; j++) {
                print_char(in_buffer[i* 28 + j] >0 ? '#': ' ');
                // print_int(in_buffer[i* 28 + j]);
                // print_char(',');
            }
            print_char('\n');
        }
        // call to the actual network function
        #ifdef INFER_FAST
        wrong_inference();
        #else
        inference();
        #endif

        print_string("Output ");
        print_int(test_no);
        print_string(": ");
        for(int i = 0; i < 10; i++) {
            print_int(out_buffer[i]);
            print_char(',');
        }
        print_string("\nExpected ");
        print_int(test_no);
        print_string(": ");
        for(int i = 0; i < 10; i++) {
            print_int(mnist_expected_activations[test_no][i]);
            print_char(',');
        }
        print_string("\nPrediction: ");
        int max_activation = -128;
        int prediction = -1;
        for(int i = 0; i < 10; i++) {
            if (out_buffer[i] > max_activation) {
                max_activation = out_buffer[i];
                prediction = i;
            }
        }
        print_int(prediction);
        
        print_string("\nExpected Prediction: ");
        print_int(mnist_labels[test_no]);
        print_char('\n');
        
        int mismatch = 0;
        for(int i = 0; i < 10; i++) {
            if(out_buffer[i] != mnist_expected_activations[test_no][i]) { 
                mismatch = 1;
                ret = 1;
            }
        }
        if(mismatch == 1) print_string("Mismatch Activations \n");

    }
    return ret;
}
