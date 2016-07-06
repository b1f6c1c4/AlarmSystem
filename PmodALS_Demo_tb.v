`default_nettype none
`timescale 10ns/1ps
module PmodALS_Demo_tb;

   reg Clock;
   reg Reset;
   reg [7:0] illumValue;
   wire ready;
   reg fetch;
   wire arrived;
   wire [7:0] illum;
   wire SCLK;
   wire MISO;
   wire MOSI;
   wire CS;

   PmodALS_Demo mdl(Clock, Reset, illumValue, ready, fetch, arrived, illum, SCLK, MISO, MOSI, CS);

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
         fetch = 1'b0;
         illumValue = 8'bx;
      end

   task automatic fetchData(input [7:0] d);
      begin
         @(posedge Clock) while (~ready) @(posedge Clock);
         fetch = 1'b1;
         illumValue = d;
         @(posedge Clock) fetch = 1'b0;
         @(posedge Clock) while (~arrived) @(posedge Clock);
         $display("PmodALS: %b -> %b (%b)", d, illum, d == illum);
      end
   endtask

   initial
      begin
         fetchData(8'b01000010);
         fetchData(8'b10101010);
         fetchData(8'b01000101);
         fetchData(8'b01110010);
         fetchData(8'b11110011);
         fetchData(8'b01010010);
         fetchData(8'b11001110);
         fetchData(8'b01110111);
         fetchData(8'b00001010);
         fetchData(8'b10010010);
         fetchData(8'b01101011);
         $finish;
      end

endmodule
