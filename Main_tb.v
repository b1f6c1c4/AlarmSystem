`default_nettype none
`timescale 10ns/1ps
module Main_tb;

   reg Clock;
   reg Reset;
   wire ready;
   reg main_ena;
   // buzzer
   reg buzzer;
   // PmodALS
   reg als_ready;
   wire als_fetch;
   reg als_arr;
   reg [7:0] als_illum;
   // PmodACL2
   reg acl_ready;
   wire acl_fetch;
   reg acl_arr;
   reg [31:0] acl_acc;
   // SPI Mux
   wire als_clk_ena;
   wire acl_clk_ena;
   // Ultrasonic
   reg [31:0] us_dist;
   // UART
   reg uart_ready;
   wire uart_trig;
   reg uart_fini;
   wire [7:0] uart_data;

   Main mdl(Clock, Reset, ready, main_ena, buzzer, als_ready, als_fetch, als_arr, als_illum, acl_ready, acl_fetch, acl_arr, acl_acc, als_clk_ena, acl_clk_ena, us_dist, uart_ready, uart_trig, uart_fini, uart_data);

   integer i;
   integer rx_count;
   reg [7:0] rx_buf[0:11];
   reg [7:0] rx_bufT[0:11];

   initial
      begin
         Reset = 1'b0;
         #2 Reset = 1'b1;
      end

   initial
      begin
         Clock = 1'b1;
         forever
            #2 Clock = ~Clock;
      end

   initial
      begin
         main_ena = 1'b0;
      end

   initial
      begin
         als_ready = 1'b0;
         als_arr = 1'b0;
      end
   always @(posedge Clock)
      if (als_fetch && als_clk_ena)
         begin
            als_ready = 1'b0;
            #11;
            @(posedge Clock);
            als_ready = 1'b1;
            als_arr = 1'b1;
         end
      else
         begin
            als_ready = 1'b1;
            als_arr = 1'b0;
         end

   initial
      begin
         acl_ready = 1'b0;
         acl_arr = 1'b0;
      end
   always @(posedge Clock)
      if (acl_fetch && acl_clk_ena)
         begin
            acl_ready = 1'b0;
            #11;
            @(posedge Clock);
            acl_ready = 1'b1;
            acl_arr = 1'b1;
         end
      else
         begin
            acl_ready = 1'b1;
            acl_arr = 1'b0;
         end

   initial
      begin
         uart_ready = 1'b0;
         uart_fini = 1'b0;
      end
   always @(posedge Clock)
      if (uart_trig)
         begin
            uart_ready = 1'b0;
            rx_buf[rx_count] = uart_data;
            #11;
            rx_count = rx_count + 1;
            @(posedge Clock);
            uart_ready = 1'b1;
            uart_fini = 1'b1;
         end
      else
         begin
            uart_ready = 1'b1;
            uart_fini = 1'b0;
         end

   task automatic goMain(
      input bu,
      input [7:0] il,
      input [31:0] ac,
      input [31:0] di);
      begin
         buzzer = bu;
         als_illum = il;
         acl_acc = ac;
         us_dist = di;
         rx_bufT[0] = 8'h5a;
         rx_bufT[1] = il;
         rx_bufT[2] = ac[31:24];
         rx_bufT[3] = ac[23:16];
         rx_bufT[4] = ac[15:8];
         rx_bufT[5] = ac[7:0];
         rx_bufT[6] = di[31:24];
         rx_bufT[7] = di[23:16];
         rx_bufT[8] = di[15:8];
         rx_bufT[9] = di[7:0];
         rx_bufT[10] = bu ? 8'h0 : 8'h1;
         rx_bufT[11] = 8'h0;
         for (i = 0; i < 11; i = i + 1)
            rx_bufT[11] = rx_bufT[11] ^ rx_bufT[i];

         @(posedge Clock) while (~ready) @(posedge Clock);
         $display("buzzer=%b illum=%h acc=%h dist=%h", bu, il, ac, di);
         rx_count = 0;
         main_ena = 1'b1;
         @(posedge Clock) main_ena = 1'b0;
         @(posedge Clock) while (~ready) @(posedge Clock);
         for (i = 0; i < rx_count; i = i + 1)
            $display("TX: %h (%h; %b)", rx_buf[i], rx_bufT[i], rx_buf[i] == rx_bufT[i]);
      end
   endtask

   initial
      begin
         goMain(1'b0, 8'b01000010, 31651654, 38796431);
         goMain(1'b1, 8'b10101010, 1556352, 48974100);
         goMain(1'b0, 8'b01000101, 139956499, 798434);
         goMain(1'b0, 8'b01110010, 234656, 2456522);
         goMain(1'b1, 8'b11110011, 1584, 234685);
         goMain(1'b0, 8'b01010010, 496365, 6784563);
         goMain(1'b0, 8'b11001110, 14534, 356754);
         goMain(1'b0, 8'b01110111, 498345, 1284570);
         goMain(1'b1, 8'b00001010, 125730, 20571);
         goMain(1'b0, 8'b10010010, 12354, 1485);
         goMain(1'b0, 8'b01101011, 1203423233, 123470237);

         $finish;
      end

endmodule
