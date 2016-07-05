`default_nettype none
module PmodACL2(
   input Clock,
   input Reset,
   output ready,
   input fetch,
   output reg arrived,
   output reg [23:0] acc,
   output SCLK,
   input MISO,
   output MOSI,
   output reg CS);
   localparam S_SINS = 4'h0;
   localparam S_SADD = 4'h1;
   localparam S_SDAT = 4'h2;
   localparam S_FINI = 4'h3;
   localparam S_BINS = 4'h4;
   localparam S_BADD = 4'h5;
   localparam S_RAXL = 4'h6;
   localparam S_RAXH = 4'h7;
   localparam S_RAYL = 4'h8;
   localparam S_RAYH = 4'h9;
   localparam S_RAZL = 4'ha;
   localparam S_RAZH = 4'hb;

   reg [3:0] state;
   reg [2:0] pc;
   reg [7:0] spi_data;
   reg spi_send;
   wire [23:0] spi_dataO;
   reg [11:0] acc_one;
   wire spi_ready, spi_arrx;

   assign ready = (state == S_FINI);

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         begin
            state <= S_SINS;
            spi_data <= 8'b0;
            spi_send <= 1'b0;
            CS <= 1'b1;
         end
      else
         case (state)
            S_SINS:
               if (spi_arrx)
                  state <= S_SADD;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h0a;
                     spi_send <= 1'b1;
                     CS <= 1'b0;
                  end
               else
                  spi_send <= 1'b0;
            S_SADD:
               if (spi_arrx)
                  state <= S_SDAT;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h2d;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_SDAT:
               if (spi_arrx)
                  state <= S_FINI;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h2a;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_FINI:
               begin
                  CS <= 1'b1;
                  if (fetch)
                     begin
                        state <= S_BINS;
                     end
               end
            S_BINS:
               if (spi_arrx)
                  state <= S_BADD;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h0b;
                     spi_send <= 1'b1;
                     CS <= 1'b0;
                  end
               else
                  spi_send <= 1'b0;
            S_BADD:
               if (spi_arrx)
                  state <= S_RAXL;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h0c;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_RAXL:
               if (spi_arrx)
                  state <= S_RAXH;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h00;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_RAXH:
               if (spi_arrx)
                  state <= S_RAYL;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h00;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_RAYL:
               if (spi_arrx)
                  state <= S_RAYH;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h00;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_RAYH:
               if (spi_arrx)
                  state <= S_RAZL;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h00;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_RAZL:
               if (spi_arrx)
                  state <= S_RAZH;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h00;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
            S_RAZH:
               if (spi_arrx)
                  state <= S_FINI;
               else if (spi_ready)
                  begin
                     spi_data <= 8'h00;
                     spi_send <= 1'b1;
                  end
               else
                  spi_send <= 1'b0;
         endcase

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         acc <= 24'b0;
      else
         case (state)
            S_FINI:
               if (fetch)
                  acc <= 24'b0;
            S_RAXH, S_RAYH, S_RAZH:
               if (spi_arrx)
                  acc <= acc + acc_one * acc_one;
         endcase

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         arrived <= 1'b0;
      else if (state == S_RAZH && spi_arrx)
         arrived <= 1'b1;
      else
         arrived <= 1'b0;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         acc_one <= 12'b0;
      else
         case (state)
            S_RAXL, S_RAYL, S_RAZL:
               if (spi_arrx)
                  acc_one[7:0] <= spi_dataO[7:0];
            S_RAXH, S_RAYH, S_RAZH:
               if (spi_arrx)
                  acc_one[11:8] <= spi_dataO[3:0];
         endcase

   SPI_Master #(8) sm(
      .Clock(Clock), .Reset(Reset),
      .ready(spi_ready), .send(spi_send), .arrived(spi_arrx),
      .data(spi_data), .dataO(spi_dataO),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI));

endmodule
