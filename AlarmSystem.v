`default_nettype none
module AlarmSystem(
   input Clock,
   input Reset,
   output ready,
   input send,
   input [7:0] data,
   output TX,
   output arrived,
   output [7:0] dataR);
   
   UART_WriteD(.Clock(Clock), .Reset(Reset),
               .ready(ready), .send(send),
               .data(data), .TX(TX));
   
   UART_ReadD(.Clock(Clock), .Reset(Reset),
              .arrived(arrived),
              .data(dataR), .RX(TX));
   
endmodule
