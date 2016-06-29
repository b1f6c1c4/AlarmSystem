`default_nettype none
module AlarmSystem(
   input CLK,
   input RST,
   output [7:0] LD,
   input RX,
   output TX,
   output SCLK,
   input MISO,
   output MOSI,
   output CS_ACL2,
   input INT_ACL2);
   
   wire Clock = CLK;
   wire Reset = RST;
   
   assign LD = {8{INT_ACL2}};
   
   PmodACL2 acl(
      .Clock(Clock), .Reset(Reset),
      .SCLK(SCLK), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ACL2));
   
endmodule
