`default_nettype none
module PmodALS(
   input Clock,
   input Reset,
   output reg [7:0] illum,
   output SCLK,
   input MISO,
   output MOSI,
   output CS);
   localparam S_SEND = 1'h0;
   localparam S_WAIT = 1'h1;
   
   reg state;
   reg [2:0] pc;
   wire [14:0] dataO;
   wire ready, arrx;
   
   always @(posedge Clock, negedge Reset)
      if (~Reset)
         state <= S_SEND;
      else
         case (state)
            S_SEND:
               if (ready)
                  state <= S_WAIT;
            S_WAIT:
               if (arrx)
                  state <= S_SEND;
         endcase
   
   always @(posedge Clock, negedge Reset)
      if (~Reset)
         illum <= 3'd0;
      else if (arrx)
         illum <= dataO[10:3];
   
   SPI_Master #(15) sm(
      .Clock(Clock), .Reset(Reset),
      .ready(ready), .send(ready && state == S_SEND), .arrived(arrx),
      .data(15'h5a5a), .dataO(dataO),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS));
   
endmodule
