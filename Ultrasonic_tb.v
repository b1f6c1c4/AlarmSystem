`default_nettype none
`timescale 10ns/1ps
module Ultrasonic_tb;

   reg Clock;
   reg Reset;
   wire [31:0] dist;
   wire Trig;
   reg Echo;

   Ultrasonic mdl(Clock, Reset, dist, Trig, Echo);

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
      Echo = 1'b0;

   initial
      begin
         #12;
         wait(Trig);
         #123 Echo = 1'b1;
         #(246*4) Echo = 1'b0;
         wait(Trig);
         $display("dist = %d", dist);
         #123 Echo = 1'b1;
         #(666*4) Echo = 1'b0;
         wait(Trig);
         $display("dist = %d", dist);
         #123 Echo = 1'b1;
         #(107*4) Echo = 1'b0;
         wait(Trig);
         $display("dist = %d", dist);
         #123 Echo = 1'b1;
         wait(Trig);
         $display("dist = %d", dist);
         $finish;
      end

endmodule
