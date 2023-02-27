`timescale 1ns / 1ps

module delayer #(
    parameter BASE_DELAY = 32'h1,
    parameter INIT_TRIG_STATE = 1'b0
  )(
    input i_CLK,
    input i_RST_N,
    input i_TRIGGER,
    input [31:0] i_DELAY,
    input [31:0] i_WIDTH,
    output o_RUN,
    output o_TRIGGER
  );

  parameter s_IDLE         = 2'b00;
  parameter s_INIT         = 2'b01;
  parameter s_DELAY        = 2'b10;
  parameter s_PULSE        = 2'b11;

  reg r_trig_sample = INIT_TRIG_STATE;
  reg r_trigger = 1'b0;
  reg r_run = 1'b0;
  reg [31:0] r_delay;
  reg [31:0] r_width;

  reg [31:0] r_cur_cnt;

  reg [2:0] r_state = s_IDLE;

  wire trig_posedge = i_TRIGGER & ~r_trig_sample;
  assign o_TRIGGER = r_trigger;
  assign o_RUN = r_run;

  always @ (posedge i_CLK) begin
    if (i_RST_N == 1'b0) begin
      r_state <= s_IDLE;
      r_cur_cnt = BASE_DELAY;
      r_delay <= 0;
      r_width <= 0;

      r_trig_sample <= INIT_TRIG_STATE;
      r_trigger <= 1'b0;
      r_run <= 1'b0;
    end else begin
      r_trig_sample <= i_TRIGGER;

      case (r_state)
        s_IDLE: begin
          if (trig_posedge) begin
            if (i_WIDTH) begin
              r_run <= 1'b1;
              r_width <= i_WIDTH;
              if (i_DELAY) begin
                r_trigger <= 1'b0;
                r_state <= s_DELAY;
                r_delay <= i_DELAY;
                r_cur_cnt = BASE_DELAY;
              end else begin
                r_trigger <= 1'b1;
                r_cur_cnt = 32'h1;
                r_state <= s_PULSE;
              end
            end else begin  // WIDTH
              r_trigger <= 1'b0;
              r_run <= 1'b0;
            end
          end else begin  // trig_posedge
            r_trigger <= 1'b0;
            r_run <= 1'b0;
          end
        end  // s_IDLE

        s_DELAY: begin
          if (r_cur_cnt < r_delay) begin
            r_cur_cnt <= r_cur_cnt + 1;
          end else begin
            r_cur_cnt <= 32'h1;

            r_state <= s_PULSE;
            r_trigger <= 1'b1;
          end
        end  // s_DELAY_1ST

        s_PULSE: begin
          if (r_cur_cnt < r_width) begin
            r_cur_cnt <= r_cur_cnt + 1;
          end else begin
            r_state <= s_IDLE;
            r_trigger <= 1'b0;
            r_run <= 1'b0;
          end
        end  // s_PULSE

        default: begin
          r_state <= s_IDLE;
          r_trigger <= 1'b0;
          r_run <= 1'b0;
        end
      endcase
    end
  end
endmodule
