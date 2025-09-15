#ifndef IMAGE_DIGITS_H_
#define IMAGE_DIGITS_H_

#include "defines.h"

#define NUM_IMAGES 20
#define IMAGE_SIZE 784

extern const uint8_t mnist_images[NUM_IMAGES][IMAGE_SIZE];
extern const uint8_t mnist_labels[NUM_IMAGES];
extern const int8_t mnist_expected_activations[NUM_IMAGES][10];

#endif