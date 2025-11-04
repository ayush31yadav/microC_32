`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2025 19:49:14
// Design Name: 
// Module Name: main32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module iJump (
    input jmpEnable, misc, // misc for unconditional jump, jmpEnable = 111 conditional jump instructions
    input [31:0] inst,
    input [3:0] flag,
    output [31:0] newPC,
    output jumpValid
);
    reg outMux;
    
    always @(*) begin
        case (inst[28:26])
            3'b000: outMux <= flag[3];
            3'b001: outMux <= ~flag[3];
            
            3'b010: outMux <= flag[1];
            3'b011: outMux <= ~flag[1];
            
            3'b100: outMux <= flag[0];
            3'b101: outMux <= flag[1] | flag[0];
            
            3'b110: outMux <= flag[2];
            3'b111: outMux <= flag[2] | flag[1];
        endcase
    end
    
    assign ucJmp = misc & ~(inst[28] | inst[27] | inst[26]);
    assign newPC = {16'h0000, inst[15:0]};
    assign jumpValid = (outMux & jmpEnable) | ucJmp;
endmodule

module opDecoder(
    input [31:0] inst,
    input clk,
    output [7:0] opType
);
    
    wire n2, n1, n0, i2, i1, i0;
    
    assign {i2, i1, i0} = inst[31:29];
    assign {n2, n1, n0} = {~i2, ~i1, ~i0};
    
    assign opType[0] = n2 & n1 & n0;
    assign opType[1] = n2 & n1 & i0;
    assign opType[2] = n2 & i1 & n0;
    assign opType[3] = n2 & i1 & i0;
    assign opType[4] = i2 & n1 & n0;
    assign opType[5] = i2 & n1 & i0;
    assign opType[6] = i2 & i1 & n0;
    assign opType[7] = i2 & i1 & i0;

endmodule


module Bin1 (
    input [31:0] R0, R1,
    input [2:0] spCode,
    output [31:0] res
);
    
    wire [31:0] a32, o32, x32, aox, neAox, naox, lastMux0;
    
    and32 A1 (
        .A(R0), .B(R1),
        .Y(a32)
    );
    or32 O1 (
        .A(R0), .B(R1),
        .Y(o32)
    );
    xor32 X1 (
        .A(R0), .B(R1),
        .Y(x32)
    );
    
    mux4_1_32 M1 (
        .X0(a32), .X1(o32), .X2(x32), .X3(R0),
        .select(spCode[1:0]),
        .Y(aox)
    );
    
    negate32 N1(
        .X(aox),
        .Y(neAox)
    );
    
    not32 N2 (
        .X(aox),
        .Y(naox)
    );
    
    mux2_1_32 M2 (
        .X0(aox), .X1(neAox),
        .select(spCode[1] & spCode[0]),
        .Y(lastMux0)
    );
    
    mux2_1_32 M3 (
        .X0(lastMux0), .X1(naox),
        .select(spCode[2]),
        .Y(res)
    );

endmodule

module Bin2 (
    input [31:0] R0, R1, //R0 = num, R1 = amt to rotate with
    input [2:0] spCode,
    output [31:0] res
);
    
    wire [31:0] L, R;

    lShift LS(
        .X(R0),
        .shiftAmt(R1[4:0]),
        .SR(spCode[1]), // shift = 0, ROTATE = 1
        .Y(L)
    );
    
    rShift RS(
        .X(R0),
        .shiftAmt(R1[4:0]),
        .SR(spCode[1]), // shift = 0, ROTATE = 1
        .LA(spCode[0]), // logical = 0, ARITHMETIC = 1
        .Y(R)
    );
    
    mux2_1_32 M1 (
        .X0(L), .X1(R),
        .select(spCode[2]),
        .Y(res)
   );

endmodule

module arithCmp (
    input [31:0] R0, R1,
    input [2:0] spCode,
    input cmp,
    output [31:0] Rd1, Rd2,
    output usMSB, sMSB
);
    
    wire ctrl, bit33;
    wire [31:0] addSubOut, mul1, mul0, divQ, divR, filteredR1;
    
    assign ctrl = spCode[1] | spCode[0] | cmp;
    
    addSub32 addSub(      // unsigned adder subtractor
        .A(R0), .B(R1),
        .control(ctrl), // 1 = SUB 0 = ADD
        .S(addSubOut),
        .Co(bit33)
    );
    
    assign usMSB = ~bit33;
    assign sMSB = addSubOut[31];
    
    intMul multiplier(
        .A(R0), .B(R1),
        .us(spCode[2]), // 0 if input = unsigned, 1 if input = signed
        .OH(mul1), .OL(mul0)
    );
    
    intDiv divider(
        .A(R0), .B(R1),
        .us(spCode[2]),
        .Q(divQ), .R(divR)
    );
    
    mux2_1_32 M1 (
        .X0(mul1), .X1(divR),
        .select(spCode[0]),
        .Y(Rd2)
    );
    
    mux4_1_32 M2(
        .X0(addSubOut), .X1(addSubOut), .X2(mul0), .X3(divQ),
        .select(spCode[1:0]),
        .Y(Rd1)
    );
    
endmodule

module writes(
    input [31:0] regVal,
    input [15:0] inVal,
    input [2:0] spCode,
    output [31:0] newVal
);

    mux2_1_32 M1 (
        .X0({regVal[31:16], inVal}), .X1({inVal, regVal[15:0]}),
        .select(spCode[0]),
        .Y(newVal)
    );

endmodule

module loadStore #(
    parameter addWidth = 8
) (
    input [31:0] memAddress, R1val, memReadVal,
    output [addWidth - 1:0] memReadAdd,
    output [31:0] R0val, memWriteVal,
    output [addWidth - 1:0] memWriteAdd
);
    
    assign memReadAdd = memAddress[addWidth-1:0];
    assign R0val = memReadVal;
    assign memWriteAdd = memAddress[addWidth-1:0];
    assign memWriteVal = R1val;

endmodule

module comparator(
    input [31:0] Rd1, Rd2,
    input [2:0] spCode, inst,
    input sMSB, usMSB,
    output [3:0] flag
);
    wire iM, finalV2, finalOR, MSBbit;
    wor v1, v2;
    
    assign iM = inst[2] & ~inst[1] & ~inst[0] & spCode[1] & ~spCode[0];
    assign isMul = iM;
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            assign v1 = Rd1[i];
            assign v2 = Rd2[i];
        end
    endgenerate
    
    assign finalV2 = v2 & iM;
    assign finalOR = v1 | finalV2;
    
    assign flag[3] = ~finalOR;
    assign flag[1] = ~finalOR;
    
    mux2_1_1 M1 (
        .X0(sMSB), .X1(usMSB),
        .select(spCode[0]),
        .Y(MSBbit)
    );
    
    assign flag[2] = MSBbit;
    assign flag[0] = ~MSBbit;
    
endmodule


module main32 #(
    parameter ramDepth = 8
) (
    input rst, clk,
    input [3:0] rSelect,
    output [31:0] regOut, PCOut, instructOut,
    output [3:0] flagOut
);
   wire [3:0] flag; // 3 = Z, 2 = LT, 1 = EQ, 0 = GT, GT & LT = DIV0
   wire [31:0] inst;
   
   wire [7:0] hotInst;
   
   wire [31:0] setPC, readPC, nxtPC, incPC, jmpPC, writeB, readB;
   wire jmpValid, memWriteEnable, flagWriteEnable;
   wire [ramDepth-1:0] W_loc, R_loc;
   wire [3:0] newFlag;
   
   // register File
   wire [31:0] regWData0, regWData1, R1Read, R2Read;
   wire [4:0] regWAdd1;
   
   wire [31:0] val1, val2;
   wire [31:0] bin1Out, bin2Out, arithOut1, arithOut2;
   wire [31:0] writesOut;
   wire [31:0] loadRegVal;
   wire sMSB, usMSB, regWrite1enable;
   
   assign PCOut = readPC;
   assign instructOut = inst;
   assign flagOut = flag;
   
   reg4 Flag (
        .D(newFlag),
        .clk(clk), .enable(flagWriteEnable),
        .Q(flag)
    );
   
   reg32 PC ( 
        .D(setPC),
        .clk(clk), 
        .enable(1'b1),
        .Q(readPC)
   );
   
   mux2_1_32 M1 (
        .X0(nxtPC), .X1(32'h0000_0000),
        .select(rst),
        .Y(setPC)
   );
   
   add32 INC_PC(
        .A(readPC), .B(32'h0000_0001),
        .Ci(1'b0),
        .S(incPC)
    );
   
   mux2_1_32 M2 (
        .X0(incPC), .X1(jmpPC),
        .select(jmpValid),
        .Y(nxtPC)
   );
   
   iJump JMP (
        .jmpEnable(hotInst[7]),
        .misc(hotInst[3]),
        .inst(inst),
        .flag(flag),
        .newPC(jmpPC),
        .jumpValid(jmpValid)
    );
    
    opDecoder OD (
        .inst(inst),
        .clk(clk),
        .opType(hotInst)
    );
    
    assign flagWriteEnable = hotInst[4] | hotInst[2] | hotInst[1] | hotInst[0];
    assign regWAdd1[4] = hotInst[4] & inst[27]; // ARITH and MUL/DIV
    assign regWrite1enable = hotInst[0] | hotInst[1] | hotInst[4] | hotInst[6] | (hotInst[5] & ~inst[28]);
    assign regWData1 = arithOut2;
    
    add4 RPP (
        .A(inst[23:20]), .B(4'b0001),
        .Ci(1'b0),
        .S(regWAdd1[3:0])
    );
    
    regFile RF(
        .inp0(regWData0), .inp1(regWData1),
        .inSelect0({regWrite1enable, inst[23:20]}), .inSelect1(regWAdd1), // [4] is enable  1 : WRITE 0 : READ 
        .outSelect0(inst[19:16]), .outSelect1(inst[15:12]), .outSelect2(rSelect),
        .clk(clk),
        .out0(R1Read), .out1(R2Read), .out2(regOut)
    );
    
    mux4_1_32 M3 (
        .X0(R2Read), .X1(R2Read), .X2({16'h0000, inst[15:0]}), .X3({24'h0000_00, inst[15:8]}),
        .select(inst[25:24]),
        .Y(val2)
    );
    
    mux4_1_32 M4 (
        .X0(R1Read), .X1({16'h0000, inst[15:0]}), .X2(R1Read), .X3({24'h0000_00, inst[7:0]}),
        .select(inst[25:24]),
        .Y(val1)
    );
    
    Bin1 binary1 (
        .R0(val1), .R1(val2),
        .spCode(inst[28:26]),
        .res(bin1Out)
    );
    
    Bin2 binary2 (
        .R0(val1), .R1(val2),
        .spCode(inst[28:26]),
        .res(bin2Out)
    );
    
    arithCmp AC (
        .R0(val1), .R1(val2),
        .spCode(inst[28:26]),
        .cmp(hotInst[2]),
        .Rd1(arithOut1), .Rd2(arithOut2),
        .usMSB(usMSB), .sMSB(sMSB)
    );
    
    comparator comp(
        .Rd1(regWData0), .Rd2(arithOut2),
        .spCode(inst[28:26]), .inst(inst[31:29]),
        .sMSB(sMSB), .usMSB(usMSB),
        .flag(newFlag)
    );
    
    mux8_1_32 R0_combined (
        .X0(bin1Out), .X1(bin2Out), .X2(32'h0000_0000), .X3(32'h0000_0000),
        .X4(arithOut1), .X5(loadRegVal), .X6(writesOut), .X7(32'h0000_0000),
        .select(inst[31:29]),
        .Y(regWData0)
    );
    
    writes W (
        .regVal(val1),
        .inVal(inst[15:0]),
        .spCode(inst[28:26]),
        .newVal(writesOut)
    );
    
    mainRAM #(
    .addWidth(ramDepth)
    ) MR (
        .wEnable(memWriteEnable), .clk(clk),
        .WSelect(W_loc),
        .RSelect1(readPC[ramDepth-1:0]),
        .RSelect2(R_loc),
        .writeDB(writeB),
        .readDB1(inst),
        .readDB2(readB)
    );
    
    loadStore #(
        .addWidth(ramDepth)
    ) LS (
        .memAddress(val2), .R1val(val1), .memReadVal(readB),
        .memReadAdd(R_loc),
        .R0val(loadRegVal), .memWriteVal(writeB),
        .memWriteAdd(W_loc)
    );
       
endmodule
