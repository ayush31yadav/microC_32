`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2025 20:39:50
// Design Name: 
// Module Name: reg32
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

module d_FF4(
    input [3:0] D,
    input clk,
    output reg [3:0] Q
    );
    
    always @(posedge clk) begin
        Q <= D;
    end
    
endmodule

module reg4(
    input [3:0] D,
    input clk, enable,
    output [3:0] Q
);
    
    wire [3:0] out, in;
    
    mux2_1_4 M1 (
        .X0(out),
        .X1(D),
        .select(enable),
        .Y(in)
    );
    
    d_FF4 R_main (
        .D(in),
        .clk(clk),
        .Q(out)
    );
    
    assign Q = out;
    
endmodule


module d_FF(
    input [31:0] D,
    input clk,
    output reg [31:0] Q
    );
    
    always @(posedge clk) begin
        Q <= D;
    end
    
endmodule

module reg32(
    input [31:0] D,
    input clk, enable,
    output [31:0] Q
);
    
    wire [31:0] out, in;
    
    mux2_1_32 M1 (
        .X0(out),
        .X1(D),
        .select(enable),
        .Y(in)
    );
    
    d_FF R_main (
        .D(in),
        .clk(clk),
        .Q(out)
    );
    
    assign Q = out;
    
endmodule

module regCell(
    input [31:0] D0, D1,
    input S0, S1, clk,
    output [31:0] Q
);
    
    wire enable;
    wire [31:0] writeData;
    
    assign enable = S0 ^ S1;
    
    mux2_1_32 M1(
        .X0(D0), .X1(D1),
        .select(S1),
        .Y(writeData)
    );
    
    reg32 R32 (
        .D(writeData),
        .clk(clk), .enable(enable),
        .Q(Q)
    );
    
endmodule

module regFile(
    input [31:0] inp0, inp1,
    input [4:0] inSelect0, inSelect1, // [4] is enable  1 : WRITE 0 : READ 
    input [3:0] outSelect0, outSelect1, outSelect2,
    input clk,
    output [31:0] out0, out1, out2
);
    wire [15:0] S0Arr, S1Arr;
    wire [511:0] rFileStatus;
    
    decoder16 D1(
        .X(inSelect0[3:0]),
        .enable(inSelect0[4]),
        .Y(S0Arr)
    );
    decoder16 D2(
        .X(inSelect1[3:0]),
        .enable(inSelect1[4]),
        .Y(S1Arr)
    );
    
    generate
        for (genvar i = 0; i < 16; i = i + 1) begin
            regCell rC(
                .D0(inp0), 
                .D1(inp1),
                .S0(S0Arr[i]), 
                .S1(S1Arr[i]), 
                .clk(clk),
                .Q(rFileStatus[(i+1)*32 - 1:i*32])
            );
        end
    endgenerate
    
    mux16_1_32 M0(
        .X(rFileStatus),
        .select(outSelect0),
        .clk(clk),
        .Y(out0)
    );
    mux16_1_32 M1(
        .X(rFileStatus),
        .select(outSelect1),
        .clk(clk),
        .Y(out1)
    );
    mux16_1_32 M2(
        .X(rFileStatus),
        .select(outSelect2),
        .clk(clk),
        .Y(out2)
    );
    
endmodule