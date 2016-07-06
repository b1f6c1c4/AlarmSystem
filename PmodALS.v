`default_nettype none
module PmodALS(
   input Clock,
   input Reset,
   output ready,
   input fetch,
   output reg arrived,
   output reg [7:0] illum,
   output SCLK,
   input MISO,
   output MOSI,
   output CS);
   localparam S_FINI = 1'h0;
   localparam S_SEND = 1'h1;

   reg state;
   reg spi_send;
   reg [2:0] pc;
   wire [15:0] spi_dataO;
   wire spi_ready, spi_arrx;

   assign ready = (state == S_FINI);

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         begin
            state <= S_FINI;
            spi_send <= 1'b0;
         end
      else
         case (state)
            S_FINI:
               begin
                  spi_send <= 1'b0;
                  if (fetch)
                     state <= S_SEND;
               end
            S_SEND:
               if (spi_arrx)
                  state <= S_FINI;
               else if (~spi_send && spi_ready)
                  spi_send <= 1'b1;
               else
                  spi_send <= 1'b0;
         endcase


   always @(posedge Clock, negedge Reset)
      if (~Reset)
         arrived <= 1'b0;
      else if (spi_arrx)
         arrived <= 1'b1;
      else
         arrived <= 1'b0;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         illum <= 3'd0;
      else if (spi_arrx)
         illum <= spi_dataO[11:4];

   SPI_Master #(16) sm(
      .Clock(Clock), .Reset(Reset),
      .ready(spi_ready), .send(spi_send), .arrived(spi_arrx),
      .data(16'h5a5a), .dataO(spi_dataO),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS));

endmodule
