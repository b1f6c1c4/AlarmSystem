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

   reg uart_trig;
   wire uart_idle;
   wire uart_arr;
   wire [7:0] uart_recv;
   reg [63:0] uart_buffer;
   reg [3:0] uart_num;

   UART_N UART_WriteN_inst(
      .Clock(Clock), .Reset(Reset),
      .buffer(uart_buffer), .num(uart_num),
      .trig_in(uart_trig), .idle(uart_idle),
      .TX(RXD_Bluetooth));

   UART_ReadD UART_READ_inst(
      .Clock(Clock), .Reset(Reset),
      .arrived(uart_arr), .data(uart_recv),
      .RX(TXD_Bluetooth));

   wire ena_5hz;
   divx_short #(5000000) divx_1Hz(.Clock(Clock), .Reset(Reset), .ena(ena_5hz));

   wire [55:0] state_report;
   assign state_report[55:48] = 8'h5a;
   assign state_report[47:16] = dist;
   assign state_report[15:8] = illum;
   assign state_report[7:0] = {6'b0,~buzzer,INT_ACL2};

   always @(posedge Clock ,negedge Reset)
      if (~Reset)
         uart_trig <= 1'b0;
      else if (ena_5hz)
         begin
            uart_buffer <= {
               state_report,
               state_report[55:48] ^
               state_report[47:40] ^
               state_report[39:32] ^
               state_report[31:24] ^
               state_report[23:16] ^
               state_report[15:8] ^
               state_report[7:0]
            };
            uart_num <= 4'd8;
            uart_trig <= 1'b1;
         end
      else
         uart_trig <= 1'b0;

   always @(posedge Clock, negedge Reset)
      if(~Reset)
         buzzer <= 1'b1;
      else if(uart_arr)
         case (uart_recv)
            8'h88: buzzer <= 1'b0;
            8'h99: buzzer <= 1'b1;
         endcase

endmodule
