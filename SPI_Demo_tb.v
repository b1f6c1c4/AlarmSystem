`default_nettype none
`timescale 10ns/1ps
module SPI_Demo_tb;

   reg Clock;
   reg Reset;
   wire ready;
   reg send;
   wire arrived;
   reg [7:0] data;
   wire [7:0] dataO;
   wire arrivedS;
   reg [7:0] dataS;
   wire [7:0] dataSO;
   wire SCLK;
   wire MISO;
   wire MOSI;
   wire CS;

   SPI_Demo mdl(Clock, Reset, ready, send, arrived, data, dataO, arrivedS, dataS, dataSO, SCLK, MISO, MOSI, CS);

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
         dataS = 8'bx;
      end

   task automatic exchangeData(input [7:0] d, input [7:0] q);
      begin
         wait(ready);
         #1 send = 1'b1;
         data = d;
         dataS = q;
         #4 send = 1'b0;
         fork
            wait(arrived) $display("MISO: %b -> %b (%b)", q, dataO, q == dataO);
            wait(arrivedS) $display("MOSI: %b -> %b (%b)", d, dataSO, d == dataSO);
         join
         #2;
      end
   endtask

   initial
      begin
         #4;
         exchangeData(8'b01000010, 8'b00101011);
         exchangeData(8'b10101010, 8'b01010110);
         exchangeData(8'b01000101, 8'b11100011);
         exchangeData(8'b01110010, 8'b10001111);
         exchangeData(8'b11110011, 8'b11001101);
         exchangeData(8'b01010010, 8'b00101001);
         exchangeData(8'b11001110, 8'b10001110);
         exchangeData(8'b01110111, 8'b10111001);
         exchangeData(8'b00001010, 8'b01101001);
         exchangeData(8'b10010010, 8'b01101101);
         exchangeData(8'b01101011, 8'b00101011);
         #4 $finish;
      end

endmodule
