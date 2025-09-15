#include "utils.h"

void print_string(char* s) {
    while (*s != '\0') {
        print_char(*s);
        s++;
    }
}

const int INT_PRINT_LIMIT = 10;
void print_int(int a) {
    int bases[INT_PRINT_LIMIT];
    bases[0] = 1;
    int i = 0;
    for (i = 1; i < INT_PRINT_LIMIT; i++) {
        bases[i] = bases[i - 1] * 10;
    }
    i = 0;
    if (a == 0) {
        print_char('0');
    } else if (a == 0x80000000) {
        print_string("-2147483648");
    } else {
        if (a < 0) {
            print_char('-');
            a = -a;
        }
        int j = INT_PRINT_LIMIT - 1;
        while (a < bases[j]) j--;
        while (j >= 0) {
            int d = 0;
            while (a >= bases[j]) {
                a -= bases[j];
                d ++;
            }
            print_char('0' + d);
            j--;
        }
    }
}

void print_int_hex(unsigned int a) {
    const char hex_lookup[] = "0123456789abcdef";
    int len = 0;

    if (a == 0) len = 1;
    else for (unsigned int n = a; n; n >>= 4) len++;

    for (int i = len - 1; i >= 0; i--)
        print_char(hex_lookup[(a >> (4 * i)) & 0xf]);
}