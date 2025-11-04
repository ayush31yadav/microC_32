`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2025 12:15:56
// Design Name: 
// Module Name: addS
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

module add32(     // unsigned 32 bit adder
    input [31:0] A, B,
    input Ci,
    output [31:0] S,
    output Co
);

    wire [31:0] cBus;
    
    assign Co = cBus[31];

    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            if (i == 0) begin
                fullAdder FAi (
                    .A(A[i]),
                    .B(B[i]),
                    .Ci(Ci),
                    .S(S[i]),
                    .Co(cBus[i])
                );
            end else begin
                fullAdder FAi (
                    .A(A[i]),
                    .B(B[i]),
                    .Ci(cBus[i-1]),
                    .S(S[i]),
                    .Co(cBus[i])
                );
            end
        end
    endgenerate

endmodule

module add4(     // unsigned 4 bit adder
    input [3:0] A, B,
    input Ci,
    output [3:0] S,
    output Co
);

    wire [3:0] cBus;
    
    assign Co = cBus[3];

    generate
        for (genvar i = 0; i < 4; i = i + 1) begin
            if (i == 0) begin
                fullAdder FAi (
                    .A(A[i]),
                    .B(B[i]),
                    .Ci(Ci),
                    .S(S[i]),
                    .Co(cBus[i])
                );
            end else begin
                fullAdder FAi (
                    .A(A[i]),
                    .B(B[i]),
                    .Ci(cBus[i-1]),
                    .S(S[i]),
                    .Co(cBus[i])
                );
            end
        end
    endgenerate

endmodule

module addSub32(      // unsigned adder subtractor
    input [31:0] A, B,
    input control, // 1 = SUB 0 = ADD
    output [31:0] S,
    output Co
);

    wire [31:0] fB; // filtered B
    
    xor32A XA(
        .A(B),
        .B(control),
        .Y(fB)
    );
    
    add32 a32 (
        .Ci(control),
        .A(A),
        .B(fB),
        .S(S),
        .Co(Co)
    );
    
endmodule