`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/24/2022 12:02:05 AM
// Design Name:
// Module Name: testbench
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


module testbench();

  reg clk = 0;
  reg n_rst = 0;
  reg rx = 1;
  integer cnt = 0;

  wire [7:0] rx_byte;
  wire rx_en;

  uart_rx uut(
    .i_Clock(clk),
    .i_Rx_Serial(rx),
    .i_nRst(n_rst),
    .o_Rx_DV(rx_en),
    .o_Rx_Byte(rx_byte)
  );

  always #5 clk <= ~clk;

  initial begin
    #10 n_rst = 1;

    #4340 rx = 1;
    #0 cnt = 0;
    #8680 rx = 0;
    #0 cnt = 1;
    #8680 rx = 1;
    #0 cnt = 2;
    #8680 rx = 0;
    #0 cnt = 3;
    #8680 rx = 1;
    #0 cnt = 4;
    #8680 rx = 0;
    #0 cnt = 5;
    #8680 rx = 1;
    #0 cnt = 6;
    #8680 rx = 0;
    #0 cnt = 7;
    #8680 rx = 1;
    #0 cnt = 8;
    #8680 rx = 0;


    #20000 $finish;

  end

endmodule
