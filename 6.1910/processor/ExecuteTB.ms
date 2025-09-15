import ProcTypes;
import Execute;
import ALU;

/*typedef struct {
    Bit#(32) word;
    IType iType;
    Maybe#(AluFunc) aluFunc;
    Maybe#(BrFunc) brFunc;
    Maybe#(memFunc) memFunc;
    Maybe#(Maybe#(RIndx)) dst;
    Maybe#(RIndx) src1;
    Maybe#(RIndx) src2;
    Maybe#(Word) imm;
} DecodedInstSpec;*/
typedef struct{
    DecodedInst dInst;
    Bit#(32) rVal1;
    Bit#(32) rVal2;
    Bit#(32) pc;
    ExecInst eInst;
    Bool checkData;
    Bool checkAddr;
    Bool checkLoadFunc;
    Bool checkStoreFunc;
} ExecInstSpec;
/*
Vector#(10, DecodedInstSpec) tests = {
endfunction
};
*/

function Maybe#(RIndx) vDst(Bit#(5) index) = Valid(index);

Maybe#(Maybe#(RIndx)) noDst = Valid(Invalid);


module ExecuteTB;
    Reg#(Bit#(9)) cycle(0);
    Reg#(IType) lastIType(AUIPC);
    Reg#(Bit#(9)) iTypeCount(0);
    rule test;
        
        Integer numTests = 79;
        Vector #(numTests, ExecInstSpec ) tests;
        Integer test_counter = 0;
        
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: AUIPC, aluFunc:?, brFunc:?, dst:vDst(0), src1:?, src2:? , imm: 'h00001000, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: AUIPC,dst: vDst(0), data: 'h1044, addr: ?, nextPc: 'h48, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: AUIPC, aluFunc:?, brFunc:?, dst:vDst(1), src1:?, src2:? , imm: 'hfffff000, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1000,
            eInst: ExecInst{iType: AUIPC,dst: vDst(1), data: 'h0, addr: ?, nextPc: 'h1004, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: AUIPC, aluFunc:?, brFunc:?, dst:vDst(31), src1:?, src2:? , imm: 'h12345000, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: AUIPC,dst: vDst(31), data: 'h12346234, addr: ?, nextPc: 'h1238, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(1), src1:?, src2:? , imm: 'h00001000, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: LUI, dst: vDst(1), data: 'h000001000, addr: ?, nextPc: 'h48, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: 'hDEADB000, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'hFC,
            eInst: ExecInst{iType: LUI, dst: vDst(12), data: 'hDEADB000, addr: ?, nextPc: 'h100, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: 'hBDEAD000, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: LUI, dst: vDst(23), data: 'hBDEAD000, addr: ?, nextPc: 'h1238, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(0), src1:?, src2:? , imm: 'hBDEAD000, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: LUI, dst: vDst(0), data: 'hBDEAD000, addr: ?, nextPc: 'h1238, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Add, brFunc:?, dst: vDst(1), src1:?, src2:? , imm: 'h03, memFunc : ?},
            rVal1: 'h10,
            rVal2: ?,
            pc: 'h124,
            eInst: ExecInst{iType: OPIMM, dst: vDst(1), data: 'h13, addr: ?, nextPc: 'h128, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Add, brFunc:?, dst: vDst(10), src1:?, src2:? , imm: -2, memFunc : ?},
            rVal1: 'h205,
            rVal2: ?,
            pc: 'h320,
            eInst: ExecInst{iType: OPIMM, dst: vDst(10), data: 'h203, addr: ?, nextPc: 'h324, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Add, brFunc:?, dst: vDst(27), src1:?, src2:? , imm: 'h281, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(27), data: 'h47E3, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:And, brFunc:?, dst: vDst(10), src1:?, src2:? , imm: 'h281, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(10), data: 'h0, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:And, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: 'hDEADBEEF, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'hBEEF, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Or, brFunc:?, dst: vDst(10), src1:?, src2:? , imm: 'h253, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(10), data: 'h4773, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Or, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: 'hDEADBEEF, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'hDEADFFFF, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Xor, brFunc:?, dst: vDst(17), src1:?, src2:? , imm: 'h253, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(17), data: 'h4731, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Xor, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: 'hDEADBEEF, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'hDEAD4110, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Sll, brFunc:?, dst: vDst(17), src1:?, src2:? , imm: 'h1, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(17), data: 'h8AC4, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Sll, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: 'h3, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'h7FFF8, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Sra, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: 'h1, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Sra, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: 'h2, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'hFFFFFFC0, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Srl, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: 'h1, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Srl, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: 'h2, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h3FFFFFC0, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Slt, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: 'h1, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Slt, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: 'h2, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Sltu, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: 'h1, memFunc : ?},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Sltu, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: 'h2, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h0, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };        
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OPIMM, aluFunc:Sltu, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: 'hFFFFFFFF, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Add, brFunc:?, dst: vDst(1), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h10,
            rVal2: 'h03,
            pc: 'h124,
            eInst: ExecInst{iType: OP, dst: vDst(1), data: 'h13, addr: ?, nextPc: 'h128, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sub, brFunc:?, dst: vDst(10), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h205,
            rVal2: 'h2,
            pc: 'h320,
            eInst: ExecInst{iType: OP, dst: vDst(10), data: 'h203, addr: ?, nextPc: 'h324, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Add, brFunc:?, dst: vDst(27), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h281,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(27), data: 'h47E3, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:And, brFunc:?, dst: vDst(10), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h281,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(10), data: 'h0, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:And, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: 'hDEADBEEF,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'hBEEF, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Or, brFunc:?, dst: vDst(10), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h253,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(10), data: 'h4773, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Or, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: 'hDEADBEEF,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'hDEADFFFF, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Xor, brFunc:?, dst: vDst(17), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h253,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(17), data: 'h4731, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Xor, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: 'hDEADBEEF,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'hDEAD4110, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sll, brFunc:?, dst: vDst(17), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h1001,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(17), data: 'h8AC4, addr: ?, nextPc: 'h34C, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sll, brFunc:?, dst: vDst(5), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFF,
            rVal2: 'h3,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'h7FFF8, addr: ?, nextPc: 'h18, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sra, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sra, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'hDEADB002,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'hFFFFFFC0, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Srl, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Srl, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'h2,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h3FFFFFC0, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Slt, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Slt, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'h2,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sltu, brFunc:?, dst: vDst(12), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sltu, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'h2,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h0, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };        
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: OP, aluFunc:Sltu, brFunc:?, dst: vDst(23), src1:?, src2:? , imm: ?, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Eq, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Eq, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h12F4, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Eq, dst:Invalid, src1:?, src2:? , imm: -20, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Neq, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'hFFFFFF00,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Neq, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h120C, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Neq, dst:Invalid, src1:?, src2:? , imm: -20, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428371,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Lt, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Lt, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h120C, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Lt, dst:Invalid, src1:?, src2:? , imm: -20, memFunc : ?},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ge, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'hEC, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ge, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h12F4, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ge, dst:Invalid, src1:?, src2:? , imm: -20, memFunc : ?},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h48, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ltu, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'hEC, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ltu, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h120C, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ltu, dst:Invalid, src1:?, src2:? , imm: -20, memFunc : ?},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Geu, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Geu, dst:Invalid, src1:?, src2:? , imm: 'hEC, memFunc : ?},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h12F4, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Geu, dst:Invalid, src1:?, src2:? , imm: -20, memFunc : ?},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h48, memFunc : ?},
            checkData: False,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: JAL, aluFunc:?, brFunc:?, dst:vDst(0), src1:?, src2:? , imm: -20, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: JAL, dst: vDst(0), data: 'h48, addr: ?, nextPc: 'h30, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: JAL, aluFunc:?, brFunc:?, dst:vDst(1), src1:?, src2:? , imm: 20, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: JAL, dst: vDst(1), data: 'h4, addr: ?, nextPc: 'h14, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: JAL, aluFunc:?, brFunc:?, dst:vDst(31), src1:?, src2:? , imm: 'hFFC, memFunc : ?},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: JAL, dst: vDst(31), data: 'h1238, addr: ?, nextPc: 'h2230, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(12), src1:?, src2:? , imm: 'h234, memFunc : Lw},
            rVal1: 'h1000,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: LOAD,dst: vDst(12), data: ?, addr: 'h1234, nextPc: 'h48, memFunc : Lw},
            checkData: False,
            checkAddr: True,
            checkLoadFunc : True,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(0), src1:?, src2:? , imm: -20, memFunc : Lb},
            rVal1: 'h2014,
            rVal2: ?,
            pc: 'h124,
            eInst: ExecInst{iType: LOAD,dst: vDst(0), data: ?, addr: 'h2000, nextPc: 'h128, memFunc : Lb},
            checkData: False,
            checkAddr: True,
            checkLoadFunc : True,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(18), src1:?, src2:? , imm: 'h234, memFunc : Lh},
            rVal1: 'h0FAD2020,
            rVal2: ?,
            pc: 'h500,
            eInst: ExecInst{iType: LOAD,dst: vDst(18), data: ?, addr: 'h0FAD2254, nextPc: 'h504, memFunc : Lh},
            checkData: False,
            checkAddr: True,
            checkLoadFunc : True,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(18), src1:?, src2:? , imm: 'h234, memFunc : Lhu},
            rVal1: 'h0FAD2020,
            rVal2: ?,
            pc: 'h124,
            eInst: ExecInst{iType: LOAD,dst: vDst(18), data: ?, addr: 'h0FAD2254, nextPc: 'h128, memFunc : Lhu},
            checkData: False,
            checkAddr: True,
            checkLoadFunc : True,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(18), src1:?, src2:? , imm: 'h238, memFunc : Lbu},
            rVal1: 'h0FAD2020,
            rVal2: ?,
            pc: 'h500,
            eInst: ExecInst{iType: LOAD,dst: vDst(18), data: ?, addr: 'h0FAD2258, nextPc: 'h504, memFunc : Lbu},
            checkData: False,
            checkAddr: True,
            checkLoadFunc : True,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: STORE, aluFunc:?, brFunc:?, dst:Invalid, src1:?, src2:? , imm: 'h234, memFunc : Sw},
            rVal1: 'h0FAD2020,
            rVal2: 'hB001234,
            pc: 'h500,
            eInst: ExecInst{iType: STORE,dst: Invalid, data: 'hB001234, addr: 'h0FAD2254, nextPc: 'h504, memFunc : Sw},
            checkData: True,
            checkAddr: True,
            checkLoadFunc : False,
            checkStoreFunc: True
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: STORE, aluFunc:?, brFunc:?, dst:Invalid, src1:?, src2:? , imm: -32, memFunc : Sb},
            rVal1: 'h0FAD2020,
            rVal2: 'hB001234,
            pc: 'h10C,
            eInst: ExecInst{iType: STORE,dst: Invalid, data: 'hB001234, addr: 'h0FAD2000, nextPc: 'h110, memFunc : Sb},
            checkData: True,
            checkAddr: True,
            checkLoadFunc : False,
            checkStoreFunc: True
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: STORE, aluFunc:?, brFunc:?, dst:Invalid, src1:?, src2:? , imm: 'h0, memFunc : Sh},
            rVal1: 'h1234,
            rVal2: 'h1235,
            pc: 'h428,
            eInst: ExecInst{iType: STORE,dst: Invalid, data: 'h1235, addr: 'h1234, nextPc: 'h42C, memFunc : Sh},
            checkData: True,
            checkAddr: True,
            checkLoadFunc : False,
            checkStoreFunc: True
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: JALR, aluFunc:?, brFunc:?, dst:vDst(0), src1:?, src2:? , imm: -19, memFunc : ?},
            rVal1: 'h1000,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: JALR, dst: vDst(0), data: 'h48, addr: ?, nextPc: 'hFEC, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: JALR, aluFunc:?, brFunc:?, dst:vDst(1), src1:?, src2:? , imm: 'h20, memFunc : ?},
            rVal1: 'h1234,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: JALR, dst: vDst(1), data: 'h4, addr: ?, nextPc: 'h1254, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        test_counter = test_counter + 1;
        tests[test_counter] = ExecInstSpec{
            dInst: DecodedInst{iType: JALR, aluFunc:?, brFunc:?, dst:vDst(31), src1:?, src2:? , imm: 'h7FC, memFunc : ?},
            rVal1: 'h1234000,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: JALR, dst: vDst(31), data: 'h1238, addr: ?, nextPc: 'h12347FC, memFunc : ?},
            checkData: True,
            checkAddr: False,
            checkLoadFunc : False,
            checkStoreFunc: False
        };
        if (cycle == numTests) begin
            $display("Passed Executing %d tests of iType ", iTypeCount, fshow(lastIType));
            // Last Test
            DecodedInst dInst = unpack(0);
            dInst.iType=Unsupported;
            ExecInst resultUn = execute(dInst,1234,5678,1200);
            if(resultUn.iType==Unsupported) begin
                $display("Passed Executing   1 tests of iType ",fshow(Unsupported));
                $display("DP.Execute: PASSED");
            end
            else begin
                $display("Failed Execute function");
                $display("Input:");
                $display("Decoded Instruction: ", fshow(dInst));
                $display("Value 1            : ", fshow(1234));
                $display("Value 2            : ", fshow(5678));
                $display("PC                 : ", fshow(1200));
                $display("Your Execute Result: ", fshow(resultUn));
                $display("FAILED: Expect iType to be Unsupported");
            end
            $finish;
            
        end

        let spec = tests[cycle];
        ExecInst result = execute(spec.dInst,spec.rVal1,spec.rVal2,spec.pc);
        ExecInst expected = spec.eInst;
        if(expected.iType!=result.iType ||
            expected.dst!=result.dst || 
            (spec.checkData && expected.data!=result.data) || 
            (spec.checkAddr && expected.addr!=result.addr) || 
            (spec.checkLoadFunc && expected.memFunc!=result.memFunc) || 
            (spec.checkStoreFunc && expected.memFunc!=result.memFunc) || 
            expected.nextPc!=result.nextPc) begin
            $display("Failed Execute function");
            $display("Input:");
            $display("Decoded Instruction: ", fshow(spec.dInst));
            $display("Value 1            : ", fshow(spec.rVal1));
            $display("Value 2            : ", fshow(spec.rVal2));
            $display("PC                 : ", fshow(spec.pc));
            if(!spec.checkData) begin
                $display("Ignoring Data field");
                result.data='hDEADBEEF;
                expected.data='hDEADBEEF;
            end
            if(!spec.checkAddr) begin
                $display("Ignoring Address field");
                result.addr='hDEADBEEF;
                expected.addr='hDEADBEEF;
            end
            if(!spec.checkLoadFunc && !spec.checkStoreFunc) begin
                $display("Ignoring memfunc Field");
                result.memFunc = Lw;
                expected.memFunc = Lw;
            end
            $display("Your Execute Result: ", fshow(result));
            $display("Expected Result    : ", fshow(expected));

            $display("FAILED");
            $finish;
        end
        if (lastIType == spec.eInst.iType) begin
            iTypeCount <= iTypeCount + 1;
        end else begin
	    $display("Passed Executing %d tests of iType ",iTypeCount,fshow(lastIType));
            iTypeCount <= 1;
        end
        lastIType <= spec.eInst.iType;
        cycle <= cycle + 1;
    endrule
endmodule
