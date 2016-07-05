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

   wire Clock = CLK;
   wire Reset = RST;

   assign TX = 1'b1;

   assign Buzz = buzzer;
   assign LD = {als_illum[3:0],dist[14:9]};

   reg buzzer;

   assign SCLK = acl_ed ? als_clk : acl_clk;

   reg als_fetch;
   wire als_ready, als_clk;
   wire [7:0] als_illum;

   reg acl_fetch;
   wire acl_ready, acl_clk;
   wire [23:0] acl_acc;

   wire [31:0] dist;

   PmodALS als(
      .Clock(Clock), .Reset(Reset),
      .ready(als_ready), .fetch(als_fetch),
      .als_illum(als_illum),
      .SCLK(als_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ALS));
   PmodACL2 acl(
      .Clock(Clock), .Reset(Reset),
      .ready(acl_ready), .fetch(acl_fetch),
      .acc(acl_acc),
      .SCLK(acl_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ACL2));
   Ultrasonic us(
      .Clock(Clock), .Reset(Reset),
      .dist(dist), .Trig(Trig_US), .Echo(Echo_US));

   reg buf_ena;
   reg [4:0] buf_pc;
   reg [7:0] buf_data;
   wire [7:0] buf_Q;

   ram #(.N(8), .M(5)) tx_buf(
      .Clock(Clock),
      .WE(buf_ena), .A(buf_pc),
      .D(buf_data), .Q(buf_Q));

   reg uart_trig;
   wire uart_idle;
   wire uart_arr;
   reg [7:0] uart_data;
   wire [7:0] uart_recv;

   UART_WriteD UART_WriteD_inst(
      .Clock(Clock), .Reset(Reset),
      .ready(uart_idle), .send(uart_trig),
      .data(uart_data),
      .TX(RXD_Bluetooth));

   UART_ReadD UART_ReadD_inst(
      .Clock(Clock), .Reset(Reset),
      .arrived(uart_arr), .data(uart_recv),
      .RX(TXD_Bluetooth));

   wire ena_5hz;
   divx_short #(5000000) divx_5Hz(.Clock(Clock), .Reset(Reset), .ena(ena_5hz));

   always @(posedge Clock, negedge Reset)
      if(~Reset)
         buzzer <= 1'b1;
      else if(uart_arr)
         case (uart_recv)
            8'h88: buzzer <= 1'b0;
            8'h99: buzzer <= 1'b1;
         endcase

endmodule
