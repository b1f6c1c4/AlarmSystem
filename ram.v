`default_nettype none
module ram(
   input Clock,
   input Reset,
   input WE,
   input [M-1:0] A,
   input [N-1:0] D,
   output reg [N-1:0] Q
   );
   parameter N = 16;
   parameter M = 6;
   parameter FILENAME = "";
   
   reg [N-1:0] ram[0:2**M-1];
   
   initial
      if (FILENAME != "")
         $readmemb(FILENAME, ram);
   
   always @(posedge Clock, negedge Reset)
      if (~Reset)
         Q <= {N{1'b0}};
      else if (WE)
         begin
            ram[A] <= D;
            Q <= D;
         end
      else
         Q <= ram[A];
   
endmodule
