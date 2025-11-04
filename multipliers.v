`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 21:03:10
// Design Name: 
// Module Name: multiplierBase
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

module multiplierBase(
    input [31:0] A, B,
    output [31:0] OH, OL
    );
    
    wire [31:0] prodArr [31:0];
    wire [30:0] carryBus;
    wire [31:0] sumArr [30:0];
    wire [64:0] finalProd;
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            and32M G1 (
                .A(A),
                .B(B[i]),
                .Y(prodArr[i])
            );
        end
    endgenerate
    
    generate
        for (genvar i = 0; i < 31; i = i + 1) begin
            if (i == 0) begin
                add32 G2 (
                    .A({0, prodArr[0][31:1]}),
                    .B(prodArr[1]),
                    .Ci(1'b0),
                    .S(sumArr[0]),
                    .Co(carryBus[0])
                );
            end else begin
                add32 G3 (
                    .A({carryBus[i-1], sumArr[i-1][31:1]}),
                    .B(prodArr[i+1]),
                    .Ci(1'b0),
                    .S(sumArr[i]),
                    .Co(carryBus[i])
                );
            end
        end
    endgenerate
    
    assign OL[0] = prodArr[0][0];
    assign OH = {carryBus[30] ,sumArr[30][31:1]};
    
    generate
        for (genvar i = 0; i < 31; i = i + 1) begin
            assign OL[i+1] = sumArr[i][0];
        end
    endgenerate
    
endmodule

module intMul(
    input [31:0] A, B,
    input us, // 0 if input = unsigned, 1 if input = signed
    output [31:0] OH, OL
);

    wire xBit, fMux;
    
    xor G1 (xBit, A[31], B[31]);
    and G2 (fMux, xBit, us);
    
    wire [31:0] mag1, mag2;
    wire [31:0] oM1, oM2;
    wire muxA, muxB;
    
    assign muxA = A[31] & us;
    assign muxB = B[31] & us;
    
    negate32 N1 (
        .X(A),
        .Y(mag1)
    );
    
    negate32 N2 (
        .X(B),
        .Y(mag2)
    );
    
    mux2_1_32 M1 (
        .X0(A),
        .X1(mag1),
        .select(muxA),
        .Y(oM1)
    );
    
    mux2_1_32 M2 (
        .X0(B),
        .X1(mag2),
        .select(muxB),
        .Y(oM2)
    );
    
    wire [31:0] OHm, OLm;
    
    multiplierBase MB (
        .A(oM1),
        .B(oM2),
        .OH(OHm),
        .OL(OLm)
    );
    
    wire [31:0] OHn, OLn;
    
    not32 NT1 (
        .X(OHm),
        .Y(OHn)
    );
    
    not32 NT2 (
        .X(OLm),
        .Y(OLn)
    );
    
    wire [31:0] OHn2, OLn2;
    wire t;
    
    add32 A1 (
        .A(OLn),
        .B(32'h0000_0001),
        .Ci(1'b0),
        .S(OLn2),
        .Co(t)
    );
    
    add32 A2 (
        .A(OHn),
        .B(32'h0000_0000),
        .Ci(t),
        .S(OHn2)
    );
    
    mux2_1_32 M5 (
        .X0(OHm),
        .X1(OHn2),
        .select(fMux),
        .Y(OH)
    );
    
    mux2_1_32 M6 (
        .X0(OLm),
        .X1(OLn2),
        .select(fMux),
        .Y(OL)
    );

endmodule
