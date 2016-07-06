`default_nettype none
`timescale 10ns/1ps
module UART_Demo_tb;

   reg Clock;
   reg Reset;
   wire ready;
   reg send;
   wire finish;
   reg [7:0] data;
   wire arrivedR;
   wire [7:0] dataR;
   wire RXTX;

   UART_Demo mdl(Clock, Reset, ready, send, finish, data, arrivedR, dataR, RXTX);

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
         send = 1'b0;
         data = 8'bx;
      end

   task automatic sendData(input [7:0] d);
      begin
         @(posedge Clock) while (~ready) @(posedge Clock);
         send = 1'b1;
         data = d;
         @(posedge Clock) send = 1'b0;
         @(posedge Clock) while (~arrivedR) @(posedge Clock);
         $display("TX: %b -> %b :RX (%b)", d, dataR, d == dataR);
      end
   endtask

   initial
      begin
         sendData(8'b01000010);
         sendData(8'b10101010);
         sendData(8'b01000101);
         sendData(8'b01110010);
         sendData(8'b11110011);
         sendData(8'b01010010);
         sendData(8'b11001110);
         sendData(8'b01110111);
         sendData(8'b00001010);
         sendData(8'b10010010);
         sendData(8'b01101011);
         $finish;
      end

endmodule
