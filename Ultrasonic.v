`default_nettype none
module Ultrasonic(
   input Clock,
   input Reset,
   output reg [31:0] dist,
   output Trig,
   input Echo);
`ifdef SIMULATION
   parameter TTRIG = 5;
   parameter TWAIT = 100;
   parameter TIDLE = 20;
`else
   parameter TTRIG = 500;
   parameter TWAIT = 100000;
   parameter TIDLE = 5000000;
`endif

   localparam S_IDLE = 2'h0;
   localparam S_TRIG = 2'h1;
   localparam S_WAIT = 2'h2;
   localparam S_MEAS = 2'h3;

   assign Trig = (state == S_TRIG);

   reg [1:0] state;

   reg [31:0] count;
   always @(posedge Clock, negedge Reset)
      if (~Reset)
         count <= TIDLE - 1;
      else
         case (state)
            S_IDLE:
               count <= (~|count ? TTRIG - 1 : count - 1);
            S_TRIG:
               count <= (~|count ? TWAIT - 1 : count - 1);
            S_WAIT:
               if (Echo)
                  count <= 0;
               else
                  count <= (~|count ? TIDLE : count - 1);
            S_MEAS:
               if (~Echo)
                  count <= TIDLE - 1;
               else
                  count <= count + 1;
         endcase

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         state <= S_IDLE;
      else
         case (state)
            S_IDLE:
               if (~|count)
                  state <= S_TRIG;
            S_TRIG:
               if (~|count)
                  state <= S_WAIT;
            S_WAIT:
               if (Echo)
                  state <= S_MEAS;
               else if (~|count)
                  state <= S_IDLE;
            S_MEAS:
               if (~Echo)
                  state <= S_IDLE;
         endcase

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         dist <= 0;
      else if (state == S_MEAS && ~Echo)
         dist <= count;

endmodule
