`default_nettype none
module SPI_Master(
   input Clock,
   input Reset,
   output ready,
   input send,
   output reg arrived,
   input [N-1:0] data,
   output reg [N-1:0] dataO,
   output reg SCLK,
   input MISO,
   inout MOSI,
   output CS
   );
   parameter N = 8;
`ifdef SIMULATION
   parameter div = 5;
`else
   parameter div = 5; // 2.5MHz
`endif

   localparam W = $clog2(N + 1);

   localparam S_IDLE = 1'h0;
   localparam S_SEND = 1'h1;

   reg [N-1:0] shift_reg;
   reg [7:0] cnt_freq;
   reg [W-1:0] cnt_bit;

   reg state;
   reg the_bit;

   assign ready = Reset & (state == S_IDLE);
   assign MOSI = (state == S_SEND) ? shift_reg[N-1] : 1'bz;
   assign CS = (state == S_SEND) ? 1'b0 : 1'b1;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         state <= S_IDLE;
      else if (state == S_IDLE && send)
         state <= S_SEND;
      else if (~|cnt_bit && ~|cnt_freq && ~SCLK)
         state <= S_IDLE;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         the_bit <= 1'b0;
      else if (~|cnt_freq && ~SCLK)
         the_bit <= MISO;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         shift_reg <= {N{1'b0}};
      else if (state == S_IDLE && send)
         shift_reg <= data;
      else if (~|cnt_freq && SCLK)
         shift_reg <= {shift_reg[N-2:0],the_bit};

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         cnt_bit <= N;
      else if (state == S_IDLE)
         cnt_bit <= N;
      else if (~|cnt_freq && SCLK)
         cnt_bit <= cnt_bit - 1;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         SCLK <= 1'b0;
      else if (state == S_IDLE)
         SCLK <= 1'b0;
      else if (|cnt_bit && ~|cnt_freq)
         SCLK <= ~SCLK;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         cnt_freq <= div - 1;
      else if (state == S_IDLE)
         cnt_freq <= div - 1;
      else
         cnt_freq <= ~|cnt_freq ? div - 1 : cnt_freq - 1;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         dataO <= {N{1'b0}};
      else if (state == S_SEND && ~|cnt_bit && ~|cnt_freq && ~SCLK)
         dataO <= shift_reg;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         arrived <= 1'b0;
      else if (state == S_SEND && ~|cnt_bit && ~|cnt_freq && ~SCLK)
         arrived <= 1'b1;
      else
         arrived <= 1'b0;

endmodule

module SPI_Slave(
   input Clock,
   input Reset,
   output reg arrived,
   input [N-1:0] data,
   output reg [N-1:0] dataO,
   input SCLK,
   inout MISO,
   input MOSI,
   input CS
   );
   parameter N = 8;

   localparam W = $clog2(N);

   localparam S_IDLE = 1'h0;
   localparam S_SEND = 1'h1;

   reg [N-1:0] shift_reg;

   reg state;
   reg the_bit;
   reg old_clk;

   assign MISO = (state == S_SEND && ~CS) ? shift_reg[N-1] : 1'bz;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         state <= S_IDLE;
      else if (~CS)
         state <= S_SEND;
      else
         state <= S_IDLE;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         the_bit <= 1'b0;
      else if (~old_clk && SCLK)
         the_bit <= MOSI;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         old_clk <= 1'b0;
      else
         old_clk <= SCLK;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         shift_reg <= {N{1'b0}};
      else if (state == S_IDLE)
         shift_reg <= data;
      else if (old_clk && ~SCLK)
         shift_reg <= {shift_reg[N-2:0],the_bit};

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         dataO <= {N{1'b0}};
      else if (state == S_SEND && CS)
         dataO <= shift_reg;

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         arrived <= 1'b0;
      else if (state == S_SEND && CS)
         arrived <= 1'b1;
      else
         arrived <= 1'b0;

endmodule
