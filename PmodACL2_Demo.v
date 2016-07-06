`default_nettype none
`ifdef SIMULATION
module PmodACL2_Demo(
   input Clock,
   input Reset,
   input [7:0] responseValue,
   output arrivedS,
   output [7:0] dataSO,
   output ready,
   input fetch,
   output arrived,
   output [31:0] acc,
   output SCLK,
   output MISO,
   output MOSI,
   output CS,
   output rawCS);

   PmodACL2 mdl(
      .Clock(Clock), .Reset(Reset),
      .ready(ready), .fetch(fetch), .arrived(arrived),
      .acc(acc),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS), .rawCS(rawCS));

   SPI_Slave #(8) slave(
      .Clock(Clock), .Reset(Reset),
      .arrived(arrivedS),
      .data(responseValue), .dataO(dataSO),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(rawCS));

endmodule
`endif
