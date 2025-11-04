`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2025 09:22:52
// Design Name: 
// Module Name: decoder_test
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


module decoder_test();

    reg [4:0] select;
    reg enable;
    
    wire [31:0] outY;
    
    regDecoder RD (
        .select(select),
        .enable(enable),
        .Y(outY)
    );
    
    initial begin
        #10 select = 5'b00000;
        #10 enable = 1'b0;
        #10 enable = 1'b1;
        #10 select = 5'b00001;
        #10 select = 5'b00010;
        #10 select = 5'b00011;
        #10 select = 5'b00100;
        #10 select = 5'b00101;
        #10 select = 5'b00110;
        #10 select = 5'b00111;
        #10 select = 5'b01000;
        #10 select = 5'b01001;
        #10 select = 5'b01010;
        #10 select = 5'b01011;
        #10 select = 5'b01100;
        #10 select = 5'b01101;
        #10 select = 5'b01110;
        #10 select = 5'b01111;
        #10 select = 5'b10000;
        #10 select = 5'b10001;
        #10 select = 5'b10010;
        #10 select = 5'b10011;
        #10 select = 5'b10100;
        #10 select = 5'b10101;
        #10 select = 5'b10110;
        #10 select = 5'b10111;
        #10 select = 5'b11000;
        #10 select = 5'b11001;
        #10 select = 5'b11010;
        #10 select = 5'b11011;
        #10 select = 5'b11100;
        #10 select = 5'b11101;
        #10 select = 5'b11110;
        #10 select = 5'b11111;
    end
endmodule

module test_regFile;

    reg clk = 0;
    reg [31:0] inp0, inp1;
    reg [5:0] inSelect0, inSelect1; // [5] is write enable
    reg [4:0] outSelect0, outSelect1;
    wire [31:0] out0, out1;

    // Instantiate the register file
    regFile uut (
        .inp0(inp0),
        .inp1(inp1),
        .inSelect0(inSelect0),
        .inSelect1(inSelect1),
        .outSelect0(outSelect0),
        .outSelect1(outSelect1),
        .clk(clk),
        .out0(out0),
        .out1(out1)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        inp0 = 0; inp1 = 0;
        inSelect0 = 0; inSelect1 = 0;
        outSelect0 = 0; outSelect1 = 0;

        @(negedge clk);

        // Write 0xAAAA_AAAA to register 3 via port0, Write 0x5555_5555 to register 5 via port1
        inp0 = 32'hAAAA_AAAA;
        inp1 = 32'h5555_5555;
        inSelect0 = 6'b1_00011; // write enable = 1, address = 3
        inSelect1 = 6'b1_00101; // write enable = 1, address = 5
        @(negedge clk);

        // Disable writes
        inSelect0 = 6'b0_00000;
        inSelect1 = 6'b0_00000;

        // Read from registers 3 and 5
        outSelect0 = 5'd3;
        outSelect1 = 5'd5;
        @(negedge clk);

        // Write new value to register 3 via port1 and overwrite with port0 to reg 7
        inp0 = 32'hFACE_BEEF;
        inp1 = 32'hDEAD_BEEF;
        inSelect0 = 6'b1_00111; // write to reg 7
        inSelect1 = 6'b1_00011; // write to reg 3
        @(negedge clk);

        // Disable writes
        inSelect0 = 6'b0_00000;
        inSelect1 = 6'b0_00000;

        // Read from registers 3 and 7
        outSelect0 = 5'd3;
        outSelect1 = 5'd7;
        #10;

        $finish;
    end

endmodule



module shift_test();
    reg [31:0] X;
    reg [4:0] sAmt;
    
    wire [31:0] out;
    
    rShift ls (
        .X(32'hdddd_dddd),
        .LA(1'b1),
        .SR(1'b1),
        .shiftAmt(sAmt),
        .Y(out)
//        .X(sAmt),
//        .Y(out)
    );
    
    initial begin
        #10 sAmt = 5'b00000;
        #10 sAmt = 5'b00001;
        #10 sAmt = 5'b00010;
        #10 sAmt = 5'b00011;
        #10 sAmt = 5'b00100;
        #10 sAmt = 5'b00101;
        #10 sAmt = 5'b00110;
        #10 sAmt = 5'b00111;
        
        #10 sAmt = 5'b01000;
        #10 sAmt = 5'b01001;
        #10 sAmt = 5'b01010;
        #10 sAmt = 5'b01011;
        #10 sAmt = 5'b01100;
        #10 sAmt = 5'b01101;
        #10 sAmt = 5'b01110;
        #10 sAmt = 5'b01111;
        
        #10 sAmt = 5'b10000;
        #10 sAmt = 5'b10001;
        #10 sAmt = 5'b10010;
        #10 sAmt = 5'b10011;
        #10 sAmt = 5'b10100;
        #10 sAmt = 5'b10101;
        #10 sAmt = 5'b10110;
        #10 sAmt = 5'b10111;
        
        #10 sAmt = 5'b11000;
        #10 sAmt = 5'b11001;
        #10 sAmt = 5'b11010;
        #10 sAmt = 5'b11011;
        #10 sAmt = 5'b11100;
        #10 sAmt = 5'b11101;
        #10 sAmt = 5'b11110;
        #10 sAmt = 5'b11111;
    end
endmodule

module tb_mainRAM;
    parameter addWidth = 8;

    reg clk = 0;
    reg rw = 0;
    reg [addWidth-1:0] WSelect;
    reg [addWidth-1:0] RSelect1;
    reg [addWidth-1:0] RSelect2;
    reg [31:0] writeDB;
    wire [31:0] readDB1;
    wire [31:0] readDB2;

    // Instantiate the RAM module
    mainRAM #(addWidth) uut (
        .rw(rw), .clk(clk),
        .WSelect(WSelect),
        .RSelect1(RSelect1),
        .RSelect2(RSelect2),
        .writeDB(writeDB),
        .readDB1(readDB1),
        .readDB2(readDB2)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        // Write to address 8
        rw = 1;
        WSelect = 8'd8;
        writeDB = 32'hA5A5_FF00;
        RSelect1 = 8'd8;
        RSelect2 = 8'd0; 
        #10; // One clock

        // Write to address 12
        WSelect = 8'd12;
        writeDB = 32'hDEAD_0000;
        RSelect1 = 8'd12;
        RSelect2 = 8'd8;
        #10; 

        // Read from both addresses (no write)
        rw = 0;
        RSelect1 = 8'd8;
        RSelect2 = 8'd12;
        #10;
        $finish;
    end
endmodule

module tb_mainRAM_printer;

    parameter addWidth = 8;

    reg clk = 0;
    reg rw;
    reg [addWidth-1:0] WSelect;
    reg [addWidth-1:0] RSelect1;
    reg [addWidth-1:0] RSelect2;
    reg [31:0] writeDB;
    wire [31:0] readDB1;
    wire [31:0] readDB2;

    // Instantiate RAM
    mainRAM #(addWidth) uut (
        .wEnable(rw),
        .clk(clk),
        .WSelect(WSelect),
        .RSelect1(RSelect1),
        .RSelect2(RSelect2),
        .writeDB(writeDB),
        .readDB1(readDB1),
        .readDB2(readDB2)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    integer i;

    initial begin
        // Initially no write operation
        rw = 0;
        WSelect = 0;
        RSelect1 = 0;
        RSelect2 = 1;     // different address for second read port
        writeDB = 0;

        // Wait some time for RAM to initialize from program.hex
        #50;

        $display("Dumping instructions from RAM addresses 0 to 255:");
        for (i = 0; i < 256; i = i + 2) begin
            @(posedge clk);
            RSelect1 = i;
            RSelect2 = i+1;
            @(posedge clk);
            $display("Address %0d: %h\tAddress %0d: %h", RSelect1, readDB1, RSelect2, readDB2);
        end

        $finish;
    end

endmodule

module tb_main32;
  // Parameters
  parameter CYCLES = 14; // change as desired

  // DUT connections
  reg rst, clk;
  reg [3:0] rSelect;
  wire [31:0] regOut, PCOut, instructOut;
  wire [3:0] flagOut;

  // Instantiate DUT
  main32 uut (
    .rst(rst),
    .clk(clk),
    .rSelect(rSelect),
    .regOut(regOut),
    .PCOut(PCOut),
    .instructOut(instructOut),
    .flagOut(flagOut)
  );

  integer cycle, regidx;

  // Clock generation: 20ns period
  initial begin
    clk = 0;
    forever #20 clk = ~clk;
  end

  // TB procedure
  initial begin
    rst = 1; #25; // initial reset
    rst = 0;

    for (cycle = 0; cycle < CYCLES; cycle = cycle + 1) begin
      // Wait for next negative edge to fetch instruction
      @(negedge clk);
      #1; // let signals settle
      $display("\n----- CYCLE %0d -----", cycle);

      // Show core state
      $display("PC = %08h | Instruction = %08h | Flags = %01b", PCOut, instructOut, flagOut);

      // Print all 16 registers
      for (regidx = 0; regidx < 16; regidx = regidx + 1) begin
        rSelect = regidx;
        #1; // allow for any mux delay
        $display("R[%0d] = %08h (dec: %0d)", regidx, regOut, regOut);
      end

      // Wait for posedge to commit writes
      @(posedge clk);
    end

    $finish;
  end
endmodule


