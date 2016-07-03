`default_nettype none
module PmodACL2(
   input Clock,
   input Reset,
   output done,
   output SCLK,
   input MISO,
   output MOSI,
   output CS);
   localparam S_LOAD = 2'h0;
   localparam S_SEND = 2'h1;
   localparam S_WAIT = 2'h2;
   localparam S_FINI = 2'h3;

   reg [1:0] state;
   reg [2:0] pc;
   wire [15:0] data;
   wire ready, arrx;

   assign done = (state == S_FINI);

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         state <= S_LOAD;
      else
         case (state)
            S_LOAD:
               state <= S_SEND;
            S_SEND:
               if (ready)
                  state <= S_WAIT;
            S_WAIT:
               if (arrx)
                  if (pc < 3'd7)
                     state <= S_LOAD;
                  else
                     state <= S_FINI;
         endcase

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         pc <= 3'd0;
      else if (state == S_LOAD && pc < 3'd7)
         pc <= pc + 3'd1;

   ram #(.N(16), .M(3), .FILENAME("PmodACL2.list")) rom(
      .Clock(Clock), .WE(1'b0), .A(pc), .D(16'b0), .Q(data));

   SPI_Master #(24) sm(
      .Clock(Clock), .Reset(Reset),
      .ready(ready), .send(ready && state == S_SEND), .arrived(arrx),
      .data({8'h0a,data}),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS));

endmodule
