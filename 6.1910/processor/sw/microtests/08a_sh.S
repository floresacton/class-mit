// This is a minimal test that tests that your processor handles SH (and ADDI
// and LW) correctly.
.text
start:
    li x1, 0x1000
    li x2, 0x4321
    sh x2, 0(x1)
    li x2, 0x8765
    sh x2, 2(x1)
    lw x3, 0(x1)
    unimp
