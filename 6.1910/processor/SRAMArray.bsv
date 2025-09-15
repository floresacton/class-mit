// BSV glue code for single-ported, non-loaded/loaded BRAM memories
import BRAMCore::*;

typedef BRAM_PORT#(Bit#(addrSz), dataT) SRAMArray#(numeric type addrSz, type dataT);

module mkSRAMArray(SRAMArray#(addrSz, dataT) ) provisos (Bits#(dataT, dataSz));
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_PORT#(Bit#(addrSz), dataT) bram <- mkBRAMCore1(memSz, hasOutputRegister);
    return bram;
endmodule

typedef BRAM_PORT#(Bit#(addrSz), dataT) SRAMArrayLoad#(numeric type addrSz, type dataT);

module mkSRAMArrayLoad#(String file)(SRAMArrayLoad#(addrSz, dataT)) provisos (Bits#(dataT, dataSz));
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_PORT#(Bit#(addrSz), dataT) bram <- mkBRAMCore1Load(memSz, hasOutputRegister, file, False);
    return bram;
endmodule

// Byte-enabled SRAM variant
typedef BRAM_PORT_BE#(Bit#(addrSz), dataT, n) SRAMBEArray#(numeric type addrSz, numeric type n, type dataT);

module mkSRAMBEArray(SRAMBEArray#(addrSz, n, dataT))
    provisos (
        // dsm: Required by SRAM
        Bits#(dataT, dataSz),
        // dsm: Required by SRAMBE
        Mul#(TDiv#(dataSz, n), n, dataSz),
        // dsm: Additional provisos to ensure these are BYTE enables
        // Note that this means you can only use this when dataSz is a multiple of 8
        // If you're getting proviso errors of the form Mul#(x, y, z) or Add#(x, 0, z),
        // your value of n is incorrect! (n * 8 must match the SRAM's data width)
        Mul#(n, 8, nTimes8), Add#(nTimes8, 0, dataSz)
    );
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_PORT_BE#(Bit#(addrSz), dataT, n) bram <- mkBRAMCore1BE(memSz, hasOutputRegister);
    return bram;
endmodule

// Byte-enabled SRAM variant
typedef BRAM_PORT_BE#(Bit#(addrSz), dataT, n) SRAMBEArrayLoad#(numeric type addrSz, numeric type n, type dataT);

module mkSRAMBEArrayLoad#(String file)(SRAMBEArrayLoad#(addrSz, n, dataT))
    provisos (
        // dsm: Required by SRAM
        Bits#(dataT, dataSz),
        // dsm: Required by SRAMBE
        Mul#(TDiv#(dataSz, n), n, dataSz),
        // dsm: Additional provisos to ensure these are BYTE enables
        // Note that this means you can only use this when dataSz is a multiple of 8
        // If you're getting proviso errors of the form Mul#(x, y, z) or Add#(x, 0, z),
        // your value of n is incorrect! (n * 8 must match the SRAM's data width)
        Mul#(n, 8, nTimes8), Add#(nTimes8, 0, dataSz)
    );
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_PORT_BE#(Bit#(addrSz), dataT, n) bram <- mkBRAMCore1BELoad(memSz, hasOutputRegister, file, False);
    return bram;
endmodule