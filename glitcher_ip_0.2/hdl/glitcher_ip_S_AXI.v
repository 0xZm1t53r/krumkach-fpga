`timescale 1 ns / 1 ps

module glitcher_ip_S_AXI #
(
  // Users to add parameters here
  parameter integer DELAY_1ST_DEFAULT = 100,
  parameter integer DELAY_2ND_DEFAULT = 100,
  parameter integer PULSE_WIDTH_DEFAULT = 100,
  parameter integer TARGET_NRST_WIDTH_DEFAULT = 1000,
  // User parameters ends

  // Do not modify the parameters beyond this line
  // Width of S_AXI data bus
  parameter integer C_S_AXI_DATA_WIDTH  = 32,
  // Width of S_AXI address bus
  parameter integer C_S_AXI_ADDR_WIDTH  = 8
)
(
  // Users to add ports here
  input  wire [31:0]                      i_STATUS,
  input  wire [15:0]                      i_DEBUG,
  input  wire [7:0]                       i_RX,
  input  wire                             i_RX_READY,
  input  wire                             i_LOCK,

  output wire [7:0]                       o_CONTROL,
  output wire                             o_CONTROL_WR,
  output wire [C_S_AXI_DATA_WIDTH*32-1:0] o_BUFFER,
  output wire [6:0]                       o_BUF_LEN,
  output wire [C_S_AXI_DATA_WIDTH-1:0]    o_DELAY_1ST,
  output wire [C_S_AXI_DATA_WIDTH-1:0]    o_DELAY_2ND,
  output wire [C_S_AXI_DATA_WIDTH-1:0]    o_PULSE_WIDTH,
  output wire                             o_TARGET_RST_PULSE,
  output wire [C_S_AXI_DATA_WIDTH-1:0]    o_TARGET_RST_WIDTH,
  // User ports ends

  // Do not modify the ports beyond this line
  // Global Clock Signal
  input wire  S_AXI_ACLK,
  // Global Reset Signal. This Signal is Active LOW
  input wire  S_AXI_ARESETN,
  // Write address (issued by master, acceped by Slave)
  input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
  // Write channel Protection type. This signal indicates the
  // privilege and security level of the transaction, and whether
  // the transaction is a data access or an instruction access.
  input wire [2 : 0] S_AXI_AWPROT,
  // Write address valid. This signal indicates that the master signaling
  // valid write address and control information.
  input wire  S_AXI_AWVALID,
  // Write address ready. This signal indicates that the slave is ready
  // to accept an address and associated control signals.
  output wire  S_AXI_AWREADY,
  // Write data (issued by master, acceped by Slave)
  input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
  // Write strobes. This signal indicates which byte lanes hold
  // valid data. There is one write strobe bit for each eight
  // bits of the write data bus.
  input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
  // Write valid. This signal indicates that valid write
  // data and strobes are available.
  input wire  S_AXI_WVALID,
  // Write ready. This signal indicates that the slave
  // can accept the write data.
  output wire  S_AXI_WREADY,
  // Write response. This signal indicates the status
  // of the write transaction.
  output wire [1 : 0] S_AXI_BRESP,
  // Write response valid. This signal indicates that the channel
  // is signaling a valid write response.
  output wire  S_AXI_BVALID,
  // Response ready. This signal indicates that the master
  // can accept a write response.
  input wire  S_AXI_BREADY,
  // Read address (issued by master, acceped by Slave)
  input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
  // Protection type. This signal indicates the privilege
  // and security level of the transaction, and whether the
  // transaction is a data access or an instruction access.
  input wire [2 : 0] S_AXI_ARPROT,
  // Read address valid. This signal indicates that the channel
  // is signaling valid read address and control information.
  input wire  S_AXI_ARVALID,
  // Read address ready. This signal indicates that the slave is
  // ready to accept an address and associated control signals.
  output wire  S_AXI_ARREADY,
  // Read data (issued by slave)
  output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
  // Read response. This signal indicates the status of the
  // read transfer.
  output wire [1 : 0] S_AXI_RRESP,
  // Read valid. This signal indicates that the channel is
  // signaling the required read data.
  output wire  S_AXI_RVALID,
  // Read ready. This signal indicates that the master can
  // accept the read data and response information.
  input wire  S_AXI_RREADY
);

  // AXI4LITE signals
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
  reg   axi_awready;
  reg   axi_wready;
  reg [1 : 0]   axi_bresp;
  reg   axi_bvalid;
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
  reg   axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
  reg [1 : 0]   axi_rresp;
  reg   axi_rvalid;

  // Example-specific design signals
  // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  // ADDR_LSB is used for addressing 32/64 bit registers/memories
  // ADDR_LSB = 2 for 32 bits (n downto 2)
  // ADDR_LSB = 3 for 64 bits (n downto 3)
  localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
  localparam integer OPT_MEM_ADDR_BITS = 5;
  //----------------------------------------------
  //-- Signals for user logic register space example
  //------------------------------------------------
  reg [C_S_AXI_DATA_WIDTH*32-1:0] r_buffer;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_buf_len;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_delay_1st;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_delay_2nd;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_pulse_width;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_target_rst_width;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_control;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_status;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_debug;
  reg [C_S_AXI_DATA_WIDTH-1:0]  r_rx_buffer;
  wire   slv_reg_rden;
  wire   slv_reg_wren;
  reg [C_S_AXI_DATA_WIDTH-1:0]   reg_data_out;
  integer  byte_index;
  reg  aw_en;

  reg [1:0] r_control_wr = 2'b00;
  reg r_target_rst_pulse = 1'b0;

  // I/O Connections assignments
  assign S_AXI_AWREADY  = axi_awready;
  assign S_AXI_WREADY = axi_wready;
  assign S_AXI_BRESP  = axi_bresp;
  assign S_AXI_BVALID = axi_bvalid;
  assign S_AXI_ARREADY  = axi_arready;
  assign S_AXI_RDATA  = axi_rdata;
  assign S_AXI_RRESP  = axi_rresp;
  assign S_AXI_RVALID = axi_rvalid;

  assign o_BUFFER      = r_buffer;
  assign o_BUF_LEN     = r_buf_len[6:0];
  assign o_CONTROL     = r_control[7:0];
  assign o_CONTROL_WR  = r_control_wr[1];
  assign o_DELAY_1ST   = r_delay_1st;
  assign o_DELAY_2ND   = r_delay_2nd;
  assign o_PULSE_WIDTH = r_pulse_width;
  assign o_TARGET_RST_WIDTH = r_target_rst_width;
  assign o_TARGET_RST_PULSE = r_target_rst_pulse;

  // Implement axi_awready generation
  // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  // de-asserted when reset is low.
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_awready <= 1'b0;
        aw_en <= 1'b1;
      end
    else
      begin
        if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
          begin
            // slave is ready to accept write address when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            axi_awready <= 1'b1;
            aw_en <= 1'b0;
          end
          else if (S_AXI_BREADY && axi_bvalid)
              begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
              end
        else
          begin
            axi_awready <= 1'b0;
          end
      end
  end

  // Implement axi_awaddr latching
  // This process is used to latch the address when both
  // S_AXI_AWVALID and S_AXI_WVALID are valid.
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_awaddr <= 0;
      end
    else
      begin
        if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
          begin
            // Write Address latching
            axi_awaddr <= S_AXI_AWADDR;
          end
      end
  end

  // Implement axi_wready generation
  // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
  // de-asserted when reset is low.
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_wready <= 1'b0;
      end
    else
      begin
        if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
          begin
            // slave is ready to accept write data when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            axi_wready <= 1'b1;
          end
        else
          begin
            axi_wready <= 1'b0;
          end
      end
  end

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
  // Write strobes are used to select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.
  assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        r_buffer <= 1024'b0;
        r_buf_len <= 0;
        r_delay_1st <= DELAY_1ST_DEFAULT;
        r_delay_2nd <= DELAY_2ND_DEFAULT;
        r_pulse_width <= PULSE_WIDTH_DEFAULT;
        r_target_rst_width <= TARGET_NRST_WIDTH_DEFAULT;
        r_control <= 0;
        r_status <= 0;
        r_debug <= 0;
        r_rx_buffer <= 0;
      end
    else begin
      if (i_RX_READY)
        r_rx_buffer <= {r_rx_buffer[23:0], i_RX};
      r_status <= i_STATUS;
      r_debug <= {r_control_wr[1], i_LOCK, 14'b0, i_DEBUG};

      r_control_wr[1]  <= r_control_wr[0];
      if (slv_reg_wren && (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 6'h24) && (S_AXI_WSTRB[0] == 1))
        r_control_wr[0]  <= 1'b1;
      else
        r_control_wr[0]  <= 1'b0;

      if (slv_reg_wren && (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 6'h29) && (S_AXI_WSTRB[0] == 1))
        r_target_rst_pulse  <= 1'b1;
      else
        r_target_rst_pulse  <= 1'b0;

      if (slv_reg_wren)
        begin
          case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            6'h00 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h00*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h01 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h01*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h02 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h02*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h03 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h03*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h04 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h04*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h05 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h05*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h06 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h06*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h07 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h07*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h08 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h08*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h09 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h09*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h0a :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h0a*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h0b :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h0b*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h0c :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h0c*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h0d :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h0d*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h0e :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h0e*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h0f :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h0f*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h10 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h10*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h11 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h11*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h12 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h12*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h13 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h13*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h14 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h14*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h15 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h15*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h16 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h16*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h17 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h17*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h18 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h18*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h19 :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h19*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h1a :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h1a*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h1b :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h1b*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h1c :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h1c*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h1d :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h1d*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h1e :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h1e*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h1f :
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buffer[(10'h1f*32 + byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h20:
              if (!i_LOCK)
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    r_buf_len[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
            6'h21:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes
                  r_delay_1st[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
            6'h22:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes
                  r_delay_2nd[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
            6'h23:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes
                  r_pulse_width[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
            6'h24:
                 if ( S_AXI_WSTRB[0] == 1 ) begin
                   // Respective byte enables are asserted as per write strobes
                  r_control[7:0] <= S_AXI_WDATA[0 +: 8];
                end
            // 6'h25: STATUS is read only
            // 6'h26: RX Buffer is read only
            // 6'h27: DEBUG is read only
            6'h28:
              for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                  // Respective byte enables are asserted as per write strobes
                  r_target_rst_width[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
            default :
              begin
                r_debug <= r_debug;
              end
          endcase
        end
    end
  end

  // Implement write response logic generation
  // The write response and response valid signals are asserted by the slave
  // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
  // This marks the acceptance of address and indicates the status of
  // write transaction.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_bvalid  <= 0;
        axi_bresp   <= 2'b0;
      end
    else
      begin
        if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
          begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response
          end                   // work error responses in future
        else
          begin
            if (S_AXI_BREADY && axi_bvalid)
              //check if bready is asserted while bvalid is high)
              //(there is a possibility that bready is always asserted high)
              begin
                axi_bvalid <= 1'b0;
              end
          end
      end
  end

  // Implement axi_arready generation
  // axi_arready is asserted for one S_AXI_ACLK clock cycle when
  // S_AXI_ARVALID is asserted. axi_awready is
  // de-asserted when reset (active low) is asserted.
  // The read address is also latched when S_AXI_ARVALID is
  // asserted. axi_araddr is reset to zero on reset assertion.

  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_arready <= 1'b0;
        axi_araddr  <= 32'b0;
      end
    else
      begin
        if (~axi_arready && S_AXI_ARVALID)
          begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            // Read address latching
            axi_araddr  <= S_AXI_ARADDR;
          end
        else
          begin
            axi_arready <= 1'b0;
          end
      end
  end

  // Implement axi_arvalid generation
  // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_ARVALID and axi_arready are asserted. The slave registers
  // data are available on the axi_rdata bus at this instance. The
  // assertion of axi_rvalid marks the validity of read data on the
  // bus and axi_rresp indicates the status of read transaction.axi_rvalid
  // is deasserted on reset (active low). axi_rresp and axi_rdata are
  // cleared to zero on reset (active low).
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_rvalid <= 0;
        axi_rresp  <= 0;
      end
    else
      begin
        if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
          begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
          end
        else if (axi_rvalid && S_AXI_RREADY)
          begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
          end
      end
  end

  // Implement memory mapped register select and read logic generation
  // Slave register read enable is asserted when valid address is available
  // and the slave is ready to accept the read address.
  assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
  always @(*)
  begin
    // Address decoding for reading registers
    case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
      6'h00   : reg_data_out <= r_buffer[10'h00*32 +: 32];
      6'h01   : reg_data_out <= r_buffer[10'h01*32 +: 32];
      6'h02   : reg_data_out <= r_buffer[10'h02*32 +: 32];
      6'h03   : reg_data_out <= r_buffer[10'h03*32 +: 32];
      6'h04   : reg_data_out <= r_buffer[10'h04*32 +: 32];
      6'h05   : reg_data_out <= r_buffer[10'h05*32 +: 32];
      6'h06   : reg_data_out <= r_buffer[10'h06*32 +: 32];
      6'h07   : reg_data_out <= r_buffer[10'h07*32 +: 32];
      6'h08   : reg_data_out <= r_buffer[10'h08*32 +: 32];
      6'h09   : reg_data_out <= r_buffer[10'h09*32 +: 32];
      6'h0a   : reg_data_out <= r_buffer[10'h0a*32 +: 32];
      6'h0b   : reg_data_out <= r_buffer[10'h0b*32 +: 32];
      6'h0c   : reg_data_out <= r_buffer[10'h0c*32 +: 32];
      6'h0d   : reg_data_out <= r_buffer[10'h0d*32 +: 32];
      6'h0e   : reg_data_out <= r_buffer[10'h0e*32 +: 32];
      6'h0f   : reg_data_out <= r_buffer[10'h0f*32 +: 32];
      6'h10   : reg_data_out <= r_buffer[10'h10*32 +: 32];
      6'h11   : reg_data_out <= r_buffer[10'h11*32 +: 32];
      6'h12   : reg_data_out <= r_buffer[10'h12*32 +: 32];
      6'h13   : reg_data_out <= r_buffer[10'h13*32 +: 32];
      6'h14   : reg_data_out <= r_buffer[10'h14*32 +: 32];
      6'h15   : reg_data_out <= r_buffer[10'h15*32 +: 32];
      6'h16   : reg_data_out <= r_buffer[10'h16*32 +: 32];
      6'h17   : reg_data_out <= r_buffer[10'h17*32 +: 32];
      6'h18   : reg_data_out <= r_buffer[10'h18*32 +: 32];
      6'h19   : reg_data_out <= r_buffer[10'h19*32 +: 32];
      6'h1a   : reg_data_out <= r_buffer[10'h1a*32 +: 32];
      6'h1b   : reg_data_out <= r_buffer[10'h1b*32 +: 32];
      6'h1c   : reg_data_out <= r_buffer[10'h1c*32 +: 32];
      6'h1d   : reg_data_out <= r_buffer[10'h1d*32 +: 32];
      6'h1e   : reg_data_out <= r_buffer[10'h1e*32 +: 32];
      6'h1f   : reg_data_out <= r_buffer[10'h1f*32 +: 32];
      6'h20   : reg_data_out <= r_buf_len;
      6'h21   : reg_data_out <= r_delay_1st;
      6'h22   : reg_data_out <= r_delay_2nd;
      6'h23   : reg_data_out <= r_pulse_width;
      6'h24   : reg_data_out <= r_control;
      6'h25   : reg_data_out <= r_status;
      6'h26   : reg_data_out <= r_rx_buffer;
      6'h27   : reg_data_out <= r_debug;
      6'h28   : reg_data_out <= r_target_rst_width;
      default : reg_data_out <= 0;
    endcase
  end

  // Output register or memory read data
  always @( posedge S_AXI_ACLK )
  begin
    if ( S_AXI_ARESETN == 1'b0 )
      begin
        axi_rdata  <= 0;
      end
    else
      begin
        // When there is a valid read address (S_AXI_ARVALID) with
        // acceptance of read address by the slave (axi_arready),
        // output the read dada
        if (slv_reg_rden)
          begin
            axi_rdata <= reg_data_out;     // register read data
          end
      end
  end

endmodule
