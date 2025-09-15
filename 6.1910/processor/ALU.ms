// Don't change signature of existing functions. You may write additional helper functions if you want.

// Description: 32-bit right barrel shifter
// Arguments: in (value to be shifted); sftSz (shift size); sft_in (the bit shifted in)
// Return: {sft_in's, in[31:sftSz]}
function Bit#(32) barrelRShift(Bit#(32) in, Bit#(5) sftSz, Bit#(1) sft_in);
    Bit#(32) ret = in;

    for (Integer i = 0; i < 5; i = i + 1) begin
        Bit#(32) shift = {signExtend(sft_in), ret[31:(1<<i)]};
        ret = sftSz[i]==1 ? shift : ret;
    end

    return ret;
endfunction

// Description: 32-bit arithmetic/logic right shifter
// Arguments: in (value to be shifted); sftSz (shift size); arith (1 = arithmetic, 0 = logic)
// Return: in >> sftSz
function Bit#(32) sr32(Bit#(32) in, Bit#(5) sftSz, Bit#(1) arith);
    return barrelRShift(in, sftSz, arith & in[31]);
endfunction


// Description: 32-bit logic left shifter
// Arguments: in (values to be shifted); sftSz (shift size)
// Return: a << b
function Bit#(32) sll32(Bit#(32) in, Bit#(5) sftSz);
    return reverseBits(barrelRShift(reverseBits(in), sftSz, 0));
endfunction


// Description: 32-bit FULL shifter
// Arguments: in (value to be shifted); sftSz (shift size);
// ShiftTypes:
// LogicalRightShift
// ArithmeticRightShift
// LeftShift
//
// Return: in >> sftSz when right shift; in << sftSz otherwise
typedef enum {LogicalRightShift, ArithmeticRightShift, LeftShift} ShiftType;

function Bit#(32) sft32(Bit#(32) in, Bit#(5) sftSz, ShiftType shiftType);
    Bit#(32) ret = shiftType==LeftShift?reverseBits(in):in;
    ret = barrelRShift(ret, sftSz, shiftType==ArithmeticRightShift?in[31]:0);
    return shiftType==LeftShift?reverseBits(ret):ret;
endfunction


// Description: one-bit less-than comparator
// Arguments: a, b (1-bit values), eq, lt (eq and lt from previous comparator)
// Return: {eq_i, lt_i}
function Bit#(2) cmp(Bit#(1) a, Bit#(1) b, Bit#(1) eq, Bit#(1) lt);
    return {eq & ~(a ^ b), lt | (eq & (~a & b))};
endfunction

// Description: unsigned 32-bit less-than comparator
// Arguments: a, b unsigned 32-bit values
// Return: 1 if a < b
function Bit#(1) ltu32(Bit#(32) a, Bit#(32) b);
    Bit#(1) eq = 1;
    Bit#(1) lt = 0;
    for (Integer i = 0; i < 32; i = i + 1) begin
        Bit#(2) res = cmp(a[31-i], b[31-i], eq, lt);
        eq = res[1];
        lt = res[0];
    end
    return lt;
endfunction

// Description: Signed/Unsigned 32-bit less-than comparator
// Arguments: a b (32-bit values); isSigned (signed comparator when 1, unsigned otherwise)
// Return: 1 if a < b
function Bit#(1) lt32(Bit#(32) a, Bit#(32) b, Bit#(1) isSigned);
    Bit#(1) ax = isSigned & a[31];
    Bit#(1) bx = isSigned & b[31];

    Bit#(1) sigdif = ax^bx;

    return (sigdif & ax) | (~sigdif & ltu32(a, b));
endfunction

// Description: one-bit full adder
// Arguments: a, b, carry in
// Return: {carry out, sum}
function Bit#(2) fullAdder(Bit#(1) a, Bit#(1) b, Bit#(1) carryIn);
    Bit#(1) s1 = a ^ b;
    Bit#(1) c1 = a & b;

    return {c1 | (carryIn & s1), s1^carryIn};
endfunction

// Description: n-bit ripple-carry adder with a carry-in
// Arguments: a, b, carryIn
// Return: sum of a, b, and carryIn
function Bit#(n) rca#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n) ret = 0;
    for (Integer i = 0; i < n; i = i + 1) begin
        Bit#(2) res = fullAdder(a[i], b[i], carryIn);
        ret[i] = res[0];
        carryIn = res[1];
    end

    return ret;
endfunction

// Description: n-bit ripple-carry adder/subractor
// Arguments: a, b (n-bit operands); isSub (1 => subtract, 0 => add)
// Return: isSub == 0 ? a + b : a - b
function Bit#(n) addSub#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) isSub);
    return fastAdd#(n)(a, isSub==1?~b:b, isSub);
endfunction


// Alu Functions:
// Add: 32-bit Addition         (a + b)
// Sub: 32-bit Subtraction      (a - b)
// And: 32-bit Bitwise And      (a & b)
// Or: 32-bit Bitwise Or        (a | b)
// Xor: 32-bit Bitwise Xor      (a ^ b)
// Slt: Set less than           (a <u b ? 1 : 0)
// Sltu: Set less than unsigned (a <s b ? 1:0)
// Sll: Left logic shfit        (a << b)
// Srl: Right logic shift       (a >>u b)
// Sra: Right arithmetic shift  (a >>s b)
typedef enum {Add, Sub, And, Or, Xor, Slt, Sltu, Sll, Srl, Sra} AluFunc;

// Description: Arithmetic Logic Unit (ALU)
// Arguments: a, operand a; b, operand b; func, ALU operation
// Return: output of ALU
function Bit#(32) alu(Bit#(32) a, Bit#(32) b, AluFunc func);
    // preform operations
    Bit#(32) add = addSub#(32)(a, b, func==Sub?1:0);
    Bit#(32) lt = zeroExtend(lt32(a, b, func==Slt?1:0));
    Bit#(32) sft = sft32(a, b[4:0], func==Sll?LeftShift:(func==Srl?LogicalRightShift:ArithmeticRightShift));

    Bit#(32) ret = (func==And?(a&b):0) | (func==Or?(a|b):0) | (func==Xor?(a^b):0);
    ret = ret | ((func==Add||func==Sub)?add:0);
    ret = ret | ((func==Slt||func==Sltu)?lt:0);
    ret = ret | ((func==Sll||func==Srl||func==Sra)?sft:0);
    return ret;
endfunction


// kill = 00
// propegate = 01
// generate = 10
function Bit#(2) fdot(Bit#(2) a, Bit#(2) b);
    // f dot g
    // propegate only when both are propegate
    // generate if both are generate
    // gen, prop is gen
    return {(a[0] & b[1]) | a[1], a[0] & b[0]};
endfunction

// Description: N-bit fast adder with a carry-in (Design Exercise)
// Arguments: a, b, carryIn
// Return: sum of a, b, and carryIn
function Bit#(n) fastAdd#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n) prop = a ^ b;
    Bit#(n) gen = a & b;
    
    for (Integer s = 1; s < n; s = s<<1) begin
        Bit#(n) tprop = prop;
        Bit#(n) tgen = gen;

        for (Integer i = s; i < n; i = i + 1) begin
            Bit#(2) res = fdot({tgen[i], tprop[i]}, {tgen[i-s], tprop[i-s]});
            gen[i] = res[1];
            prop[i] = res[0];
        end
    end

    Bit#(n) carry = zeroExtend(carryIn);
    for (Integer i = 1; i < n; i = i + 1) begin
        carry[i] = gen[i-1] | (prop[i-1] & carryIn);
    end

    return a^b^carry;
endfunction
