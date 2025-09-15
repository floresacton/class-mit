#ifndef MUL_H_
#define MUL_H_

#include "defines.h"

// GCC uses this unsigned multiplication function to override the * operator for unsigned/signed int multiply
uint32_t __mulsi3 (uint32_t a, uint32_t b) {
    uint32_t result = 0;

    // Examples of how to inline new instructions into C
    // read more at : https://sourceware.org/binutils/docs-2.34/as/RISC_002dV_002dFormats.html
    // and  https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html
    //
    // asm volatile (".insn r 0b0110011, 0b000, 0b0000001, %0, %1, %2" : "=r" (result) : "r"(a), "r"(b)); 
 
    while (b) {
        if (b & 1) {
            result += a;
        }
        a = a << 1;
        b = b >> 1;
    }
    return result;

}

// Same as above but for 64 bit multiplication

// WARNING: Using unsigned 32x32 bit multiplication here will cause signed mulitplicaitons
// to fail! Since only 64x64 bit multiplicaiton will work, we suggest you implement and
// call a separate helper function instead which computes signed 32x32 bit multiplicaiton directly.

// If you would like to test your function with the provided testbench,
// make sure to change call to * in sw/mnist/mul64_test.c
uint64_t __muldi3 (uint64_t a, uint64_t b) {
    uint64_t result = 0;
    
    while (b) {
        if (b & 1) {
            result += a;
        }
        a = a << 1;
        b = b >> 1;
    }
    return result;

}

// SUGGESTED: Integrate into model.c and then implement in hardware
int32_t packmul(uint32_t input_i, uint32_t filter_i) {
    // input_i and filter_i each hold four adjacent int8_t numbers cast to a single uint32_t

    // NOTE: Packed elements of input buffer should be treated as unsigned.
    uint8_t a[4]; *(uint32_t*)a = input_i;
    int8_t b[4]; *(uint32_t*)b = filter_i; 

    // NOTE: software implementation of packmul relies on working 32 bit multiplication
    return (
        ((int32_t)a[0] * (int32_t)b[0]) +
        ((int32_t)a[1] * (int32_t)b[1]) +
        ((int32_t)a[2] * (int32_t)b[2]) +
        ((int32_t)a[3] * (int32_t)b[3])
    );
}

#endif