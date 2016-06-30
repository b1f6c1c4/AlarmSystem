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
         #120 Echo = 1'b1;
         #512 Echo = 1'b0;
         #200 $finish;
      end
   
endmodule
