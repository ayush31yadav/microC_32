`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2025 18:10:37
// Design Name: 
// Module Name: mainRAM
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


module mainRAM #(
    parameter addWidth = 8
)  (
    input wEnable, clk,
    input [addWidth - 1:0] WSelect,
    input [addWidth - 1:0] RSelect1,
    input [addWidth - 1:0] RSelect2,
    input [31:0] writeDB,
    output reg [31:0] readDB1,
    output reg [31:0] readDB2
);
    
    localparam size = 1 << addWidth; 
    
    reg [31:0] ram [0:size-1];
        
    initial begin
        $readmemh("program.hex", ram);
    end
    
    always @(posedge clk) begin
        if (wEnable == 1'b1) begin
            ram[WSelect] <= writeDB;
        end
    end
    
    always @(*) begin
        readDB1 <= ram[RSelect1];
        readDB2 <= ram[RSelect2];
    end
endmodule
