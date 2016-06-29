`default_nettype none
`timescale 10ns/1ps
module AlarmSystem_tb;
   
   reg Clock;
   reg Reset;
   wire ready;
   reg send;
   reg [7:0] data;
   wire TX;
   wire arrived;
   wire [7:0] dataO;
   
   AlarmSystem mdl(Clock, Reset, ready, send, data, TX, arrived, dataO);
   
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
   task automatic sendByte(input [7:0] d);
      begin
         wait(ready);
         #1 send = 1'b1;
         data = d;
         #4 send = 1'b0;
      end
   endtask
   
   initial
      begin
         #4;
         sendByte(8'b01000010);
         sendByte(8'b10101010);
         sendByte(8'b01000101);
         sendByte(8'b01110010);
         sendByte(8'b11110011);
         sendByte(8'b01010010);
         sendByte(8'b11001110);
         sendByte(8'b01110111);
         sendByte(8'b00001010);
         sendByte(8'b10010010);
         sendByte(8'b01101011);
         wait(ready);
         #4 $finish;
      end
   
endmodule
