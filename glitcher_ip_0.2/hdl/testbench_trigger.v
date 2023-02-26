`timescale 1ns / 1ps


module testbench_trigger();
    
    reg CLK = 0;
    reg RST_N = 0;
    reg EN = 0;
    reg [31:0] DELAY_1ST = 0;
    reg [31:0] DELAY_2ND = 0;
    reg [31:0] PULSE_WIDTH = 0;
    wire TRIGGER;
    wire DONE;
    
      trigger # () uut (
      .i_CLK(CLK),
      .i_RST_N(RST_N),
      .i_EN(EN),
      .i_DELAY_1ST(DELAY_1ST),
      .i_DELAY_2ND(DELAY_2ND),
      .i_PULSE_WIDTH(PULSE_WIDTH),
      .o_TRIGGER(TRIGGER),
      .o_DONE(DONE)
    );
 
initial begin
    CLK = 0;
end

always #5 CLK=!CLK;

initial begin

    #0 RST_N = 1'b1;
    #0 EN = 1'b0;
    #10 RST_N = 1'b0;
    #10 RST_N = 1'b1;
    
    #5 
    #0 DELAY_1ST = 32'h0;
    #0 DELAY_2ND = 32'h0;
    #0 PULSE_WIDTH = 32'h0;
    #30 EN = 1'b1;
    #5 EN = 1'b0;  
    
    #200
    #0 DELAY_1ST = 32'h0;
    #0 DELAY_2ND = 32'h7;
    #25 EN = 1'b1;
    #5 EN = 1'b0;    

    #200
    #0 DELAY_1ST = 32'h0;
    #0 DELAY_2ND = 32'h0;
    #0 PULSE_WIDTH = 32'h3;
    #25 EN = 1'b1;
    #5 EN = 1'b0;    

    #200
    #0 DELAY_1ST = 32'h0;
    #0 DELAY_2ND = 32'h7;
    #0 PULSE_WIDTH = 32'h3;
    #25 EN = 1'b1;
    #5 EN = 1'b0;    

    #200    
    #0 DELAY_1ST = 32'h3;
    #0 DELAY_2ND = 32'h0;
    #25 EN = 1'b1;
    #5 EN = 1'b0;  
    
    #200
    #0 DELAY_1ST = 32'h8;
    #0 DELAY_2ND = 32'h14;
    #25 EN = 1'b1;
    #5 EN = 1'b0;
    
    #400
    #0 DELAY_1ST = 32'h9;
    #0 DELAY_2ND = 32'h16;
    #25 EN = 1'b1;
    #5 EN = 1'b0;
    #120 RST_N = 1'b0;  
    #10 RST_N = 1'b1;
    
    
    #200 $finish;
end
    
endmodule
