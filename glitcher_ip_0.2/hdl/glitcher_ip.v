`timescale 1 ns / 1 ps

module glitcher_ip_v0_2 #
(
  // Users to add parameters here
  parameter integer TRIGGER_MIN_CNT = 16,
  parameter integer DELAY_1ST_DEFAULT = 100,
  parameter integer DELAY_2ND_DEFAULT = 100,
  parameter integer PULSE_WIDTH_DEFAULT = 100,
  parameter integer TARGET_NRST_WIDTH_DEFAULT = 1000,
  // User parameters ends

  // Do not modify the parameters beyond this line
  // Parameters of Axi Slave Bus Interface S_AXI
  parameter integer C_S_AXI_DATA_WIDTH	= 32,
  parameter integer C_S_AXI_ADDR_WIDTH	= 8
)
(
  // Users to add ports here
  input wire [7:0] RX,
  input wire RX_READY,
  input wire TRIGGER_IN,
  output wire TRIGGER_OUT,
  output wire EVENT_OUT,
  output wire TARGET_NRST_OUT,
  output wire RUN_OUT,
  // User ports ends

  // Do not modify the ports beyond this line
  // Ports of Axi Slave Bus Interface S_AXI
  input wire  s_axi_aclk,
  input wire  s_axi_aresetn,
  input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
  input wire [2 : 0] s_axi_awprot,
  input wire  s_axi_awvalid,
  output wire  s_axi_awready,
  input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
  input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
  input wire  s_axi_wvalid,
  output wire  s_axi_wready,
  output wire [1 : 0] s_axi_bresp,
  output wire  s_axi_bvalid,
  input wire  s_axi_bready,
  input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
  input wire [2 : 0] s_axi_arprot,
  input wire  s_axi_arvalid,
  output wire  s_axi_arready,
  output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
  output wire [1 : 0] s_axi_rresp,
  output wire  s_axi_rvalid,
  input wire  s_axi_rready
);

	wire event_out;
	wire target_nrst_out;

	wire [C_S_AXI_DATA_WIDTH-1 : 0] delay_1st;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] delay_2nd;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] pulse_width;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] delay_1st_out;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] delay_2nd_out;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] pulse_width_out;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] target_rst_width;
	wire [7:0] control;
	wire control_wr;
	wire target_rst_n;
	wire [1023:0] buffer;
	wire [6:0] buf_len;
	wire [31:0] status;
	wire [15:0] debug;
	wire lock;
	wire stop_n;
	wire done;

  wire delayer_1st_out;
  wire delayer_2nd_out;
  wire delayer_1st_run;
  wire delayer_2nd_run;
  wire target_rst_run;

  reg [31:0] r_delay_1st;
  reg [31:0] r_delay_2nd;
  reg [31:0] r_pulse_width;
  reg trig_2nd_enabled = 1'b1;
  reg lock_sample;

  assign trig_1st = event_out & ~delayer_2nd_run;
  assign trig_2nd = delayer_1st_out & trig_2nd_enabled;

  assign EVENT_OUT       = event_out;
  assign TARGET_NRST_OUT = ~target_nrst_out;
  assign TRIGGER_OUT = delayer_1st_out | delayer_2nd_out;
  assign RUN_OUT = lock;

  assign target_nrst_trigger = control[5];
  //assign trigger_input = (TRIGGER_IN & ~target_nrst_trigger) | (TARGET_NRST_OUT & target_nrst_trigger);
  assign trigger_input = target_nrst_trigger?TARGET_NRST_OUT:TRIGGER_IN;

  always @ (posedge s_axi_aclk)
  begin
    if (!stop_n) begin
      r_delay_1st <= 32'h0;
      r_delay_2nd <= 32'h0;
      r_pulse_width <= 32'h0;
      lock_sample <= 1'b0;
      trig_2nd_enabled <= 1'b1;
    end else begin
      lock_sample <= lock;
      if (lock & ~lock_sample) begin
        r_delay_1st <= delay_1st;
        r_delay_2nd <= delay_2nd;
        r_pulse_width <= pulse_width;
        trig_2nd_enabled <= ~control[7];
      end
    end
  end

  // Instantiation of Axi Bus Interface S_AXI
	glitcher_ip_S_AXI # ( 
    .DELAY_1ST_DEFAULT(DELAY_1ST_DEFAULT),
    .DELAY_2ND_DEFAULT(DELAY_2ND_DEFAULT),
    .PULSE_WIDTH_DEFAULT(PULSE_WIDTH_DEFAULT),
    .TARGET_NRST_WIDTH_DEFAULT(TARGET_NRST_WIDTH_DEFAULT),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) glitcher_ip_v0_1_S_AXI_inst (
		.i_STATUS(status),
		.i_DEBUG(debug),
		.i_RX(RX),
		.i_RX_READY(RX_READY),
		.i_LOCK(lock),
		.o_CONTROL(control),
		.o_CONTROL_WR(control_wr),
		.o_BUFFER(buffer),
		.o_BUF_LEN(buf_len),
		.o_DELAY_1ST(delay_1st),
		.o_DELAY_2ND(delay_2nd),
		.o_PULSE_WIDTH(pulse_width),
    .o_TARGET_RST_PULSE(target_rst_n),
    .o_TARGET_RST_WIDTH(target_rst_width),

		.S_AXI_ACLK(s_axi_aclk),
		.S_AXI_ARESETN(s_axi_aresetn),
		.S_AXI_AWADDR(s_axi_awaddr),
		.S_AXI_AWPROT(s_axi_awprot),
		.S_AXI_AWVALID(s_axi_awvalid),
		.S_AXI_AWREADY(s_axi_awready),
		.S_AXI_WDATA(s_axi_wdata),
		.S_AXI_WSTRB(s_axi_wstrb),
		.S_AXI_WVALID(s_axi_wvalid),
		.S_AXI_WREADY(s_axi_wready),
		.S_AXI_BRESP(s_axi_bresp),
		.S_AXI_BVALID(s_axi_bvalid),
		.S_AXI_BREADY(s_axi_bready),
		.S_AXI_ARADDR(s_axi_araddr),
		.S_AXI_ARPROT(s_axi_arprot),
		.S_AXI_ARVALID(s_axi_arvalid),
		.S_AXI_ARREADY(s_axi_arready),
		.S_AXI_RDATA(s_axi_rdata),
		.S_AXI_RRESP(s_axi_rresp),
		.S_AXI_RVALID(s_axi_rvalid),
		.S_AXI_RREADY(s_axi_rready)
	); 

	handler #(
    .TRIGGER_MIN_CNT(TRIGGER_MIN_CNT)
  ) handler_inst (
    .i_CLK(s_axi_aclk),
    .i_RST_N(s_axi_aresetn),
    .i_CONTROL(control),
    .i_CONTROL_WR(control_wr),
    .i_TRIGGER(trigger_input),
    .i_RX(RX),
    .i_RX_READY(RX_READY),
    .i_DELAY_1ST(delay_1st),
    .i_DELAY_2ND(delay_2nd),
    .i_PULSE_WIDTH(pulse_width),
    .i_BUFFER(buffer),
    .i_BUF_LEN(buf_len),

    .o_STATUS(status),
    .o_DEBUG(debug),
    .o_LOCK(lock),
    .o_STOP_N(stop_n),
    .o_TRIGGER(event_out)
  );

  delayer #(.BASE_DELAY(32'h2)) delayer_1st (
    .i_CLK(s_axi_aclk),
    .i_RST_N(stop_n),
    .i_TRIGGER(trig_1st),
    .i_DELAY(r_delay_1st),
    .i_WIDTH(r_pulse_width),
    .o_RUN(delayer_1st_run),
    .o_TRIGGER(delayer_1st_out)
  );

  delayer #(.BASE_DELAY(32'h2),
            .INIT_TRIG_STATE(1'b1)) delayer_2nd
  (
    .i_CLK(s_axi_aclk),
    .i_RST_N(stop_n),
    .i_TRIGGER(~trig_2nd),
    .i_DELAY(r_delay_2nd),
    .i_WIDTH(r_pulse_width),
    .o_RUN(delayer_2nd_run),
    .o_TRIGGER(delayer_2nd_out)
  );

  delayer target_rst (
    .i_CLK(s_axi_aclk),
    .i_RST_N(s_axi_aresetn),
    .i_TRIGGER(target_rst_n),
    .i_DELAY(0),
    .i_WIDTH(target_rst_width),
    .o_RUN(target_rst_run),
    .o_TRIGGER(target_nrst_out)
  );

endmodule
