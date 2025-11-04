`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2025 21:21:27
// Design Name: 
// Module Name: halfAdder
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

module tristate_buffer (
    input x,     // Data input
    input c,     // Control (enable)
    output y     // Output
);

assign y = c ? x : 1'bz;

endmodule

module halfAdder(
    input A, B,
    output C, S
);
    
    xor G1 (S, A, B);
    and G2 (C, A, B);
    
endmodule

module fullAdder(
    input Ci, A, B,
    output Co, S
);

    wire w1, w2, w3;
    
    or (Co, w1, w3);
    
    halfAdder HA1 (
        .A(Ci),
        .B(A),
        .C(w1),
        .S(w2)
    );
    
    halfAdder HA2 (
        .A(w2),
        .B(B),
        .C(w3),
        .S(S)
    );

endmodule

module and32M(
    input [31:0] A,
    input B,
    output [31:0] Y
    );
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            and (Y[i], A[i], B);
        end
    endgenerate
    
endmodule

module and32(
    input [31:0] A, B,
    output [31:0] Y
    );

    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            and N (Y[i], A[i], B[i]);
        end
    endgenerate

endmodule

module or32(
    input [31:0] A, B,
    output [31:0] Y
    );

    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            or N (Y[i], A[i], B[i]);
        end
    endgenerate

endmodule

module xor32(
    input [31:0] A, B,
    output [31:0] Y
    );

    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            xor N (Y[i], A[i], B[i]);
        end
    endgenerate

endmodule

module not32(
    input [31:0] X,
    output [31:0] Y
    );

    generate
        for (genvar i = 0; i < 32; i = i + 1) begin
            not N (Y[i], X[i]);
        end
    endgenerate

endmodule

module negate32(
    input [31:0] X,
    output [31:0] Y
);

    wire [31:0] nx;
    
    not32 N32 (
        .X(X),
        .Y(nx)
    );
    
    add32 A32 (
        .A(nx),
        .B(32'h0000_0001),
        .Ci(32'h0000_0000),
        .S(Y)
    );

endmodule

module mux2_1_32(
    input [31:0] X0, X1,
    input select,
    output reg [31:0] Y
);
    
    always @(*) begin
        case (select)
            1'b0 : Y = X0;
            1'b1 : Y = X1;
        endcase
    end

endmodule

module mux4_1_32(
    input [31:0] X0, X1, X2, X3,
    input [1:0] select,
    output reg [31:0] Y
);
    
    always @(*) begin
        case (select)
            2'b00 : Y = X0;
            2'b01 : Y = X1;
            2'b10 : Y = X2;
            2'b11 : Y = X3;
        endcase
    end

endmodule

module mux8_1_32(
    input [31:0] X0, X1, X2, X3, X4, X5, X6, X7,
    input [2:0] select,
    output reg [31:0] Y
);
    
    always @(*) begin
        case (select)
            3'b000 : Y = X0;
            3'b001 : Y = X1;
            3'b010 : Y = X2;
            3'b011 : Y = X3;
            3'b100 : Y = X4;
            3'b101 : Y = X5;
            3'b110 : Y = X6;
            3'b111 : Y = X7;
        endcase
    end

endmodule

module mux16_1_32(
    input [511:0] X,
    input [3:0] select,
    input clk,
    output reg [31:0] Y
);

    always @(*) begin
        case (select)
            4'b0000 : Y <= X[31:0];
            4'b0001 : Y <= X[63:32];
            4'b0010 : Y <= X[95:64];
            4'b0011 : Y <= X[127:96];
            4'b0100 : Y <= X[159:128];
            4'b0101 : Y <= X[191:160];
            4'b0110 : Y <= X[223:192];
            4'b0111 : Y <= X[255:224];
            4'b1000 : Y <= X[287:256];
            4'b1001 : Y <= X[319:288];
            4'b1010 : Y <= X[351:320];
            4'b1011 : Y <= X[383:352];
            4'b1100 : Y <= X[415:384];
            4'b1101 : Y <= X[447:416];
            4'b1110 : Y <= X[479:448];
            4'b1111 : Y <= X[511:480];
        endcase
    end
endmodule

module mux2_1_4(
    input [3:0] X0, X1,
    input select,
    output reg [3:0] Y
);
    
    always @(*) begin
        case (select)
            1'b0 : Y = X0;
            1'b1 : Y = X1;
        endcase
    end

endmodule

module mux2_1_1(
    input X0, X1,
    input select,
    output reg Y
);
    always @(*) begin
        case (select)
            1'b0 : Y = X0;
            1'b1 : Y = X1;
        endcase
    end
endmodule

module decoder32(
    input [4:0] X,
    output [31:0] Y
);
    
    wire [4:0] n;
    
    not (n[0], X[0]);
    not (n[1], X[1]);
    not (n[2], X[2]);
    not (n[3], X[3]);
    not (n[4], X[4]);
    
    and (Y[00], n[4], n[3], n[2], n[1], n[0]);
    and (Y[01], n[4], n[3], n[2], n[1], X[0]);
    and (Y[02], n[4], n[3], n[2], X[1], n[0]);
    and (Y[03], n[4], n[3], n[2], X[1], X[0]);
    and (Y[04], n[4], n[3], X[2], n[1], n[0]);
    and (Y[05], n[4], n[3], X[2], n[1], X[0]);
    and (Y[06], n[4], n[3], X[2], X[1], n[0]);
    and (Y[07], n[4], n[3], X[2], X[1], X[0]);
    and (Y[08], n[4], X[3], n[2], n[1], n[0]);
    and (Y[09], n[4], X[3], n[2], n[1], X[0]);
    and (Y[10], n[4], X[3], n[2], X[1], n[0]);
    and (Y[11], n[4], X[3], n[2], X[1], X[0]);
    and (Y[12], n[4], X[3], X[2], n[1], n[0]);
    and (Y[13], n[4], X[3], X[2], n[1], X[0]);
    and (Y[14], n[4], X[3], X[2], X[1], n[0]);
    and (Y[15], n[4], X[3], X[2], X[1], X[0]);
    and (Y[16], X[4], n[3], n[2], n[1], n[0]);
    and (Y[17], X[4], n[3], n[2], n[1], X[0]);
    and (Y[18], X[4], n[3], n[2], X[1], n[0]);
    and (Y[19], X[4], n[3], n[2], X[1], X[0]);
    and (Y[20], X[4], n[3], X[2], n[1], n[0]);
    and (Y[21], X[4], n[3], X[2], n[1], X[0]);
    and (Y[22], X[4], n[3], X[2], X[1], n[0]);
    and (Y[23], X[4], n[3], X[2], X[1], X[0]);
    and (Y[24], X[4], X[3], n[2], n[1], n[0]);
    and (Y[25], X[4], X[3], n[2], n[1], X[0]);
    and (Y[26], X[4], X[3], n[2], X[1], n[0]);
    and (Y[27], X[4], X[3], n[2], X[1], X[0]);
    and (Y[28], X[4], X[3], X[2], n[1], n[0]);
    and (Y[29], X[4], X[3], X[2], n[1], X[0]);
    and (Y[30], X[4], X[3], X[2], X[1], n[0]);
    and (Y[31], X[4], X[3], X[2], X[1], X[0]);
    
endmodule

module decoder16(
    input [3:0] X,
    input enable,
    output [15:0] Y
);
    
    wire [3:0] n;
    
    not (n[0], X[0]);
    not (n[1], X[1]);
    not (n[2], X[2]);
    not (n[3], X[3]);
    
    and (Y[00], n[3], n[2], n[1], n[0], enable);
    and (Y[01], n[3], n[2], n[1], X[0], enable);
    and (Y[02], n[3], n[2], X[1], n[0], enable);
    and (Y[03], n[3], n[2], X[1], X[0], enable);
    and (Y[04], n[3], X[2], n[1], n[0], enable);
    and (Y[05], n[3], X[2], n[1], X[0], enable);
    and (Y[06], n[3], X[2], X[1], n[0], enable);
    and (Y[07], n[3], X[2], X[1], X[0], enable);
    and (Y[08], X[3], n[2], n[1], n[0], enable);
    and (Y[09], X[3], n[2], n[1], X[0], enable);
    and (Y[10], X[3], n[2], X[1], n[0], enable);
    and (Y[11], X[3], n[2], X[1], X[0], enable);
    and (Y[12], X[3], X[2], n[1], n[0], enable);
    and (Y[13], X[3], X[2], n[1], X[0], enable);
    and (Y[14], X[3], X[2], X[1], n[0], enable);
    and (Y[15], X[3], X[2], X[1], X[0], enable);
    
endmodule

module lShift(
    input [31:0] X,
    input [4:0] shiftAmt,
    input SR, // shift = 0, ROTATE = 1
    output [31:0] Y
);

    wire [31:0] controlSig;
    
    decoder32 d32 (
        .X (shiftAmt),
        .Y(controlSig)
    );
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin // shift amt
            for (genvar j = 0; j < 32; j = j + 1) begin // output
                if (j - i < 0) begin
                    wire muxConnect;
                    
                    mux2_1_1 M (
                        .X0(1'b0),
                        .X1(X[j - i + 32]),
                        .select(SR),
                        .Y(muxConnect)
                    );
                    
                    tristate_buffer tsb (
                        .x(muxConnect),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end else begin
                    tristate_buffer tsb (
                        .x(X[j - i]),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end
            end
        end
    endgenerate

endmodule

module rShift(
    input [31:0] X,
    input [4:0] shiftAmt,
    input SR, // shift = 0, ROTATE = 1
    input LA, // logical = 0, ARITHMETIC = 1
    output [31:0] Y
);

    wire [31:0] controlSig;
    
    decoder32 d32 (
        .X (shiftAmt),
        .Y(controlSig)
    );
    
    generate
        for (genvar i = 0; i < 32; i = i + 1) begin // shift amt
            for (genvar j = 0; j < 32; j = j + 1) begin // output
                if (j + i >= 32) begin
                    wire newBit, muxConnect;
                    
                    mux2_1_1 M_LA (
                        .X0(1'b0),
                        .X1(X[31]),
                        .select(LA),
                        .Y(newBit)
                    );
                    
                    mux2_1_1 M_SR (
                        .X0(newBit),
                        .X1(X[j + i - 32]),
                        .select(SR),
                        .Y(muxConnect)
                    );
                    
                    tristate_buffer tsb (
                        .x(muxConnect),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end else begin
                    tristate_buffer tsb (
                        .x(X[j + i]),
                        .y(Y[j]),
                        .c(controlSig[i])
                    );
                end
            end
        end
    endgenerate

endmodule