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

// TODO: Complete the implementation of TwoWayCache
// NOTE: Implementing this module requires about 20 new lines of code from DirectMappedCache
module TwoWayCache(MainMemory mainMem);
    // SRAM arrays, one element per way (e.g., dataArrays[0] is the data array of way 0).
    Vector#(2, SRAM#(logCacheSets, Line)) dataArrays;
    Vector#(2, SRAM#(logCacheSets, CacheTag)) tagArrays;
    Vector#(2, SRAM#(logCacheSets, CacheStatus)) statusArrays;

    // LRU bits, one per set. We implement it as registers instead of an SRAM
    // array, because with small caches this is just a few bits (e.g., 64), and
    // SRAMs make sense only for larger memories. This also makes the code
    // simpler, and will make the cache easier to pipeline in the future.
    Vector#(cacheSets, RegU#(Bit#(1))) lru;


    // Registers for holding the current state of the cache and how far along
    // it is in processing a request.
    RegU#(MemReq) curReq;
    Reg#(ReqStatus) state(Ready);
 
    // Hit/miss counters
    Reg#(Word) hits(0);
    Reg#(Word) misses(0);
    
    input Maybe#(MemReq) req default = Invalid;
    
    // TODO return True if the cache can accept a new request
    method Bool reqEnabled = state == Ready;

    /*
    function Bool isHit(Integer way);
        return (state == Lookup) && (isValid(tagArrays[way].data)) && isValid(statusArrays[way].data) &&
               (fromMaybe(?, tagArrays[way].data) == getTag(curReq.addr)) &&
               (fromMaybe(?, statusArrays[way].data) != NotValid);
    endfunction
    */

    function Bool isHit0();
        return (state == Lookup) && (isValid(tagArrays[0].data)) && isValid(statusArrays[0].data) &&
               (fromMaybe(?, tagArrays[0].data) == getTag(curReq.addr)) &&
               (fromMaybe(?, statusArrays[0].data) != NotValid);
    endfunction
    
    function Bool isHit1();
        return (state == Lookup) && (isValid(tagArrays[1].data)) && isValid(statusArrays[1].data) &&
               (fromMaybe(?, tagArrays[1].data) == getTag(curReq.addr)) &&
               (fromMaybe(?, statusArrays[1].data) != NotValid);
    endfunction

    rule tick;
        if (state == Ready && isValid(req)) begin
            let validReq = fromMaybe(?, req);
            state <= Lookup;
            curReq <= validReq;

            CacheIndex lineIndex = getIndex(validReq.addr);
            dataArrays[0].req = Valid(DataReq{addr: lineIndex, write: False, data: ?});
            tagArrays[0].req = Valid(TagReq{addr: lineIndex, write: False, data: ?});
            statusArrays[0].req = Valid(StatusReq{addr: lineIndex, write: False, data: ?});

            dataArrays[1].req = Valid(DataReq{addr: lineIndex, write: False, data: ?});
            tagArrays[1].req = Valid(TagReq{addr: lineIndex, write: False, data: ?});
            statusArrays[1].req = Valid(StatusReq{addr: lineIndex, write: False, data: ?});
        end else if (state == Lookup) begin
            if (isHit0()) begin
                state <= Ready;
                hits <= hits + 1;
                lru[getIndex(curReq.addr)] <= 1;
                if (isStore(curReq.op)) begin
                    CacheIndex index = getIndex(curReq.addr);
                    WordOffset offset = getWordOffset(curReq.addr);
                    Line storeLine = fromMaybe(?, dataArrays[0].data);
                    Word storeWord = getStoreData(storeLine[offset], curReq.data, getByteOffset(curReq.addr), curReq.op);
                    storeLine[offset] = storeWord;
                    dataArrays[0].req = Valid(DataReq{addr: index, write: True, data: storeLine});
                    tagArrays[0].req = Valid(TagReq{addr: index, write: True, data: getTag(curReq.addr)});
                    statusArrays[0].req = Valid(StatusReq{addr: index, write: True, data: Dirty});
                end
            end else if (isHit1()) begin
                state <= Ready;
                hits <= hits + 1;
                lru[getIndex(curReq.addr)] <= 0;
                if (isStore(curReq.op)) begin
                    CacheIndex index = getIndex(curReq.addr);
                    WordOffset offset = getWordOffset(curReq.addr);
                    Line storeLine = fromMaybe(?, dataArrays[1].data);
                    Word storeWord = getStoreData(storeLine[offset], curReq.data, getByteOffset(curReq.addr), curReq.op);
                    storeLine[offset] = storeWord;
                    dataArrays[1].req = Valid(DataReq{addr: index, write: True, data: storeLine});
                    tagArrays[1].req = Valid(TagReq{addr: index, write: True, data: getTag(curReq.addr)});
                    statusArrays[1].req = Valid(StatusReq{addr: index, write: True, data: Dirty});
                end
            end else begin
                Bit#(1) select = lru[getIndex(curReq.addr)];
                if (fromMaybe(?, statusArrays[select].data) != Dirty) begin
                    // $display("CLEAN");
                    state <= Fill;
                    misses <= misses + 1;
                    mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), write: False, data: ?});
                end else begin
                    // $display("DIRTY");
                    state <= Writeback;
                    misses <= misses + 1;
                    mainMem.req = Valid(LineReq{lineAddr: {fromMaybe(?, tagArrays[select].data), getIndex(curReq.addr)}, write: True, data: fromMaybe(?, dataArrays[select].data)});
                end
            end
        end else if (state == Writeback && mainMem.reqEnabled) begin
            state <= Fill;
            mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), write: False, data: ?});
        end else if (state == Fill && isValid(mainMem.data)) begin
            Bit#(1) select = lru[getIndex(curReq.addr)];
            lru[getIndex(curReq.addr)] <= select^1;
            state <= Ready;
            CacheIndex index = getIndex(curReq.addr);
            Line memLine = fromMaybe(?, mainMem.data);
            tagArrays[select].req = Valid(TagReq{addr: index, write: True, data: getTag(curReq.addr)});
            if (isStore(curReq.op)) begin
                memLine[getWordOffset(curReq.addr)] = getStoreData(memLine[getWordOffset(curReq.addr)], curReq.data, getByteOffset(curReq.addr), curReq.op);
                statusArrays[select].req = Valid(StatusReq{addr: index, write: True, data: Dirty});
            end else begin
                statusArrays[select].req = Valid(StatusReq{addr: index, write: True, data: Clean});
            end
            dataArrays[select].req = Valid(DataReq{addr: index, write: True, data: memLine});
        end
            
    endrule

    method Maybe#(Word) data;
        // This method should return a Valid output in only two cases:
        // 1. On a load hit (we're in the Lookup state, there's a hit, and
        //    isLoad(curReq.op)).
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

        // This function should take about 5-20 lines of code to implement.
        if (isLoad(curReq.op)) begin
            if (isHit0()) begin
                return Valid(getLoadData(fromMaybe(?, dataArrays[0].data)[getWordOffset(curReq.addr)], getByteOffset(curReq.addr), curReq.op));
            end else if (isHit1()) begin
                return Valid(getLoadData(fromMaybe(?, dataArrays[1].data)[getWordOffset(curReq.addr)], getByteOffset(curReq.addr), curReq.op));
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
