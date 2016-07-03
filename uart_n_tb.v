`timescale 10 ns / 1 ns
module uart_n_tb;
	reg CLK, RST;
	reg[63:0] Buffer;
	reg[3:0] Num;
	reg trig;
	wire idle,TX,tclk;
	initial begin
		RST = 1'b0;
		trig=1'b0;
	#1 RST = 1'b1;
	#5	Buffer= 64'h1234567890123456;
		Num = 4'd8;
		trig= 1'b1;
	#100000
		$finish;
	end
	
	UART_N UART_WriteN_inst(
	.Clock(CLK) ,	// input  Clock_sig
	.Reset(RST) ,	// input  Reset_sig
	.Buffer(Buffer) ,	// input [63:0] Buffer_sig
	.Num(Num) ,	// input [3:0] Num_sig
	.Trig_in(trig) ,	// input  Trig_in_sig
	.idle(idle) ,	// output  idle_sig
	.TX(TX), 	// output  TX_sig
	.tclk(tclk)
	);
	
	always begin
	#1 CLK=1'b0;
	#1 CLK=1'b1;	
	end	
endmodule
