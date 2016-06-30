`default_nettype none
module AlarmSystem(
   input CLK,
   input RST,
   output [9:0] LD,
   output Buzz,
   input RX,
   output TX,
   input TXD_Bluetooth,
   output RXD_Bluetooth,
   output SCLK,
   input MISO,
   output MOSI,
   output CS_ALS,
   output CS_ACL2,
   input INT_ACL2,
   output Trig_US,
   input Echo_US);
   
   wire Clock = CLK;
   wire Reset = RST;
   
   assign TX = TXD_Bluetooth;
   assign RXD_Bluetooth = RX;
   
   assign Buzz = ~INT_ACL2;
   assign LD = {INT_ACL2,illum[3:0],dist[13:9]};
   
   wire als_clk, acl_clk, acl_ed;
   wire [7:0] illum;
   assign SCLK = acl_ed ? als_clk : acl_clk;
   wire [31:0] dist;

   PmodALS als(
      .Clock(Clock), .Reset(acl_ed), .illum(illum),
      .SCLK(als_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ALS));
   PmodACL2 acl(
      .Clock(Clock), .Reset(Reset), .done(acl_ed),
      .SCLK(acl_clk), .MISO(MISO),
      .MOSI(MOSI), .CS(CS_ACL2));
   Ultrasonic us(
      .Clock(Clock), .Reset(Reset),
      .dist(dist), .Trig(Trig_US), .Echo(Echo_US));
   
endmodule
