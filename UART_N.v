`default_nettype none
module UART_N(input Clock, input Reset,
						 input [63:0] Buffer, 
						 input [3:0] Num,
						 input Trig_in,
						 output idle,
						 output TX,
						 output tclk);
	
	localparam S_IDLE = 2'b00;
	localparam S_WORKING = 2'b01;
	localparam S_PAUSE = 2'b10;
	
	assign idle = Reset & (state==S_IDLE);
	
	reg[7:0] buff[8];
	reg[3:0] n, inv_cnt, tarn;
	reg[1:0] state;
	
	reg pre_trig, trig;
	always @(negedge Clock, negedge Reset)
	if(~Reset) begin
		pre_trig <= 1'b0;
		trig <= 1'b0;
	end else  begin
		trig <= 1'b0;
		if(Trig_in & ~pre_trig)
			trig <= 1'b1;
			pre_trig <= Trig_in;
	end
	
	initial begin
		state <= S_IDLE;
	end
	
	reg send_uart;
	reg[7:0] to_send;
	wire uart_rd;
	UART_WriteD uart_inst(
		.Clock(Clock), .Reset(Reset), .ready(uart_rd),
		.send(send_uart), .data(to_send), .TX(TX), .tclk(tclk)
   );
	
	always @(posedge Clock, negedge Reset)
		if(~Reset) begin
			state <= S_IDLE;
		end else begin
			case(state)
			S_IDLE: if(trig) begin
				state <= S_WORKING;	
				n <= Num;
				tarn <= Num;
				{buff[7],buff[6],buff[5],buff[4],buff[3],buff[2],buff[1],buff[0]} <= Buffer;
			end
			S_WORKING: begin
				send_uart <= 1'b0;
				if(uart_rd) begin
					if(~|tarn) begin
						state <= S_IDLE;
					end else begin
						send_uart <= 1'b1;
						to_send <= buff[tarn-1'b1];
						state <= S_PAUSE;
						tarn <= tarn - 1'b1;
					end
				end
			end
			S_PAUSE: state <=S_WORKING;
			endcase		
		end
endmodule
