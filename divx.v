`timescale 1 ns/ 1 ps
module divx(input wire CLK, input wire RST,input wire[31:0] DIV, output reg CLKout);

integer cnt; 

always @( posedge CLK or negedge RST)      //分频50Hz
	begin
    if (!RST) begin
        cnt = 0 ;
		end
    else  begin			  
			  if (cnt == (DIV >> 1) - 1) begin
						 CLKout <= 1'b1;
						 cnt= cnt+1'b1;
					end
			  else if (cnt == DIV - 1)  
					begin 
						 CLKout <= 1'b0;
						 cnt = 1'b0;      
					end
				else cnt= cnt + 1'b1;			  
			end
	end
	
endmodule
				
				