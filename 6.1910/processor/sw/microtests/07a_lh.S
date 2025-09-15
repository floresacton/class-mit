// This is a minimal test that tests that your processor handles LW (and AUIPC
// and ADDI) correctly.
.text
start:
    la x1, label
    lh x2, 0(x1)
    lh x3, 2(x1)
    unimp

.data
label:  .word 0x1234F678
