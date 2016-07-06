`default_nettype none
`timescale 10ns/1ps
module PmodACL2_Demo_tb;

   reg Clock;
   reg Reset;
   reg [7:0] responseValue;
   wire arrivedS;
   wire [7:0] dataSO;
   wire ready;
   reg fetch;
   wire arrived;
   wire [31:0] acc;
   wire SCLK;
   wire MISO;
   wire MOSI;
   wire CS;
   wire rawCS;

   PmodACL2_Demo mdl(Clock, Reset, responseValue, arrivedS, dataSO, ready, fetch, arrived, acc, SCLK, MISO, MOSI, CS, rawCS);

   reg signed [15:0] xT;
   reg signed [15:0] yT;
   reg signed [15:0] zT;
   reg [31:0] accT;

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
         responseValue = 8'bx;
      end

   initial
      forever
         begin
            @(negedge CS) $display("----- Frame begin");
            @(posedge CS) $display("----- Frame end");
         end

   task automatic assertAndReply(input [7:0] assert, input [7:0] reply);
      begin
         responseValue = reply;
         @(posedge Clock) while (~arrivedS) @(posedge Clock);
         $display("MOSI: %b (%b; %b)  MISO: %b", dataSO, assert, dataSO == assert, reply);
      end
   endtask

   task automatic accData(
      input signed [11:0] x,
      input signed [11:0] y,
      input signed [11:0] z);
      begin
         xT = x;
         yT = y;
         zT = z;
         accT = x * x + y * y + z * z;
         @(posedge Clock) while (~ready) @(posedge Clock);
         fetch = 1'b1;
         fork
            @(posedge Clock) fetch = 1'b0;
            begin
               assertAndReply(8'h0b, 8'hxx);
               assertAndReply(8'h0e, 8'hxx);
               assertAndReply(8'hxx, xT[7:0]);
               assertAndReply(8'hxx, xT[15:8]);
               assertAndReply(8'hxx, yT[7:0]);
               assertAndReply(8'hxx, yT[15:8]);
               assertAndReply(8'hxx, zT[7:0]);
               assertAndReply(8'hxx, zT[15:8]);
            end
            begin
               @(posedge Clock) while (~arrived) @(posedge Clock);
               $display("ACC: %b (%b; %b)", acc, accT, acc == $unsigned(accT));
            end
         join
      end
   endtask

   initial
      begin
         assertAndReply(8'h0a, 8'hxx);
         assertAndReply(8'h2d, 8'hxx);
         assertAndReply(8'h22, 8'hxx);

         accData(12'b010001000010, 12'b011001000010, 12'b011001001010);
         accData(12'b010110101010, 12'b010010101010, 12'b010010101010);
         accData(12'b100001000101, 12'b100001010001, 12'b100111000101);
         accData(12'b001101110010, 12'b001101011010, 12'b001100110010);
         accData(12'b000011110011, 12'b000011110011, 12'b000011110011);
         accData(12'b010001010010, 12'b010101000010, 12'b010001010010);
         accData(12'b010011001110, 12'b010010111110, 12'b010111011110);
         accData(12'b000101110111, 12'b000100110111, 12'b000110100111);
         accData(12'b101000001010, 12'b101011011010, 12'b101000101010);
         accData(12'b010010010010, 12'b010010010010, 12'b010010010010);
         accData(12'b101001101011, 12'b101001101011, 12'b101001101011);

         $finish;
      end

endmodule
