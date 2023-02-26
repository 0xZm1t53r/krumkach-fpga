`timescale 1ns / 1ps

module testbench_handler();

   reg CLK = 1;
   reg RST_N = 1'b0;
   reg [7:0] CONTROL = 8'h0;
   reg CONTROL_WR = 1'b0;
   reg TRIGGER_IN = 0;
   reg [7:0] RX = 8'h0;
   reg RX_READY = 0;
   reg [31:0] DELAY_1ST = 32'h0;
   reg [31:0] DELAY_2ND = 32'h0;
   reg [31:0] PULSE_WIDTH = 32'h0;
   reg [1023:0] BUFFER = 1024'h0;
   reg [6:0] BUF_LEN = 7'h0;

   wire [7:0] STATUS;
   wire [7:0] DEBUG;
   wire LOCK;
   wire STOP_N;
   wire TRIGGER_OUT;
   wire TRIGGER;
   wire DONE;
    
   reg [47:0] rx_value = 48'h343332313020;

   integer i = 0;
   integer j = 0;
   
   handler #(
    .TRIGGER_MIN_CNT(3)
   ) handler_inst (
    .i_CLK(CLK),
    .i_RST_N(RST_N),
    .i_CONTROL(CONTROL),
    .i_CONTROL_WR(CONTROL_WR),
    .i_TRIGGER(TRIGGER_IN),
    .i_RX(RX),
    .i_RX_READY(RX_READY),
    .i_DELAY_1ST(DELAY_1ST),
    .i_DELAY_2ND(DELAY_2ND),
    .i_PULSE_WIDTH(PULSE_WIDTH),
    .i_BUFFER(BUFFER),
    .i_BUF_LEN(BUF_LEN),

    .o_STATUS(STATUS),
    .o_DEBUG(DEBUG),
    .o_LOCK(LOCK),
    .o_STOP_N(STOP_N),
    .o_TRIGGER(TRIGGER_OUT)
   );
   
   trigger # () uut (
      .i_CLK(CLK),
      .i_RST_N(STOP_N),
      .i_EN(TRIGGER_OUT),
      .i_DELAY_1ST(DELAY_1ST),
      .i_DELAY_2ND(DELAY_2ND),
      .i_PULSE_WIDTH(PULSE_WIDTH),
      .o_TRIGGER(TRIGGER),
      .o_DONE(DONE)
    );
 

initial begin
    CLK = 1;
end

always #5 CLK=!CLK;


initial begin
    #10
    RST_N = 1'b1;
   
    #10
    BUF_LEN = 6'h3;
    BUFFER[0 * 8 +: 8] = 8'h30;
    BUFFER[1 * 8 +: 8] = 8'h31;
    BUFFER[2 * 8 +: 8] = 8'h32;
    BUFFER[3 * 8 +: 8] = 8'h33;
    
    #20
    CONTROL = 8'h2;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    for (i=0; i < 6; i = i + 1) begin
      #10 RX = rx_value[8*i +: 8];
      #10 RX_READY = 1;
      #5 RX_READY = 0;
      #5 RX_READY = 0;
    end
    
    #20 DELAY_2ND = 32'h7;

    #0 CONTROL = 8'h0;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    #20 CONTROL = 8'h2;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;

    for (i=0; i < 6; i = i + 1) begin
      #10 RX = rx_value[8*i +: 8];
      #10 RX_READY = 1;
      #5 RX_READY = 0;
      #5 RX_READY = 0;
    end
    
    #20 DELAY_1ST = 32'h0;
    #0  DELAY_2ND = 32'h5;

    #0 CONTROL = 8'h0;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    #20 CONTROL = 8'h2;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;

    for (i=0; i < 6; i = i + 1) begin
      #10 RX = rx_value[8*i +: 8];
      #10 RX_READY = 1;
      #5 RX_READY = 0;
      #5 RX_READY = 0;
    end

    #20 DELAY_1ST = 32'h0;
    #0  DELAY_2ND = 32'h0;
    #0  PULSE_WIDTH = 32'h10;

    #0 CONTROL = 8'h0;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    #20 CONTROL = 8'h2;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;

    for (i=0; i < 6; i = i + 1) begin
      #10 RX = rx_value[8*i +: 8];
      #10 RX_READY = 1;
      #5 RX_READY = 0;
      #5 RX_READY = 0;
    end
   
    #20 DELAY_1ST = 32'h7;
    #0  DELAY_2ND = 32'h0;
    #0  PULSE_WIDTH = 32'h10;

    #0 CONTROL = 8'h0;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    #20 CONTROL = 8'h2;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;

    for (i=0; i < 6; i = i + 1) begin
      #10 RX = rx_value[8*i +: 8];
      #10 RX_READY = 1;
      #5 RX_READY = 0;
      #5 RX_READY = 0;
    end

    #200 DELAY_1ST = 32'h7;
    #0  DELAY_2ND = 32'h14;
    #0  PULSE_WIDTH = 32'h10;

    #0 CONTROL = 8'h0;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    #40 CONTROL = 8'h2;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;

    for (j=0; j < 3; j = j +1 ) begin
      for (i=0; i < 6; i = i + 1) begin
        #10 RX = rx_value[8*i +: 8];
        #10 RX_READY = 1;
        #5 RX_READY = 0;
        #5 RX_READY = 0;
      end
    end
    
    #200 CONTROL = 8'h0;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    #20 CONTROL = 8'h1;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    for (j=0; j < 3; j = j +1 ) begin
      for (i=0; i < 6; i = i + 1) begin
        #10 RX = rx_value[8*i +: 8];
        #10 RX_READY = 1;
        #5 RX_READY = 0;
        #5 RX_READY = 0;
      end
    end
          
    #200 CONTROL = 8'h0;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    #20 CONTROL = 8'h1;
    #10 CONTROL_WR = 1'b1;
    #10 CONTROL_WR = 1'b0;
    
    for (j=0; j < 10; j = j +1 ) begin
      for (i=0; i < 6; i = i + 1) begin
        #10 RX = rx_value[8*i +: 8];
        #10 RX_READY = 1;
        #5 RX_READY = 0;
        #5 RX_READY = 0;
      end
      
      if (j == 3) begin
          #10 CONTROL = 8'h02;
          #10 CONTROL_WR = 1'b1;
          #10 CONTROL_WR = 1'b0;
      end
      
      if (j == 6) begin
          #10 CONTROL = 8'h12;
          #10 CONTROL_WR = 1'b1;
          #10 CONTROL_WR = 1'b0;
      end
    end 
     
    #10 RX = 0;
    
    #10 TRIGGER_IN = 1;
    #10 TRIGGER_IN = 0;
    #10 TRIGGER_IN = 1;
    #10 TRIGGER_IN = 0;
    #40 TRIGGER_IN = 1;
    #10 TRIGGER_IN = 0;
    
    #400 $finish;
end

endmodule
