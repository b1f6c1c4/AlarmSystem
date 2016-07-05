`default_nettype none
module AlarmSystem(
   input CLK,
   input RST,
   output [9:0] LD,
   output Buzz,
   input RX,
   output TX,
   input TXD_Bluetooth,
   output RXD_Bluetooth,
   output SCLK,
   input MISO,
   output MOSI,
   output CS_ALS,
   output CS_ACL2,
   output Trig_US,
   input Echo_US);
   localparam S_INIT = 4'h8;
   localparam S_IDLE = 4'h0;
   localparam S_WINI = 4'h1;
   localparam S_RALS = 4'h2;
   localparam S_WALS = 4'h3;
   localparam S_RACL = 4'h4;
   localparam S_WAC0 = 4'h5;
   localparam S_WAC1 = 4'h6;
   localparam S_WAC2 = 4'h7;
   localparam S_WUS0 = 4'h9;
   localparam S_WUS1 = 4'ha;
   localparam S_WUS2 = 4'hb;
   localparam S_WUS3 = 4'hc;
   localparam S_WFLG = 4'hd;
   localparam S_LOAD = 4'he;
   localparam S_SCHK = 4'hf;

   wire Clock = CLK;
   wire Reset = RST;

   assign TX = 1'b1;

   assign Buzz = buzzer;
   assign LD = {als_illum[3:0],us_dist[14:9]};

   reg buzzer;

   reg als_clk_ena, acl_clk_ena;
   assign SCLK = als_clk_ena & als_clk |
                 acl_clk_ena & acl_clk;

   reg als_fetch;
   wire als_ready, als_clk, als_arr;
   wire [7:0] als_illum;

   reg acl_fetch;
   wire acl_ready, acl_clk, acl_arr;
   wire [23:0] acl_acc;

   wire [31:0] us_dist;
   reg [31:0] us_dist_buf;

   PmodALS als(
      .Clock(Clock), .Reset(Reset),
      .ready(als_ready), .fetch(als_fetch), .arrived(als_arr),
      .illum(als_illum),
      .SCLK(als_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ALS));
   PmodACL2 acl(
      .Clock(Clock), .Reset(Reset),
      .ready(acl_ready), .fetch(acl_fetch), .arrived(acl_arr),
      .acc(acl_acc),
      .SCLK(acl_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ACL2));
   Ultrasonic us(
      .Clock(Clock), .Reset(Reset),
      .dist(us_dist), .Trig(Trig_US), .Echo(Echo_US));

   reg buf_ena;
   reg [3:0] buf_pc;
   reg [7:0] buf_data;
   wire [7:0] buf_Q;
   reg [7:0] chk_byte;

   ram #(.N(8), .M(4)) tx_buf(
      .Clock(Clock),
      .WE(buf_ena), .A(buf_pc),
      .D(buf_data), .Q(buf_Q));

   reg uart_trig;
   wire uart_ready, uart_arr, uart_fini;
   reg [7:0] uart_data;
   wire [7:0] uart_recv;

   UART_WriteD UART_WriteD_inst(
      .Clock(Clock), .Reset(Reset),
      .ready(uart_ready), .send(uart_trig), .finish(uart_fini),
      .data(uart_data),
      .TX(RXD_Bluetooth));

   UART_ReadD UART_ReadD_inst(
      .Clock(Clock), .Reset(Reset),
      .arrived(uart_arr), .data(uart_recv),
      .RX(TXD_Bluetooth));

   wire main_ena;
   divx_short #(5000000) divx_5Hz(.Clock(Clock), .Reset(Reset), .ena(main_ena));

   always @(posedge Clock, negedge Reset)
      if(~Reset)
         buzzer <= 1'b1;
      else if(uart_arr)
         case (uart_recv)
            8'h88: buzzer <= 1'b0;
            8'h99: buzzer <= 1'b1;
         endcase

   reg [3:0] state;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         chk_byte <= 8'b0;
      else if (state == S_IDLE)
         chk_byte <= 8'b0;
      else if (buf_ena)
         chk_byte <= chk_byte ^ buf_data;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         begin
            state <= S_INIT;
            als_clk_ena <= 1'b0;
            acl_clk_ena <= 1'b1;
            als_fetch <= 1'b0;
            acl_fetch <= 1'b0;
            us_dist_buf <= 32'b0;
            buf_ena <= 1'b0;
            buf_pc <= 4'b0;
            buf_data <= 8'b0;
            uart_trig <= 1'b0;
            uart_data <= 8'b0;
         end
      else
         case (state)
            S_INIT:
               if (acl_ready)
                  begin
                     state <= S_IDLE;
                     acl_clk_ena <= 1'b0;
                  end
            S_IDLE:
               if (main_ena)
                  begin
                     state <= S_WINI;
                     buf_ena <= 1'b1;
                     buf_pc <= 4'b0;
                     buf_data <= 8'h5a;
                  end
            S_WINI:
               begin
                  state <= S_RALS;
                  buf_ena <= 1'b0;
                  buf_pc <= buf_pc + 4'b1;
               end
            S_RALS:
               if (als_arr)
                  begin
                     state <= S_WALS;
                     als_clk_ena <= 1'b0;
                     buf_ena <= 1'b1;
                     buf_data <= als_illum;
                  end
               else if (als_ready)
                  begin
                     als_clk_ena <= 1'b1;
                     als_fetch <= 1'b1;
                  end
               else
                  als_fetch <= 1'b0;
            S_WALS:
               begin
                  state <= S_RACL;
                  buf_ena <= 1'b0;
                  buf_pc <= buf_pc + 4'b1;
               end
            S_RACL:
               if (acl_arr)
                  begin
                     state <= S_WAC0;
                     acl_clk_ena <= 1'b0;
                     buf_ena <= 1'b1;
                     buf_data <= acl_acc[23:16];
                  end
               else if (acl_ready)
                  begin
                     acl_clk_ena <= 1'b1;
                     acl_fetch <= 1'b1;
                  end
               else
                  acl_fetch <= 1'b0;
            S_WAC0:
               begin
                  state <= S_WAC1;
                  buf_pc <= buf_pc + 4'b1;
                  buf_data <= acl_acc[15:8];
               end
            S_WAC1:
               begin
                  state <= S_WAC2;
                  buf_pc <= buf_pc + 4'b1;
                  buf_data <= acl_acc[7:0];
               end
            S_WAC2:
               begin
                  state <= S_WUS0;
                  us_dist_buf <= us_dist;
                  buf_pc <= buf_pc + 4'b1;
                  buf_data <= us_dist_buf[31:24];
               end
            S_WUS0:
               begin
                  state <= S_WUS1;
                  buf_pc <= buf_pc + 4'b1;
                  buf_data <= us_dist_buf[23:16];
               end
            S_WUS1:
               begin
                  state <= S_WUS2;
                  buf_pc <= buf_pc + 4'b1;
                  buf_data <= us_dist_buf[15:8];
               end
            S_WUS2:
               begin
                  state <= S_WUS3;
                  buf_pc <= buf_pc + 4'b1;
                  buf_data <= us_dist_buf[7:0];
               end
            S_WUS3:
               begin
                  state <= S_WFLG;
                  buf_pc <= buf_pc + 4'b1;
                  buf_data <= {7'b0,~buzzer};
               end
            S_WFLG:
               begin
                  state <= S_LOAD;
                  buf_ena <= 1'b0;
                  buf_pc <= 4'b0;
               end
            S_LOAD:
               if (uart_fini && buf_pc == 4'd10 - 4'b1)
                  state <= S_SCHK;
               else if (uart_ready)
                  begin
                     uart_trig <= 1'b1;
                     uart_data <= buf_Q;
                     buf_pc <= buf_pc + 4'b1;
                  end
               else
                  uart_trig <= 1'b0;
            S_SCHK:
               if (uart_fini)
                  state <= S_IDLE;
               else if (uart_ready)
                  begin
                     uart_trig <= 1'b1;
                     uart_data <= chk_byte;
                  end
               else
                  uart_trig <= 1'b0;
         endcase

endmodule
