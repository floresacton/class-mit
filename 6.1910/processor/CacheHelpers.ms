import CacheTypes;

////////////////////////////////////////
// Address Helper Functions //
// NOTE: Each of these functions can be implemented with a single line.
// Use the constants logCacheSets and logWordsPerLine, defined in CacheTypes.ms
////////////////////////////////////////


// Extract the Cache Line Byte Offset from a given memory address
function ByteOffset getByteOffset(Word byteAddress);
    return byteAddress[1:0];
endfunction

// Extract the Cache Line Index from a given memory address
function CacheIndex getIndex(Word byteAddress);
    // TODO: Implement this in Exercise 1.
    return byteAddress[11:6];
endfunction


// Extract the Cache Line Tag from a given memory address
function CacheTag getTag(Word byteAddress);
    // TODO: Implement this in Exercise 1.
    return byteAddress[31:12]; 
endfunction


// Extract the Cache Line Word Offset from a given memory address
function WordOffset getWordOffset(Word byteAddress);
    // TODO: Implement this in Exercise 1.
    return byteAddress[5:2];
endfunction


// Extract the line address (tag + index) from a given memory address
function LineAddr getLineAddr(Word byteAddress);
    // TODO: Implement this in Exercise 1.
    return byteAddress[31:6]; 
endfunction


////////////////////////////////////////
// Memory Helper Functions //
////////////////////////////////////////

// Load the correct word (or halfword or byte based on the given memory 
// operation `op`) from `word`. If `op` is a subword load operation, use 
// memory address in `byteOffset` to extract the correct bytes of data.
function Word getLoadData(Word word, Bit#(2) byteOffset, MemFunc op);
    case (op)
        Lbu: case (byteOffset)
            0: return zeroExtend(word[7:0]);
            1: return zeroExtend(word[15:8]);
            2: return zeroExtend(word[23:16]);
            3: return zeroExtend(word[31:24]);
        endcase
        Lb: case (byteOffset)
            0: return signExtend(word[7:0]);
            1: return signExtend(word[15:8]);
            2: return signExtend(word[23:16]);
            3: return signExtend(word[31:24]);
        endcase
        Lhu: case (byteOffset)
            0: return zeroExtend(word[15:0]);
            2: return zeroExtend(word[31:16]);
        endcase
        Lh: case (byteOffset)
            0: return signExtend(word[15:0]);
            2: return signExtend(word[31:16]);
        endcase
        default: return word;
    endcase
endfunction


// Store the new data `newData` in word `currentData`. If `op` is a subword 
// store operation, store the correct bytes of data from `newData` in the 
// correct bytes of word `currentData`. Return modified word.
function Word getStoreData(Word currentData, Word newData, Bit#(2) byteOffset, MemFunc op);
    case (op)
        Sb: case (byteOffset)
            0: return {currentData[31:8], newData[7:0]};
            1: return {currentData[31:16], newData[7:0], currentData[7:0]};
            2: return {currentData[31:24], newData[7:0], currentData[15:0]};
            3: return {newData[7:0], currentData[23:0]};
        endcase
        Sh: case (byteOffset)
            0: return {currentData[31:16], newData[15:0]};
            2: return {newData[15:0], currentData[15:0]};
        endcase
        default: return newData;
    endcase
endfunction
