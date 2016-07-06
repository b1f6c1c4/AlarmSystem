`default_nettype none
module UART_Demo(
   input Clock,
   input Reset,
   output ready,
   input send,
   output finish,
   input [7:0] data,
   output arrivedR,
   output [7:0] dataR,
   output RXTX);

   UART_WriteD writer(
      .Clock(Clock), .Reset(Reset),
      .ready(ready), .send(send), .finish(finish),
      .data(data),
      .TX(RXTX));

   UART_ReadD reader(
      .Clock(Clock), .Reset(Reset),
      .arrived(arrivedR),
      .data(dataR),
      .RX(RXTX));

endmodule
