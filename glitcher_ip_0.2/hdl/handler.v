`timescale 1ns / 1ps

module handler #(
    parameter integer TRIGGER_MIN_CNT = 16
  )
  (
    input i_CLK,
    input i_RST_N,
    input [7:0] i_CONTROL,
    input i_CONTROL_WR,
    input i_TRIGGER,
    input [7:0] i_RX,
    input i_RX_READY,
    input [31:0] i_DELAY_1ST,
    input [31:0] i_DELAY_2ND,
    input [31:0] i_PULSE_WIDTH,
    input [1023:0] i_BUFFER,
    input [6:0] i_BUF_LEN,

    output [31:0]  o_STATUS,
    output [15:0]  o_DEBUG,
    output o_LOCK,
    output o_STOP_N,
    output o_TRIGGER
  );

  parameter c_IDLE         = 8'h00;
  parameter c_RUN_ONCE     = 8'h01;
  parameter c_RUN          = 8'h02;
  parameter c_UART         = 8'h00;
  parameter c_TRIGGER      = 8'h10;

  parameter c_RUN_MASK     = 2'h3;

  parameter s_IDLE         = 4'b000;
  parameter s_WAIT_UART    = 4'b001;
  parameter s_SETUP        = 4'b010;
  parameter s_WAIT_TRIGGER = 4'b011;
  parameter s_PULSE        = 4'b100;

  parameter e_SUCCESS               = 8'h00000;
  parameter e_ERR_DELAYS_ZERO       = 8'b00001;
  parameter e_ERR_BUF_LEN           = 8'b00010;
  parameter e_ERR_PULSE_WIDTH_ZERO  = 8'b00011;
  parameter e_ERR_STOPPED           = 8'b00100;

  // output
  reg r_trigger = 1'b0;
  reg r_stop_n  = 1'b1;

  reg [7:0] r_control = 8'h00;
  reg r_lock = 1'b1;

  // UART data idx
  reg [6:0] r_idx;

  // state
  reg [2:0] r_state = s_IDLE;
  reg [4:0] r_status = 5'h0;
  reg [7:0] r_debug = 8'h0;

  // TRIGGER
  reg [TRIGGER_MIN_CNT - 1:0] r_trigger_sampled = 16'hff;
  reg r_trigger_buffer = 1'b1;
  reg r_control_wr = 1'b0;
  reg r_control_sample = 1'b0;

  wire trigger_in_posedge = r_trigger_buffer & r_trigger_sampled == 16'h00;
  wire [1:0] run = i_CONTROL[1:0] & 2'b11;
  wire control_wr_posedge = i_CONTROL_WR & ~r_control_wr;

  assign o_TRIGGER = r_trigger;
  assign o_STOP_N = r_stop_n;
  assign o_STATUS = {r_lock, r_control[7], 25'b0, r_status};
  assign o_LOCK = r_lock;
  assign o_DEBUG = {r_debug, 3'b0, r_state};

  always @ (posedge i_CLK) begin
    if (i_RST_N == 1'b0) begin
      r_state <= s_IDLE;
      r_status <= e_SUCCESS;

      r_trigger <= 1'b0;
      r_stop_n <= 1'b0;
      r_lock <= 1'b0;

      r_trigger_sampled = 16'hff;
      r_trigger_buffer = 1'b1;
    end else begin // not RST_N
      r_control_wr <= i_CONTROL_WR;
      r_debug[2:0] <= {r_control_wr, r_control_sample, i_CONTROL_WR};
      r_trigger_buffer <= i_TRIGGER;
      r_trigger_sampled <= { r_trigger_sampled[TRIGGER_MIN_CNT - 2:0],  r_trigger_buffer};

      case (r_state)
        s_IDLE: begin
          r_stop_n <= 1'b1;
          r_trigger <= 1'b0;
          r_lock <= 1'b0;
          r_control <= 0;
          if (control_wr_posedge && run)
            r_state <= s_SETUP;
        end

        s_SETUP: begin
          r_stop_n <= 1'b1;
          r_control <= i_CONTROL;
          r_lock <= 1'b0;
          if ((i_DELAY_1ST || i_DELAY_2ND) && i_PULSE_WIDTH) begin
            if (i_CONTROL & c_TRIGGER) begin
              r_state <= s_WAIT_TRIGGER;
              r_status <= e_SUCCESS;
              r_lock <= 1'b1;
            end else begin
              if (i_BUF_LEN) begin
                r_state <= s_WAIT_UART;
                r_status <= e_SUCCESS;
                r_lock <= 1'b1;
                r_idx <= 7'h00;
              end else begin
                r_status <= e_ERR_BUF_LEN;
                r_state <= s_IDLE;
              end
            end
          end else begin
            if (!i_PULSE_WIDTH)
              r_status <= e_ERR_PULSE_WIDTH_ZERO;
            else
              r_status <= e_ERR_DELAYS_ZERO;
            r_state <= s_IDLE;
          end
        end  // s_IDLE

        s_WAIT_TRIGGER: begin
          if (control_wr_posedge) begin  // restart
            r_stop_n <= 1'b0;
            r_lock <= 1'b0;
            r_status <= e_ERR_STOPPED;
            if (run)
              r_state <= s_SETUP;
            else
              r_state <= s_IDLE;
          end else begin
            if (trigger_in_posedge) begin
              r_state <= s_PULSE;
              r_trigger <= 1'b1;
            end else
              r_trigger = 1'b0;
          end
        end  // s_WAIT_TRIGGER

        s_WAIT_UART: begin
          if (control_wr_posedge) begin  // restart
            r_stop_n <= 1'b0;
            r_lock <= 1'b0;
            r_status <= e_ERR_STOPPED;
            if (run)
              r_state <= s_SETUP;
            else
              r_state <= s_IDLE;
          end else begin
            if (i_RX_READY) begin
              if (i_RX == i_BUFFER[r_idx * 8 +: 8]) begin
                if (r_idx == i_BUF_LEN - 1) begin // last symbol?
                  r_idx <= 7'h0;
                  r_state <= s_PULSE;
                  r_trigger <= 1'b1;
                end else begin   // not a last one
                  r_idx <= r_idx + 1;
                  r_trigger = 1'b0;
                end
              end else begin // RX does not match
                r_idx <= 7'h00;
                r_trigger = 1'b0;
              end
            end
          end
        end  // s_WAIT_UART

        s_PULSE: begin
          if (control_wr_posedge) begin  // restart
            r_stop_n <= 1'b0;
            r_lock <= 1'b0;
            r_status <= e_ERR_STOPPED;
            if (run)
              r_state <= s_SETUP;
            else
              r_state <= s_IDLE;
          end else begin
            r_trigger = 1'b0;
            r_idx <= 0;
            if (r_control & c_RUN) begin
              if (r_control & c_TRIGGER)
                r_state = s_WAIT_TRIGGER;
              else
                r_state = s_WAIT_UART;
            end else begin
              r_state <= s_IDLE;
              r_status <= e_SUCCESS;
              r_lock <= 1'b0;
            end
          end
        end  // s_PULSE

        default: begin
          r_state <= s_IDLE;
          r_trigger <= 1'b0;
          r_lock <= 1'b0;
          r_stop_n <= 1'b0;
        end
      endcase
    end  // not RST_N
  end  // always
endmodule

