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
   parameter TWAIT = 1000000;
   parameter TIDLE = 5000000;
`endif
   parameter MAX_COUNT = 100000;

   localparam S_IDLE = 2'h0;
   localparam S_TRIG = 2'h1;
   localparam S_WAIT = 2'h2;
   localparam S_MEAS = 2'h3;

   assign Trig = (state == S_TRIG);

   reg [1:0] state;

   reg [31:0] count;
   always @(posedge Clock, negedge Reset)
      if (~Reset)
         begin
            count <= TIDLE - 1;
            dist <= 0;
            state <= S_IDLE;
         end
      else
         case (state)
            S_IDLE:
               if (~|count)
                  begin
                     state <= S_TRIG;
                     count <= TTRIG - 1;
                  end
               else
                  count <= count - 1;
            S_TRIG:
               if (~|count)
                  begin
                     state <= S_WAIT;
                     count <= TWAIT - 1;
                  end
               else
                  count <= count - 1;
            S_WAIT:
               if (Echo)
                  begin
                     count <= 0;
                     state <= S_MEAS;
                  end
               else if (~|count)
                  begin
                     state <= S_IDLE;
                     count <= TIDLE - 1;
                  end
               else
                  count <= count - 1;
            S_MEAS:
               if (~Echo)
                  begin
                     dist <= count;
                     count <= TIDLE - 1;
                     state <= S_IDLE;
                  end
               else if (count >= MAX_COUNT)
                  begin
                     dist <= count;
                     count <= TIDLE - 1;
                     state <= S_IDLE;
                  end
               else
                  count <= count + 1;
         endcase

endmodule
