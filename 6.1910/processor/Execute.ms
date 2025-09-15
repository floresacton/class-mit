import ProcTypes;

// ALU
// Imports your ALU from Lab 2
import ALU;

// Branch ALU
// BrFunc defined in ProcTypes.ms
function Bool aluBr(Word a, Word b, BrFunc brFunc);
    Bool res = case (brFunc)
        Eq:     (a == b);
        Neq:    (a != b);
        Lt:     signedLT(a, b); // Built-in signed comparison
        Ltu:    (a < b);
        Ge:     signedGE(a, b); // Built-in signed comparison
        Geu:    (a >= b);
        default: False;
    endcase;
    return res;
endfunction

// Execute function
// ExecInst defined in ProcTypes.ms
function ExecInst execute( DecodedInst dInst, Word rVal1, Word rVal2, Word pc );
    let imm = dInst.imm;
    let brFunc = dInst.brFunc;
    let aluFunc = dInst.aluFunc;
    let aluVal2 = dInst.iType == OPIMM ? imm : rVal2;

    Word pcp4 = pc + 4;
    Word pcpimm = pc + imm;

    Word data = case (dInst.iType)
        AUIPC:     pcpimm;
        LUI:       imm;
        OP, OPIMM: alu(rVal1, aluVal2, aluFunc);
        JAL, JALR: pcp4;
        STORE:     rVal2;
        default:   0;
    endcase;

    Word nextPcBranch = pcp4;
    case (dInst.brFunc)
        Eq: if (rVal1 == rVal2) nextPcBranch = pcpimm;
        Neq: if (rVal1 != rVal2) nextPcBranch = pcpimm;
        Lt: if (lt32(rVal1, rVal2, 1) == 1) nextPcBranch = pcpimm;
        Ge: if (lt32(rVal1, rVal2, 1) == 0) nextPcBranch = pcpimm;
        Ltu: if (lt32(rVal1, rVal2, 0) == 1) nextPcBranch = pcpimm;
        Geu: if (lt32(rVal1, rVal2, 0) == 0) nextPcBranch = pcpimm;
        default: nextPcBranch = pcp4;
    endcase

    Word addr = imm + rVal1;

    Word nextPc = case (dInst.iType)
        BRANCH: nextPcBranch;
        JAL:    pcpimm;
        JALR: addr & ~1;
        default: pcp4;
    endcase;


    return ExecInst{iType: dInst.iType, dst: dInst.dst, data: data, addr: addr, nextPc: nextPc, memFunc : dInst.memFunc};
endfunction
