`default_nettype none
module PmodALS_Demo(
   input Clock,
   input Reset,
   input [7:0] illumValue,
   output ready,
   input fetch,
   output arrived,
   output [7:0] illum,
   output SCLK,
   output MISO,
   output MOSI,
   output CS);

   PmodALS mdl(
      .Clock(Clock), .Reset(Reset),
      .ready(ready), .fetch(fetch), .arrived(arrived),
      .illum(illum),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS));

   SPI_Slave #(16) slave(
      .Clock(Clock), .Reset(Reset),
      .data({4'b0,illumValue,4'b0}),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS));

endmodule
