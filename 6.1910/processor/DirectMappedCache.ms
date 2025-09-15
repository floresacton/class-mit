import CacheTypes;
import CacheHelpers;
import MainMemory;

// ReqStatus (defined in CacheTypes.ms) is used to keep track of the state of the current request
//typedef enum {
//    Ready,         // The cache is ready for a new request
//    Lookup,        // Issued a lookup to tag/data arrays
//    Writeback,     // In main memory access for dirty writeback
//    Fill           // In main memory access for requested data
//} ReqStatus;
//
// Possible flows:
//   HIT: Ready -> Lookup -> Ready
//   MISS, line is clean: Ready -> Lookup -> Fill
//   MISS, line is dirty: Ready -> Lookup -> Writeback -> Fill

// Cache SRAM Synonyms (defined in CacheTypes.ms)
// You may find the following type synonyms helpful to access the tag/data/status arrays
// typedef SRAMReq#(logCacheSets, CacheTag) TagReq;
// typedef SRAMReq#(logCacheSets, Line) DataReq;
// typedef SRAMReq#(logCacheSets, CacheStatus) StatusReq;

// TODO: Complete the implementation of DirectMappedCache
// NOTE: Implementing this module requires about 60 lines of additional code
// (~40-50 lines in rule tick, ~5-15 lines in method data, 1 line in method reqEnabled, 1 line in function isHit;
//  you may want to define an additional function to construct the word to write to the data array on a store,
//  combining the line's current data and the word/half-word/byte that is updated on an Sw/Sh/Sb operation)
module DirectMappedCache(MainMemory mainMem);
    // SRAM arrays. Note that, for a direct-mapped cache,
    // number of cache sets == number of cache lines
    SRAM#(logCacheSets, Line) dataArray;
    SRAM#(logCacheSets, CacheTag) tagArray;
    SRAM#(logCacheSets, CacheStatus) statusArray;
    
    // Registers for holding the current state of the cache and how far along
    // it is in processing a request.
    RegU#(MemReq) curReq;
    Reg#(ReqStatus) state(Ready);
    
    // Hit/miss counters
    Reg#(Word) hits(0);
    Reg#(Word) misses(0);

    input Maybe#(MemReq) req default = Invalid;

    method Bool reqEnabled = state == Ready || (isLoad(curReq.op) && isHit());

    function Bool isHit;
        return (state == Lookup) && (isValid(tagArray.data)) && isValid(statusArray.data) &&
               (fromMaybe(?, tagArray.data) == getTag(curReq.addr)) &&
               (fromMaybe(?, statusArray.data) != NotValid);
    endfunction

    rule tick;
        if (state == Ready && isValid(req)) begin
            let validReq = fromMaybe(?, req);
            state <= Lookup;
            curReq <= validReq;

            CacheIndex lineIndex = getIndex(validReq.addr);
            dataArray.req = Valid(DataReq{addr: lineIndex, write: False, data: ?});
            tagArray.req = Valid(TagReq{addr: lineIndex, write: False, data: ?});
            statusArray.req = Valid(StatusReq{addr: lineIndex, write: False, data: ?});
        end else if (state == Lookup) begin
            // $display("------LAST------");
            // $display("STATUS: 0b%b", fromMaybe(?, statusArray.data));
            // $display("TAG: 0x%h", fromMaybe(?, tagArray.data));
            // $display("DATA: 0x%h", fromMaybe(?, dataArray.data));
            // $display("------REQ-------");
            // $display("OP: %d", curReq.op);
            // $display("ADDR: 0x%h", curReq.addr);
            // $display("DATA: 0x%h", curReq.data);
            // $display("------REQD------");
            // $display("BYTEOFS: 0x%h", getByteOffset(curReq.addr));
            // $display("WORDOFS: 0x%h", getWordOffset(curReq.addr));
            // $display("IDX: 0x%h", getIndex(curReq.addr));
            // $display("TAG: 0x%h", getTag(curReq.addr));
            // $display("----------------");
            if (isHit()) begin
                // $display("HIT");
                // state <= Ready;

                hits <= hits + 1;

                if (isStore(curReq.op)) begin
                    let validReq = fromMaybe(?, req);
                    curReq <= validReq;
                    state <= Ready;

                    CacheIndex index = getIndex(curReq.addr);
                    WordOffset offset = getWordOffset(curReq.addr);
                    Line storeLine = fromMaybe(?, dataArray.data);
                    Word storeWord = getStoreData(storeLine[offset], curReq.data, getByteOffset(curReq.addr), curReq.op);
                    
                    storeLine[offset] = storeWord;
                    dataArray.req = Valid(DataReq{addr: index, write: True, data: storeLine});
                    tagArray.req = Valid(TagReq{addr: index, write: True, data: getTag(curReq.addr)});
                    statusArray.req = Valid(StatusReq{addr: index, write: True, data: Dirty});
                end else if (isValid(req)) begin
                    let validReq = fromMaybe(?, req);
                    curReq <= validReq;
                    state <= Lookup;

                    CacheIndex lineIndex = getIndex(validReq.addr);
                    dataArray.req = Valid(DataReq{addr: lineIndex, write: False, data: ?});
                    tagArray.req = Valid(TagReq{addr: lineIndex, write: False, data: ?});
                    statusArray.req = Valid(StatusReq{addr: lineIndex, write: False, data: ?});
                end else begin
                    state <= Ready;
                end
            end else if (fromMaybe(?, statusArray.data) != Dirty) begin
                // $display("CLEAN");
                state <= Fill;
                misses <= misses + 1;
                mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), write: False, data: ?});
            end else begin
                // $display("DIRTY");
                state <= Writeback;
                misses <= misses + 1;
                mainMem.req = Valid(LineReq{lineAddr: {fromMaybe(?, tagArray.data), getIndex(curReq.addr)}, write: True, data: fromMaybe(?, dataArray.data)});
            end
        end else if (state == Writeback && mainMem.reqEnabled) begin
            state <= Fill;
            mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), write: False, data: ?});
        end else if (state == Fill && isValid(mainMem.data)) begin
            state <= Ready;
            CacheIndex index = getIndex(curReq.addr);
            Line memLine = fromMaybe(?, mainMem.data);
            tagArray.req = Valid(TagReq{addr: index, write: True, data: getTag(curReq.addr)});
            if (isStore(curReq.op)) begin
                memLine[getWordOffset(curReq.addr)] = getStoreData(memLine[getWordOffset(curReq.addr)], curReq.data, getByteOffset(curReq.addr), curReq.op);
                statusArray.req = Valid(StatusReq{addr: index, write: True, data: Dirty});
            end else begin
                statusArray.req = Valid(StatusReq{addr: index, write: True, data: Clean});
            end
            dataArray.req = Valid(DataReq{addr: index, write: True, data: memLine});
        end
    endrule

    method Maybe#(Word) data;
        // This method should return a Valid output in only two cases:
        // 1. On a load hit (it is a hit, and isLoad(curReq.op)).
        // 2. On a fill for a load request (we're in the Fill state,
        //    mainMem.data is valid, and isLoad(curReq.op)).
        // In all other cases, the output should be Invalid.
        //
        // This method should handle sub-word loads, producing the right 32-bit
        // output to store on a register from the word read from the cache.
        //
        // NOTE: You should be checking the above conditions explicitly in
        //    THIS method so you can return data as soon as possible.
        //    DO NOT place your output into a register in the rule and then
        //    simply return that register here.

        // This function should take about 5-15 lines of code to implement.
        if (isLoad(curReq.op)) begin
            if (isHit()) begin
                return Valid(getLoadData(fromMaybe(?, dataArray.data)[getWordOffset(curReq.addr)], getByteOffset(curReq.addr), curReq.op));
            end else if (state == Fill && isValid(mainMem.data)) begin
                Line memLine = fromMaybe(?, mainMem.data);
                Word memWord = memLine[getWordOffset(curReq.addr)];
                return Valid(getLoadData(memWord, getByteOffset(curReq.addr), curReq.op));
            end else begin
                return Invalid();
            end
        end else begin
            return Invalid();
        end
    endmethod

    method Bit#(32) getHits = hits;
    method Bit#(32) getMisses = misses;
endmodule
