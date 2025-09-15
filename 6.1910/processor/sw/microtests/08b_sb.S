// This is a more complex test that tests that your processor handles sb (and
// ADDI, AUIPC, and LW) correctly.
.text
start:
    la x1, e

    // test positive offsets
    li x2, 15
    sb x2, 0(x1) // address of e

    li x2, 10
    sb x2, 1(x1) // address of f

    li x2, 5
    sb x2, 2(x1)  // address of g

    li x2, 0
    sb x2, 3(x1) // address of h

    // test negative offsets
    li x2, 1
    sb x2, -1(x1) // address of d

    li x2, 2
    sb x2, -2(x1) // address of c

    // test large offsets
    li x3, 0x810

    li x2, 100
    sb x2, 0x7f0(x3) // address of a

    li x2, 200
    sb x2, 0x7f1(x3) // address of b

    // check
    lbu x2, 0(x1)   // e
    lbu x3, 1(x1)   // f
    lbu x4, 2(x1)   // g
    lbu x5, 3(x1)   // h
    lbu x6, -1(x1)  // d
    lbu x7, -2(x1)  // c
    lbu x8, -3(x1)  // b
    lbu x9, -4(x1)  // a
    unimp

.data
a:      .byte 0
b:      .byte 1
c:      .byte 52
d:      .byte 41
e:      .byte 17
f:      .byte 59
g:      .byte 12
h:      .byte -16

