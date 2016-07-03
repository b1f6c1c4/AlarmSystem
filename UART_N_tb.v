`default_nettype none
`timescale 10ns/1ps
module UART_N_tb;

   reg Clock;
   reg Reset;
   reg [63:0] buffer;
   reg [3:0] num;
   reg trig_in;
   wire idle;
   wire TX;

   UART_N mdl(Clock, Reset, buffer, num, trig_in, idle, TX);

   initial
      begin
         Clock = 1'b1;
         forever
            #2 Clock = ~Clock;
      end

   initial
      begin
         Reset = 1'b0;
         trig_in = 1'b0;
         #2 Reset = 1'b1;
         #4 buffer = 64'h55aaff001248137f;
         num = 4'd8;
         trig_in = 1'b1;
         #4;
         wait(idle);
         #4 $finish;
      end

endmodule
