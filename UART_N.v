`default_nettype none
module UART_N(
   input Clock,
   input Reset,
   input [63:0] buffer,
   input [3:0] num,
   input trig_in,
   output idle,
   output TX);

   localparam S_IDLE = 2'b00;
   localparam S_WORKING = 2'b01;
   localparam S_PAUSE = 2'b10;

   assign idle = Reset & (state == S_IDLE);

   reg [7:0] buff[8];
   reg [3:0] inv_cnt, tarn;
   reg [1:0] state;

   reg pre_trig;
   wire trig = trig_in && ~pre_trig;
   always @(posedge Clock, negedge Reset)
      if (~Reset)
         pre_trig <= 1'b0;
      else
         pre_trig <= trig_in;

   reg send_uart;
   reg [7:0] to_send;
   wire uart_rd;
   UART_WriteD uart_inst(
      .Clock(Clock), .Reset(Reset), .ready(uart_rd),
      .send(send_uart), .data(to_send), .TX(TX));

   genvar i;
   generate
      for (i = 0; i < 8; i = i + 1)
         begin : MERGE_BUFF
            always @(posedge Clock)
               if (state == S_IDLE && trig)
                  buff[i] <= buffer[8*i+7:8*i];
         end
   endgenerate

   always @(posedge Clock, negedge Reset)
      if (~Reset)
         state <= S_IDLE;
      else
         case (state)
            S_IDLE:
               if (trig)
                  begin
                     state <= S_WORKING;
                     tarn <= num;
                  end
            S_WORKING:
               begin
                  send_uart <= 1'b0;
                  if(uart_rd)
                     if(~|tarn)
                        state <= S_IDLE;
                     else
                        begin
                           send_uart <= 1'b1;
                           to_send <= buff[tarn-1'b1];
                           state <= S_PAUSE;
                           tarn <= tarn - 1'b1;
                        end
               end
            S_PAUSE:
               state <= S_WORKING;
         endcase

endmodule
