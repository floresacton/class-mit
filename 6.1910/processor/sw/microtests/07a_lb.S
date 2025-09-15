// This is a minimal test that tests that your processor handles LW (and AUIPC
// and ADDI) correctly.
.text
start:
    la x1, label
    lb x2, 0(x1)
    lb x3, 1(x1)
    lb x4, 2(x1)
    lb x5, 3(x1)
    unimp

.data
label:  .word 0x1234F678
