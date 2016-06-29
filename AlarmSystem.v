`default_nettype none
module AlarmSystem(
   input Clock,
   input Reset,
   output ready,
   input send,
   input [7:0] data,
   output [7:0] dataO,
   output SCLK,
   output MISO,
   output MOSI,
   output CS,
   output arrived,
   output [7:0] dataR);
   
   SPI_Master(.Clock(Clock), .Reset(Reset),
               .ready(ready), .send(send),
               .data(data), .dataO(dataO),
               .SCLK(SCLK), .MISO(MISO),
               .MOSI(MOSI), .CS(CS));
   
   SPI_Slave(.Clock(Clock), .Reset(Reset),
              .arrived(arrived),
               .data(8'b10101101), .dataO(dataR),
               .SCLK(SCLK), .MISO(MISO),
               .MOSI(MOSI), .CS(CS));
   
endmodule
