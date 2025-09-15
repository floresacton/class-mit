import ProcTypes;
import CacheTypes;
import SRAM;
bsvimport Assert;

Integer timeOutLimit = 2000000000;


module WordMem;
    Integer memBytes = 1 << 24;  // 16 MB
    Integer memWords = memBytes / 4;
    Integer addrBits = log2(memWords);
    SRAMBELoad#(addrBits, 4, Word) ram("mem.vmh");

    RegU#(Bit#(2)) curWordOffset;
    RegU#(MemFunc) curOp;

    input Maybe#(MemReq) req default = Invalid;
    
    method Maybe#(Word) data;
        if (isValid(ram.data)) begin
            let d = fromMaybe(?, ram.data) >> ({curWordOffset, 3'b000});
            return Valid(case (curOp)
                Lw: d;
                Lh: signExtend(d[15:0]);
                Lhu: zeroExtend(d[15:0]);
                Lb: signExtend(d[7:0]);
                Lbu: zeroExtend(d[7:0]);
                default: ?;
            endcase);
        end else return Invalid;
    endmethod

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);
            
            // Check alignment
            if ((r.op == Lw || r.op == Sw) && r.addr[1:0] != 0) begin
                $display("Alignment violation: 0x%x must be multiple of 4 for op ", r.addr, r.op);
                $finish;
            end else if ((r.op == Lh || r.op == Lhu || r.op == Sh) && r.addr[0] != 0) begin
                $display("Alignment violation: 0x%x must be multiple of 2 for op ", r.addr, r.op);
                $finish;
            end
            Word wrData = r.data << ({r.addr[1:0], 3'b000});
            Bit#(4) wrEn = case (r.op)
                Sw: 4'b1111;
                Sh: 4'b0011 << {r.addr[1], 1'b0};
                Sb: 4'b0001 << r.addr[1:0];
                default: 4'b0000; // Loads
            endcase;
            ram.req = Valid(SRAMBEReq#(addrBits, 4, Word){
                addr: truncate(r.addr >> 2), wren: wrEn, data: wrData
            });
            // For reads
            curWordOffset <= r.addr[1:0];
            curOp <= r.op;
        end
    endrule
endmodule

// To emulate DRAM technology, MainMemory uses a word-based memory and adds some delay
module /*msc_pragma:nosynth*/ MainMemory;
    WordMem wordMem;
    Integer latency = wordsPerLine + 16;

    Reg#(Bit#(log2(latency) + 1)) cyclesLeft(0);
    RegU#(MemFunc) curOp;
    RegU#(Word) curAddr;
    Reg#(Bool) validOut(False);
    Vector#(wordsPerLine, RegU#(Word)) dataRegs;

    method Bool reqEnabled = (cyclesLeft == 0);
    input Maybe#(LineReq) req default = Invalid;

    method Maybe#(Line) data;
        Line res;
        for (Integer i = 0; i < wordsPerLine; i = i + 1)
            res[i] = dataRegs[i];
        return validOut? Valid(res) : Invalid;
    endmethod

    rule tick;
        // dsm: Check that wordsPerLine is a reasonable value
        if (wordsPerLine != 4 && wordsPerLine != 8 && wordsPerLine != 16) begin
            $display("ERROR: MainMemory requires wordsPerLine to be 4, 8, or 16");
            $finish;
        end

        dynamicAssert(!((cyclesLeft != 0) && isValid(req)), "MainMemory received request while not ready!\n\n");
        if (cyclesLeft != 0) cyclesLeft <= cyclesLeft - 1;
        if (cyclesLeft == 0 && isValid(req)) begin
            cyclesLeft <= latency;
            let r = fromMaybe(?, req);
            curAddr <= {r.lineAddr, 0};
            MemFunc o = Lw;
            if (r.write) o = Sw;
            curOp <= o;
            for (Integer i = 0; i < wordsPerLine; i = i + 1)
                dataRegs[i] <= r.data[i];
            if (!r.write)
                wordMem.req = Valid(MemReq{addr: {r.lineAddr, 0}, op: Lw, data: ?});
        end else if (cyclesLeft > latency - wordsPerLine) begin
            Bit#(logWordsPerLine) idx = truncate(curAddr >> 2);
            curAddr <= curAddr + 4;
            if (curOp == Lw) begin
                dataRegs[idx] <= fromMaybe(?, wordMem.data);
                wordMem.req = Valid(MemReq{addr: curAddr + 4, op: Lw, data: ?});
            end else wordMem.req = Valid(MemReq{addr: curAddr, op: Sw, data: dataRegs[idx]});
        end
        validOut <= (cyclesLeft == 1);
    endrule
endmodule

// Single-cycle word memory, used as ideal memory by the tests
module /*msc_pragma:nosynth*/ SingleCycleMemory;
    WordMem wordMem;

    Reg#(Bit#(64)) cycles(0);

    input Maybe#(MemReq) req default = Invalid;
    method Maybe#(Word) data = wordMem.data;

    // For detecting timeouts
    rule doCycle;
        cycles <= cycles + 1;
        if (cycles > timeOutLimit) begin
            $display("FAILED: Your processor timed out");
            $finish;
        end
    endrule

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);

            // MMIO and program termination
            if (r.op == Sw) begin
                if (r.addr == 'h4000_0000) begin
                    // Write character to stdout
                    $write("%c", r.data[7:0]);
                end else if (r.addr == 'h4000_0004) begin
                    // Write integer to stdout
                    $write("%0d", r.data);
                end else if (r.addr == 'h4000_1000) begin
                    // Exit simulation
                    $display("Total Clock Cycles = %d\n", cycles);
                    if (r.data == 0) begin
                        $display("PASSED");
                    end else begin
                        $display("FAILED %0d", r.data);
                    end
                    $finish;
                end
            end
        end
        wordMem.req = req;
    endrule
endmodule

module CacheWrapper#(type T)(MainMemory mainMem);
    T cache(mainMem);

    Reg#(Bit#(64)) cycles(0);

    input Maybe#(MemReq) req default = Invalid;
    method Maybe#(Word) data = cache.data;

    method Bool reqEnabled = cache.reqEnabled;

    // For detecting timeouts
    rule doCycle;
        cycles <= cycles + 1;
        if (cycles > timeOutLimit) begin
            $display("FAILED: Your processor timed out");
            $finish;
        end
    endrule

    rule tick;
        if (isValid(req)) begin
            // MMIO and program termination
            let curReq = fromMaybe(?, req);
            if (curReq.op == Sw) begin
                if (curReq.addr == 'h4000_0000) begin
                    // Write character to stdout
                    $write("%c", curReq.data[7:0]);
                end else if (curReq.addr == 'h4000_0004) begin
                    // Write integer to stdout
                    $write("%0d", curReq.data);
                end else if (curReq.addr == 'h4000_1000) begin
                    // Exit simulation
                    $display("Total Clock Cycles = %d\n", cycles);
                    if (curReq.data == 0) begin
                        $display("PASSED");
                    end else begin
                        $display("FAILED %0d", curReq.data);
                    end
                    $finish;
                end
            end
        end
        cache.req = req;
    endrule
endmodule
