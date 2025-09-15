// This is a more complex test that tests that your processor handles lh (and
// AUIPC and ADDI) correctly.
.text
start:
    la x1, e // pseudoinstruction that puts the address of label e into x1
    lh x2, 0(x1)
    lh x3, 2(x1)
    lh x4, 4(x1)
    lh x5, 6(x1)
    lh x6, -2(x1)
    lh x7, -4(x1)
    lh x8, -6(x1)
    lh x9, -8(x1)
    addi x10, x1, -0x800
    lh x11, 0x7F8(x10) // should match the address of a
    lh x12, 0x7FA(x10)
    lh x13, 0x7FC(x10)
    lh x14, 0x7FE(x10)
    unimp

.data
. = 0x1000
a:      .half 0
b:      .half 1
c:      .half 52
d:      .half -215
e:      .half 17
f:      .half 59
g:      .half 12
h:      .half -16