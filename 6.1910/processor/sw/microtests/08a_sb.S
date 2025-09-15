// This is a minimal test that tests that your processor handles SB (and ADDI
// and LW) correctly.
.text
start:
    li x1, 0x1000
    li x2, 0x21
    sb x2, 0(x1)
    li x2, 0x43
    sb x2, 1(x1)
    lhu x3, 0(x1)
    unimp
