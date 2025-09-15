import ProcTypes;

////////////////////////////////////////////////////////////////////////////////////////////
/// The following are relevant types and constants for the decoder, copied from ProcTypes.ms
////////////////////////////////////////////////////////////////////////////////////////////
// typedef enum {OP, OPIMM, BRANCH, LUI, JAL, JALR, LOAD, STORE, AUIPC, Unsupported} IType;
// // Branch function enumeration
// typedef enum {Eq, Neq, Lt, Ltu, Ge, Geu} BrFunc;
// // Load/Store function enumeration
// typedef enum { Lw, Lh, Lhu, Lb, Lbu, Sw, Sh, Sb } MemFunc;

// typedef struct {
//     IType iType;
//     AluFunc aluFunc;
//     BrFunc brFunc;
//     MemFunc memFunc;
//     Maybe#(RIndx) dst;
//     RIndx src1;
//     RIndx src2;
//     Word imm;
// } DecodedInst;

// // Opcode
// Bit#(7) opOpImm  = 7'b0010011;
// Bit#(7) opOp     = 7'b0110011;
// Bit#(7) opLui    = 7'b0110111;
// Bit#(7) opJal    = 7'b1101111;
// Bit#(7) opJalr   = 7'b1100111;
// Bit#(7) opBranch = 7'b1100011;
// Bit#(7) opLoad   = 7'b0000011;
// Bit#(7) opStore  = 7'b0100011;
// Bit#(7) opAuipc  = 7'b0010111;

// // funct3 - ALU
// Bit#(3) fnADD   = 3'b000;
// Bit#(3) fnSLL   = 3'b001;
// Bit#(3) fnSLT   = 3'b010;
// Bit#(3) fnSLTU  = 3'b011;
// Bit#(3) fnXOR   = 3'b100;
// Bit#(3) fnSR    = 3'b101;
// Bit#(3) fnOR    = 3'b110;
// Bit#(3) fnAND   = 3'b111;
// // funct3 - Branch
// Bit#(3) fnBEQ   = 3'b000;
// Bit#(3) fnBNE   = 3'b001;
// Bit#(3) fnBLT   = 3'b100;
// Bit#(3) fnBGE   = 3'b101;
// Bit#(3) fnBLTU  = 3'b110;
// Bit#(3) fnBGEU  = 3'b111;
// // funct3 - Load
// Bit#(3) fnLW    = 3'b010;
// Bit#(3) fnLB    = 3'b000;
// Bit#(3) fnLH    = 3'b001;
// Bit#(3) fnLBU   = 3'b100;
// Bit#(3) fnLHU   = 3'b101;
// // funct3 - Store
// Bit#(3) fnSW    = 3'b010;
// Bit#(3) fnSB    = 3'b000;
// Bit#(3) fnSH    = 3'b001;
// // funct3 - JALR
// Bit#(3) fnJALR  = 3'b000;

function DecodedInst decode(Bit#(32) inst);
    let opcode = inst[6:0];
    let funct3 = inst[14:12];
    let funct7 = inst[31:25];
    let dst    = inst[11:7];
    let src1   = inst[19:15];
    let src2   = inst[24:20];

    Maybe#(RIndx) validDst = Valid(dst);
    Maybe#(RIndx) dDst = Invalid;
    RIndx dSrc = 5'b0;

    Word immD32 = signExtend(1'b0);

    Bit#(12) immB = { inst[31], inst[7], inst[30:25], inst[11:8] };
    Word immB32 = signExtend({ immB, 1'b0 });

    Bit#(20) immU = inst[31:12];
    Word immU32 = signExtend({ immU, 12'b0});

    Bit#(12) immI = inst[31:20];
    Word immI32 = signExtend(immI);

    Bit#(20) immJ = {inst[31], inst[19:12], inst[20], inst[30:21]};
    Word immJ32 = signExtend({ immJ, 1'b0 });

    Bit#(12) immS = {inst[31:25], inst[11:7]};
    Word immS32 = signExtend(immS);

    DecodedInst dInst = unpack(0);
    dInst.iType = Unsupported;

    case (opcode)
        opAuipc: begin
            dInst = DecodedInst {iType: AUIPC, dst: validDst, src1: dSrc, src2: dSrc, imm: immU32, brFunc: ?, aluFunc: ?, memFunc : ?};
        end
        opLui: begin
            dInst = DecodedInst {iType: LUI, dst: validDst, src1: ?, src2: ?, imm: immU32, brFunc: ?, aluFunc: ?, memFunc : ?};
        end

        opOpImm: begin
            dInst.iType = OPIMM;
            dInst.src1  = src1;
            dInst.imm   = immI32;
            dInst.dst   = validDst;

            case (funct3)
                fnAND : dInst.aluFunc = And;
                fnOR  : dInst.aluFunc = Or;
                fnXOR : dInst.aluFunc = Xor;
                fnADD : dInst.aluFunc = Add;
                fnSLT : dInst.aluFunc = Slt;
                fnSLTU: dInst.aluFunc = Sltu;
                fnSLL : case (funct7)
                    7'b0000000: dInst.aluFunc = Sll;
                    default:    dInst.iType = Unsupported;
                endcase
                fnSR  : case (funct7)
                    7'b0000000: dInst.aluFunc = Srl;
                    7'b0100000: dInst.aluFunc = Sra;
                    default:    dInst.iType = Unsupported;
                endcase
                default: dInst.iType = Unsupported;
            endcase
        end
        opOp: begin
            dInst.iType = OP;
            dInst.src1  = src1;
            dInst.src2  = src2;
            dInst.dst   = validDst;

            case (funct3)
                fnAND : case (funct7)
                    7'b0000000: dInst.aluFunc = And;
                    default:    dInst.iType = Unsupported;
                endcase
                fnOR  : case (funct7)
                    7'b0000000: dInst.aluFunc = Or;
                    default:    dInst.iType = Unsupported;
                endcase
                fnXOR : case (funct7)
                    7'b0000000: dInst.aluFunc = Xor;
                    default:    dInst.iType = Unsupported;
                endcase
                fnADD : case (funct7)
                    7'b0000000: dInst.aluFunc = Add;
                    7'b0100000: dInst.aluFunc = Sub;
                    default:    dInst.iType = Unsupported;
                endcase
                fnSLT : case (funct7)
                    7'b0000000: dInst.aluFunc = Slt;
                    default:    dInst.iType = Unsupported;
                endcase
                fnSLTU: case (funct7)
                    7'b0000000: dInst.aluFunc = Sltu;
                    default:    dInst.iType = Unsupported;
                endcase
                fnSLL : case (funct7)
                    7'b0000000: dInst.aluFunc = Sll;
                    default:    dInst.iType = Unsupported;
                endcase
                fnSR  : case (funct7)
                    7'b0000000: dInst.aluFunc = Srl;
                    7'b0100000: dInst.aluFunc = Sra;
                    default:    dInst.iType = Unsupported;
                endcase
                default: dInst.iType = Unsupported;
            endcase
        end
        opBranch: begin
            dInst.iType = BRANCH;
            dInst.src1  = src1;
            dInst.src2  = src2;
            dInst.imm   = immB32;

            case (funct3)
                fnBEQ: dInst.brFunc = Eq;
                fnBNE: dInst.brFunc = Neq;
                fnBLT: dInst.brFunc = Lt;
                fnBGE: dInst.brFunc = Ge;
                fnBLTU: dInst.brFunc = Ltu;
                fnBGEU: dInst.brFunc = Geu;
                default: dInst.iType = Unsupported;
            endcase
        end
        opJal: begin
            dInst.iType = JAL;
            dInst.imm   = immJ32;
            dInst.dst   = validDst;
        end
        opLoad: begin
            dInst.iType = LOAD;
            dInst.src1  = src1;
            dInst.imm   = immI32;
            dInst.dst   = validDst;

            case (funct3)
                fnLB: dInst.memFunc = Lb;
                fnLH: dInst.memFunc = Lh;
                fnLW: dInst.memFunc = Lw;
                fnLBU: dInst.memFunc = Lbu;
                fnLHU: dInst.memFunc = Lhu;
                default: dInst.iType = Unsupported;
            endcase
        end
        opStore: begin
            dInst.iType = STORE;
            dInst.src1  = src1;
            dInst.src2  = src2;
            dInst.imm   = immS32;

            case (funct3)
                fnSB: dInst.memFunc = Sb;
                fnSH: dInst.memFunc = Sh;
                fnSW: dInst.memFunc = Sw;
                default: dInst.iType = Unsupported;
            endcase
        end
        opJalr: begin
            dInst.src1  = src1;
            dInst.imm   = immI32;
            dInst.dst   = validDst;

            case (funct3)
                fnJALR: dInst.iType = JALR;
                default: dInst.iType = Unsupported;
            endcase
        end
    endcase

    return dInst;
endfunction
