import ProcTypes;

import RegisterFile;
import Decode;
import Execute;

// MainMemory includes the MainMemory port
// and the SingleCycleMemory modules
import MainMemory;

// Exercise 3: Select which cache(s) to import
import DirectMappedCache;
import TwoWayCache;

// Types associated with the Fetch stage
typedef enum {
    Dequeue, // Consume instruction at the f2d output, if any
    Stall, // Do not consume instruction at f2d
    Redirect  // Redirect fetch to another PC, annulling any fetched instructions
} FetchAction;

typedef struct {
    FetchAction fetchAction;
    Word redirectPC;  // PC to fetch from, used only if fetchAction is Redirect
} FetchInput;


typedef struct {
    Word pc;
    Word inst;
} F2D;

typedef struct {
    Word pc;
    DecodedInst dInst;
    Word rVal1;
    Word rVal2;
    // Add anything you need
} D2E;

typedef struct {
    Word pc;
    IType iType;
    Maybe#(RIndx) dst;
    Word data;
    // Add anything you need
} E2W;


// Fetch stage, including pc and instruction memory/cache
// 
// See handout for the structure of the recommended Fetch stage. 
//
// Implementing this module is optional: you can place the fetch logic and
// iMem/iCache inside the processor instead. We recommend you use a separate
// module to ease debugging.
module Fetch;
    Reg#(Word) pc(0);

    // Execise 3: uncomment this declaration
    // Extra bit of state to deal with interaction between iCache misses and annulments
    // For more details, see handout, Part 3.2, final bulletpoint
    Reg#(Bool) ignoreInstr(False);

    // Single-cycle Instruction Memory
    // Exercise 3: comment this declaration out
    // SingleCycleMemory iMem;
    
    // Line-based Main Memory to use with caches
    // Exercise 3: uncomment this declaration
    MainMemory iMem;

    // Exercise 3: choose which type of iCache to use
    DirectMappedCache iCache(iMem);
    // TwoWayCache iCache(iMem);

    input FetchInput in;

    // Exercise 3: Modify to use iCache instead
    method Maybe#(F2D) f2d = (isValid(iCache.data) && !ignoreInstr)?
        Valid(F2D{pc: pc, inst: fromMaybe(?, iCache.data)}) : Invalid;

    rule fetch;
        Bool written = False;

        case (in.fetchAction)
        Dequeue: begin
            pc <= pc + 4;
            // if (iCache.reqEnabled) begin
                iCache.req = Valid(MemReq{op: Lw, addr: pc+4, data: ?});
            // end
        end
        Redirect: begin
            pc <= in.redirectPC;
            ignoreInstr <= True;
            written = True;
            // if (iCache.reqEnabled) begin
                iCache.req = Valid(MemReq{op: Lw, addr: in.redirectPC, data: ?});
            // end
        end
        Stall: begin
            // if (iCache.reqEnabled) begin
                iCache.req = Valid(MemReq{op: Lw, addr: pc, data: ?});
            // end
        end
        endcase

        if (!written && isValid(iCache.data)) begin
            ignoreInstr <= False;
        end
    endrule

    // Used only for pipeline debugging; you should not use this method
    // elsewhere in your code (assume the fetch stage can run ahead)
    method Word getPc = pc; 
endmodule


module Processor;
    Fetch fetch;

    RegisterFile rf;

    // Single-cycle data memory
    // Exercise 3: comment this declaration out
    // SingleCycleMemory dMem;

    // Line-based Main Memory to use with caches
    // Exercise 3: uncomment this declaration
    MainMemory dMem;

    // Exercise 3: choose which type of data cache to use
    // NOTE: The CacheWrapper#() type of the dCache is critical, as it is used
    // for detecting that the program has finished running
    CacheWrapper#(DirectMappedCache) dCache(dMem);
    // CacheWrapper#(TwoWayCache) dCache(dMem);

    // Pipeline Registers
    Reg#(Maybe#(D2E)) d2e(Invalid);
    Reg#(Maybe#(E2W)) e2w(Invalid);

    // Performance counters
    // These are used in the processor rule for debugging help, by tracking the
    // cycles and instructions completed. They are not needed for correctness
    // and you may remove them, but doing so is unlikely to reduce cycle time.
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(32)) instrs(0);

    rule tick;
        //////////////////////
        // Debugging Helper //
        //////////////////////
        cycle <= cycle + 1;
        // Uncomment the code below to print pipeline state each cycle
        begin
            $write("[%d] F|D|E|W PCs: ", cycle);
            $write("%x|", fetch.getPc);
            if (isValid(fetch.f2d)) $write("%x|", fromMaybe(?, fetch.f2d).pc); else $write("%8s|", "NOP");
            if (isValid(d2e)) $write("%x|", fromMaybe(?, d2e).pc); else $write("%8s|", "NOP");
            if (isValid(e2w)) $write("%x", fromMaybe(?, e2w).pc); else $write("%8s", "NOP");
            $display("  instrs: %d", instrs);
        end

        /////////////////////
        // Writeback Stage //
        /////////////////////
        // Signals used by decode to handle data hazards
        RIndx dstW = 0;
        Word dataW = 0;

        // Exercise 3:
        // Signal for dCache-induced stalls
        Bool dDataStall = False;

        if (isValid(e2w)) begin
            E2W e2w_v = fromMaybe(?, e2w);
            dstW = fromMaybe(0, e2w_v.dst);
            dataW = e2w_v.data;
        
            if (e2w_v.iType == LOAD) begin
                // if (dstW != 0) begin
                if (isValid(dCache.data)) begin
                    dataW = fromMaybe(?, dCache.data);
                    rf.wr = Valid(RegWriteArgs{index: dstW, data: dataW});
                end else begin
                    // $display("dDataStalling ------------");
                    dDataStall = True;
                end
                // end
            //end else if (e2w_v.iType == STORE) begin
            //     if (isValid())
                // cache stuff ?
            end else begin
                // if (dstW != 0) begin
                rf.wr = Valid(RegWriteArgs{index: dstW, data: dataW});
                // end
            end

            // Count every instruction that leaves the writeback stage
            // (for debugging help)
            instrs <= instrs + 1;

            // BEGIN: DO NOT REMOVE OR MODIFY THIS CODE
            // If unsupported instruction, stops simulation and print the state of the processor
            if (e2w_v.iType == Unsupported) begin
                $display("Reached unsupported instruction");
                $display("Dumping the state of the processor");
                $display("pc = 0x%x", e2w_v.pc);
                $display(rf.fshow);
                $display("Quitting simulation.");
                $finish;
            end
            // END: DO NOT REMOVE OR MODIFY THIS CODE
        end

        ///////////////////
        // Execute Stage //
        ///////////////////
        // Signals used to handle mispredictions
        Bool annul = False;
        Word redirectPC = ?;

        // Signals used by decode to handle data hazards
        RIndx dstE = 0;
        Maybe#(Word) dataE = Invalid;

        // Exercise 3:
        // Signal for dCache-induced stalls
        Bool dReqStall = False; // if data stalls then req stalls

        if (!dDataStall) begin
            if (isValid(d2e)) begin
                let d2e_v = fromMaybe(?, d2e);

                ExecInst eInst = execute(d2e_v.dInst, d2e_v.rVal1, d2e_v.rVal2, d2e_v.pc);
                
                dstE = fromMaybe(0, eInst.dst);

                if (eInst.nextPc != (d2e_v.pc + 4)) begin
                    annul = True;
                    redirectPC = eInst.nextPc;
                end

                if (eInst.iType == LOAD || eInst.iType == STORE) begin
                    if (dCache.reqEnabled) begin
                        dCache.req = Valid(MemReq{op: eInst.memFunc, addr: eInst.addr, data: d2e_v.rVal2});
                    end else begin
                        dReqStall = True;
                    end
                end

                if (!dReqStall) begin
                    e2w <= Valid(E2W{
                        pc: d2e_v.pc,
                        iType: eInst.iType,
                        dst: eInst.dst,
                        data: eInst.data
                    });
                end else begin
                    e2w <= Invalid;
                end
            end else begin
                e2w <= Invalid;
            end
        end

        //////////////////
        // Decode Stage //
        //////////////////
        // Signal for decode stalls
        Bool hazardStall = False;

        if (isValid(fetch.f2d)) begin
            F2D f2d_v = fromMaybe(?, fetch.f2d);

            DecodedInst dInst = decode(f2d_v.inst);

            Word rVal1 = rf.rd1(dInst.src1);
            Word rVal2 = rf.rd2(dInst.src2);

            //bypass
            if (dInst.src1 != 0 && dInst.iType != LUI && dInst.iType != JAL) begin
                if (dInst.src1 == dstE) begin
                    if (isValid(dataE)) begin
                        rVal1 = fromMaybe(?, dataE);
                    end else hazardStall = True;
                end else if (dInst.src1 == dstW) begin
                    rVal1 = dataW;
                end
            end

            if (dInst.src2 != 0 && (dInst.iType == OP || dInst.iType == BRANCH || dInst.iType == STORE)) begin
                if (dInst.src2 == dstE) begin
                    if (isValid(dataE)) begin
                        rVal2 = fromMaybe(?, dataE);
                    end else hazardStall = True;
                end else if (dInst.src2 == dstW) begin
                    rVal2 = dataW;
                end
            end

            // if (dInst.src1 != 0 && dInst.src1 == dstE) begin
            //     hazardStall = True;
            // end

            // if (dInst.src2 != 0 && dInst.src2 == dstE) begin
            //     hazardStall = True;
            // end

            // if (dInst.src1 != 0 && dInst.src1 == dstW) begin
            //     hazardStall = True;
            // end

            // if (dInst.src2 != 0 && dInst.src2 == dstW) begin
            //     hazardStall = True;
            // end


            if (!dReqStall) begin
                if (annul || hazardStall) begin
                    d2e <= Invalid;
                end else if (!dDataStall) begin
                    d2e <= Valid(D2E{
                        pc: f2d_v.pc,
                        dInst: dInst,
                        rVal1: rVal1,
                        rVal2: rVal2
                    });
                end
            end
        end else begin
            if (!dReqStall) begin
                d2e <= Invalid;
            end
        end
        ///////////////////////
        // Drive fetch stage //
        ///////////////////////

        if (annul) begin
            fetch.in = FetchInput{fetchAction: Redirect, redirectPC: redirectPC};
        end else if (hazardStall || dDataStall || dReqStall || !isValid(fetch.f2d)) begin //|| dDataStall  
            fetch.in = FetchInput{fetchAction: Stall, redirectPC: ?};
        end else begin
            fetch.in = FetchInput{fetchAction: Dequeue, redirectPC: ?};
        end
    endrule

    // This method gives a non-trivial output that depends on execution so that
    // synth doesn't optimize out the whole processor :)
    method Word getPc = fetch.getPc;
endmodule
