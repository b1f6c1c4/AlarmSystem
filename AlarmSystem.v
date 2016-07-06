`default_nettype none
module AlarmSystem(
   input CLK,
   input RST,
   output [9:0] LD,
   output reg Buzz,
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
   wire Reset;

   rst_recover rc(.Clock(Clock), .RST(RST), .Reset(Reset));

   assign LD = {als_illum[3:0],us_dist[14:9]};

   wire als_clk_ena, acl_clk_ena;
   assign SCLK = als_clk_ena & als_clk |
                 acl_clk_ena & acl_clk;

   wire als_fetch;
   wire als_ready, als_clk, als_arr;
   wire [7:0] als_illum;

   wire acl_fetch;
   wire acl_ready, acl_clk, acl_arr;
   wire [31:0] acl_acc;

   wire [31:0] us_dist;
   wire [31:0] us_dist_buf;

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

   wire uart_trig;
   wire uart_ready, uart_fini;
   wire [7:0] uart_data;

   UART_WriteD UART_WriteD_inst(
      .Clock(Clock), .Reset(Reset),
      .ready(uart_ready), .send(uart_trig), .finish(uart_fini),
      .data(uart_data),
      .TX(RXD_Bluetooth));

   wire uart_arr;
   wire [7:0] uart_recv;

   UART_ReadD UART_ReadD_inst(
      .Clock(Clock), .Reset(Reset),
      .arrived(uart_arr), .data(uart_recv),
      .RX(TXD_Bluetooth));

   wire main_ena;
   divx_short #(5000000) divx_5Hz(.Clock(Clock), .Reset(Reset), .ena(main_ena));

   always @(posedge Clock, negedge Reset)
      if(~Reset)
         Buzz <= 1'b1;
      else if(uart_arr)
         case (uart_recv)
            8'h88: Buzz <= 1'b0;
            8'h99: Buzz <= 1'b1;
         endcase

   Main cont(
      .Clock(Clock),
      .Reset(Reset),
      .main_ena(main_ena),
      // buzzer
      .buzzer(Buzz),
      // PmodALS
      .als_ready(als_ready),
      .als_fetch(als_fetch),
      .als_arr(als_arr),
      .als_illum(als_illum),
      // PmodACL2
      .acl_ready(acl_ready),
      .acl_fetch(acl_fetch),
      .acl_arr(acl_arr),
      .acl_acc(acl_acc),
      // SPI Mux
      .als_clk_ena(als_clk_ena),
      .acl_clk_ena(acl_clk_ena),
      // Ultrasonic
      .us_dist(us_dist),
      // UART
      .uart_ready(uart_ready),
      .uart_trig(uart_trig),
      .uart_fini(uart_fini),
      .uart_data(uart_data));

endmodule
