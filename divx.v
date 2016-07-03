`default_nettype none
module divx(
   input Clock,
   input Reset,
   output reg clk_out);
   parameter div = 25000;

   reg [31:0] cnt;

   always @(posedge Clock, negedge Reset)
      if (!Reset)
         begin
            cnt <= 0;
            clk_out <= 1'b0;
         end
      else
         if (cnt == (div >> 1) - 1)
            begin
               clk_out <= 1'b1;
               cnt <= cnt + 1;
            end
         else if (cnt == div - 1)
            begin
               clk_out <= 1'b0;
               cnt <= 0;
            end
         else
            cnt <= cnt + 1;

endmodule
