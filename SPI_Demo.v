`default_nettype none
module SPI_Demo(
   input Clock,
   input Reset,
   output ready,
   input send,
   output arrived,
   input [7:0] data,
   output [7:0] dataO,
   output arrivedS,
   input [7:0] dataS,
   output [7:0] dataSO,
   output SCLK,
   output MISO,
   output MOSI,
   output CS);

   SPI_Master #(8) master(
      .Clock(Clock), .Reset(Reset),
      .ready(ready), .send(send), .arrived(arrived),
      .data(data), .dataO(dataO),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS));

   SPI_Slave #(8) slave(
      .Clock(Clock), .Reset(Reset),
      .arrived(arrivedS),
      .data(dataS), .dataO(dataSO),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS));

endmodule
