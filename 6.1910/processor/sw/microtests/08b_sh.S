// This is a more complex test that tests that your processor handles sh (and
// ADDI, AUIPC, and LW) correctly.
.text
start:
    la x1, e

    // test positive offsets
    li x2, 15
    sh x2, 0(x1) // address of e

    li x2, 10
    sh x2, 2(x1) // address of f

    li x2, 5
    sh x2, 4(x1)  // address of g

    li x2, 0
    sh x2, 6(x1) // address of h

    // test negative offsets
    li x2, 1
    sh x2, -2(x1) // address of d

    li x2, 2
    sh x2, -4(x1) // address of c

    // test large offsets
    li x3, 0x810

    li x2, 100
    sh x2, 0x7f0(x3) // address of a

    li x2, 200
    sh x2, 0x7f2(x3) // address of b

    // check
    lh x2, 0(x1)   // e
    lh x3, 2(x1)   // f
    lh x4, 4(x1)   // g
    lh x5, 6(x1)   // h
    lh x6, -2(x1)  // d
    lh x7, -4(x1)  // c
    lh x8, -6(x1)  // b
    lh x9, -8(x1)  // a
    unimp

.data
a:      .half 0
b:      .half 1
c:      .half 52
d:      .half -215
e:      .half 17
f:      .half 59
g:      .half 12
h:      .half -16

