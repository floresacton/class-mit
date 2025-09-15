bsvimport SRAMArray;
bsvimport BRAMCore;

typedef struct {
    Bit#(addrSz) addr;
    Bool write;
    DataT data;
} SRAMReq#(Integer addrSz, type DataT);

module SRAM#(Integer addrSz, type DataT);
    SRAMArray#(addrSz, DataT) array;  // BSV array
    Reg#(Bool) arrayHasData(False);

    input Maybe#(SRAMReq#(addrSz, DataT)) req default = Invalid;

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);
            array.put(r.write, r.addr, r.data);
            arrayHasData <= !r.write;
        end else arrayHasData <= False;
    endrule

    method Maybe#(DataT) data = arrayHasData? Valid(array.read) : Invalid;
endmodule

module SRAMLoad#(Integer addrSz, type DataT)(String file);
    SRAMArrayLoad#(addrSz, DataT) array(file);  // BSV array
    Reg#(Bool) arrayHasData(False);

    input Maybe#(SRAMReq#(addrSz, DataT)) req default = Invalid;

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);
            array.put(r.write, r.addr, r.data);
            arrayHasData <= !r.write;
        end else arrayHasData <= False;
    endrule

    method Maybe#(DataT) data = arrayHasData? Valid(array.read) : Invalid;
endmodule

// Variant with byte-mask for writes

typedef struct {
    Bit#(addrSz) addr;
    Bit#(n) wren; // selects which bytes of data to write; 0 means read
    DataT data;
} SRAMBEReq#(Integer addrSz, Integer n, type DataT);

module SRAMBE#(Integer addrSz, Integer n, type DataT);
    SRAMBEArray#(addrSz, n, DataT) array;  // BSV array
    Reg#(Bool) arrayHasData(False);

    input Maybe#(SRAMBEReq#(addrSz, n, DataT)) req default = Invalid;

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);
            array.put(r.wren, r.addr, r.data);
            arrayHasData <= r.wren == 0;
        end else arrayHasData <= False;
    endrule

    method Maybe#(DataT) data = arrayHasData? Valid(array.read) : Invalid;
endmodule

module SRAMBELoad#(Integer addrSz, Integer n, type DataT)(String file);
    SRAMBEArrayLoad#(addrSz, n, DataT) array(file);  // BSV array
    Reg#(Bool) arrayHasData(False);

    input Maybe#(SRAMBEReq#(addrSz, n, DataT)) req default = Invalid;

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);
            array.put(r.wren, r.addr, r.data);
            arrayHasData <= r.wren == 0;
        end else arrayHasData <= False;
    endrule

    method Maybe#(DataT) data = arrayHasData? Valid(array.read) : Invalid;
endmodule