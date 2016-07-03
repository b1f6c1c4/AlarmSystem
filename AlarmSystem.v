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
   
   //assign TX = TXD_Bluetooth;
   //assign RXD_Bluetooth = RX;
   
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
	
	reg uart_trig;
	wire uart_idle;
	reg [63:0] uart_buffer;
	reg [3:0] uart_num;
	
	UART_N UART_WriteN_inst(
	.Clock(Clock) ,	// input  Clock_sig
	.Reset(Reset) ,	// input  Reset_sig
	.Buffer(uart_buffer) ,	// input [63:0] Buffer_sig
	.Num(uart_num),	// input [3:0] Num_sig
	.Trig_in(uart_trig) ,	// input  Trig_in_sig
	.idle(uart_idle),	// output  idle_sig
	.TX(TX) 	// output  TX_sig
	);
	
	wire ena_1hz;
	divx_short #(25000000) divx_1Hz(
		.Clock(Clock), .Reset(Reset), .ena(ena_1hz)
	);
	
	always @(posedge Clock ,negedge Reset)
		if(~Reset) begin
			uart_trig <= 1'b0;
		end else if(ena_1hz) begin
			uart_buffer <= {8'h5A,dist,illum,{7'b0, INT_ACL2},dist[7:0] ^ illum ^ {7'b0,INT_ACL2}};
			uart_num <= 4'd8;
			uart_trig <= 1'b1;
		end else begin
			uart_trig <= 1'b0;
		end

endmodule
