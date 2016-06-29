`default_nettype none
module AlarmSystem(
   input CLK,
   input RST,
   output [7:0] LD,
   output Buzz,
   input RX,
   output TX,
   output SCLK,
   input MISO,
   output MOSI,
   output CS_ALS,
   output CS_ACL2,
   input INT_ACL2);
   
   wire Clock = CLK;
   wire Reset = RST;
   
   assign Buzz = ~INT_ACL2;
   assign LD = illum;
   
   wire als_clk, acl_clk, acl_ed;
   wire [7:0] illum;
   assign SCLK = acl_ed ? als_clk : acl_clk;
   
   PmodALS als(
      .Clock(Clock), .Reset(acl_ed), .illum(illum),
      .SCLK(als_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ALS));
   PmodACL2 acl(
      .Clock(Clock), .Reset(Reset), .done(acl_ed),
      .SCLK(acl_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ACL2));
   
endmodule
