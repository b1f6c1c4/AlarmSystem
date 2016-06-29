`default_nettype none
module AlarmSystem(
   input CLK,
   input RST,
   input RX,
   output TX,
   output SCLK,
   input MISO,
   output MOSI,
   output CS_ALS);
   
   wire Clock = CLK;
   wire Reset = RST;
   
   wire arr, ready;
   wire [7:0] data;
   wire arrx, readyx;
   wire [14:0] dataO;
   
   UART_ReadD ur(.Clock(Clock), .Reset(Reset),
                 .arrived(arr), .data(data),
                 .RX(RX));
   UART_WriteD uw(.Clock(Clock), .Reset(Reset),
                  .ready(ready), .send(arrx),
                  .data(dataO[10:3]), .TX(TX));
   SPI_Master #(15) sm(.Clock(Clock), .Reset(Reset),
               .ready(readyx), .send(arr), .arrived(arrx),
               .data(data), .dataO(dataO),
               .SCLK(SCLK), .MISO(MISO),
               .MOSI(MOSI), .CS(CS_ALS));
   
endmodule
