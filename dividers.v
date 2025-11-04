`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2025 15:31:13
// Design Name: 
// Module Name: dividerCell
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


module dividerCell(
    input nxtBit,
    input [31:0] prevAns, invDivider,
    output Q,
    output [31:0] R
    );
    
    wire [31:0] subRes;
    wire muxCont;
    wire temp;
    
    add32 S1 (
        .A({prevAns[30:0], nxtBit}),
        .B(invDivider),
        .Ci(1'b1),
        .S(subRes),
        .Co(temp)
    );
    
    mux2_1_32 M1 (
        .X0(subRes),
        .X1({prevAns[30:0], nxtBit}),
        .select(subRes[31]),
        .Y(R)
    );
    
    assign Q = ~subRes[31];
    
endmodule

module division(
    input [31:0] A, B, prevR,
    output [31:0] Q, R
);

    wire [31:0] invB;
    wire t;
    wire [31:0] subArr [31:0];
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            not N (invB[i], B[i]);
        end
    endgenerate
    
    generate
        for (genvar i = 31; i >= 0; i = i - 1) begin
            if (i == 31) begin
                dividerCell dC1 (
                    .nxtBit(A[31]),
                    .prevAns(prevR),
                    .invDivider(invB),
                    .Q(Q[31]),
                    .R(subArr[31])
                );
            end else begin
                dividerCell dC2 (
                    .nxtBit(A[i]),
                    .prevAns(subArr[i+1]),
                    .invDivider(invB),
                    .Q(Q[i]),
                    .R(subArr[i])
                );
            end
        end
    endgenerate
    
    assign R = subArr[31];
    
endmodule

module intDiv(
    input [31:0] A, B,
    input us,
    output [31:0] Q, R
);

    wire fSign;
    
    xor G1 (fSign, A[31], B[31]);
    
    wire [31:0] absA, absB, negA, negB, baseQ, baseR;
    wire muxA, muxB;
    
    negate32 N1 (
        .X(A),
        .Y(negA)
    );
    
    negate32 N2 (
        .X(B),
        .Y(negB)
    );
    
    assign muxA = A[31] & us;
    assign muxB = B[31] & us;
    
    mux2_1_32 M1 (
        .X0(A),
        .X1(negA),
        .select(muxA),
        .Y(absA)
    );
    
    mux2_1_32 M2 (
        .X0(B),
        .X1(negB),
        .select(muxB),
        .Y(absB)
    );
    
    division DMain (
        .A(absA), 
        .B(absB), 
        .prevR(32'b0000_0000),
        .Q(baseQ),
        .R(baseR)
    ); 
    
    wire [31:0] negQ, negR;
    
    negate32 N3 (
        .X(baseQ),
        .Y(negQ)
    );
    
    negate32 N4 (
        .X(baseR),
        .Y(negR)
    );
    
    wire fMux;
    
    and (fMux, us, fSign);
    
    mux2_1_32 M5 (
        .X0(baseQ),
        .X1(negQ),
        .select(fMux),
        .Y(Q)
    );
    
    mux2_1_32 M6 (
        .X0(baseR),
        .X1(negR),
        .select(fMux),
        .Y(R)
    );

endmodule
