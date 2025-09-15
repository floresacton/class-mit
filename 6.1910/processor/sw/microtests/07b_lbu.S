// This is a more complex test that tests that your processor handles lbu (and
// AUIPC and ADDI) correctly.
.text
start:
    la x1, e // pseudoinstruction that puts the address of label e into x1
    lbu x2, 0(x1)
    lbu x3, 1(x1)
    lbu x4, 2(x1)
    lbu x5, 3(x1)
    lbu x6, -1(x1)
    lbu x7, -2(x1)
    lbu x8, -3(x1)
    lbu x9, -4(x1)
    addi x10, x1, -0x800
    lbu x11, 0x7FC(x10) // should match the address of a
    lbu x12, 0x7FD(x10)
    lbu x13, 0x7FE(x10)
    lbu x14, 0x7FF(x10)
    unimp

.data
. = 0x1000
a:      .byte 0
b:      .byte 1
c:      .byte 52
d:      .byte 41  // this is the -215 but in 1 byte
e:      .byte 17
f:      .byte 59
g:      .byte 12
h:      .byte -16