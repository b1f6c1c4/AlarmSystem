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
   input INT_ACL2,
   output Trig_US,
   input Echo_US);

   wire Clock = CLK;
   wire Reset = RST;

   assign TX = 1'b1;

   assign Buzz = buzzer;
   assign LD = {INT_ACL2,illum[3:0],dist[13:9]};

   reg buzzer;

   wire als_clk, acl_clk, acl_ed;
   wire [7:0] illum;
   assign SCLK = acl_ed ? als_clk : acl_clk;
   wire [31:0] dist;

   PmodALS als(
      .Clock(Clock), .Reset(acl_ed), .illum(illum),
      .SCLK(als_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ALS));
   PmodACL2 acl(
      .Clock(Clock), .Reset(Reset), .done(acl_ed),
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
   divx_short #(5000000) divx_1Hz(.Clock(Clock), .Reset(Reset), .ena(ena_5hz));

   always @(posedge Clock, negedge Reset)
      if(~Reset)
         buzzer <= 1'b1;
      else if(uart_arr)
         case (uart_recv)
            8'h88: buzzer <= 1'b0;
            8'h99: buzzer <= 1'b1;
         endcase

endmodule
