`default_nettype none
module divx_short(
   input Clock,
   input Reset,
   output ena
   );
   parameter div = 10;
   
   reg [31:0] count;
   assign ena = ~|count;
   
   always @(posedge Clock, negedge Reset)
      if (~Reset)
         count <= div - 1;
      else
         count <= ~|count ? div - 1 : count - 1;
   
endmodule
