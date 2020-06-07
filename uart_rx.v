`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:31:21 06/06/2020 
// Design Name: 
// Module Name:    uart_rx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_rx(i_clk,serial_in,data_out, data_valid);
parameter no_clk_per_bit=32;
input i_clk,serial_in;
output [7:0] data_out;
output data_valid;

parameter idle_state=3'b000;
parameter start_bit_state=3'b001;
parameter data_bit_state=3'b010;
parameter stop_bit_state=3'b011;
parameter resync_state=3'b100;
reg [2:0] cstate=idle_state;
reg [7:0] data_byte;
reg [7:0] count_clk;   //assuming maximum no of clk per bit is 256
reg [2:0]  index;  
reg data_received=1'b0;
reg r_serial_data=1'b1;
reg serial_data=1'b1;

assign data_out=data_byte;
assign data_valid=data_received;
// state machine for flow of data and control
always@(posedge i_clk)
	begin
	serial_data<=serial_in;
	r_serial_data<=serial_data;
	case(cstate)
	idle_state:
		begin
		count_clk<=0;
		index<=0;
		data_received<=1'b0;
		if(r_serial_data==1'b1)
			cstate<=idle_state;
		else
			cstate<=start_bit_state;
		end
	start_bit_state:
		begin
		if(count_clk<(no_clk_per_bit-1)/2)
			begin
			count_clk<=count_clk+1;
			cstate<=start_bit_state;
			end
		else
			begin
			if(r_serial_data==1'b0)
				begin
				cstate<=data_bit_state;
				count_clk<=0;
				end
			else
				cstate<=idle_state;
			end  // end of else
		end  // end of case start_bit
	data_bit_state:
		begin
		if(count_clk<(no_clk_per_bit-1))
			begin
			count_clk<=count_clk+1;
			cstate<=data_bit_state;
			end
		else
			begin
			data_byte[index]=r_serial_data;
			if(index<7)
				begin
				index<=index+1;
				count_clk<=0;
				cstate<=data_bit_state;
				end
			else
				begin
				count_clk<=0;
				cstate<=stop_bit_state;
				end
			end
		end
	stop_bit_state:
		begin
		if(count_clk<(no_clk_per_bit-1))
			begin
			count_clk<=count_clk+1;
			cstate<=stop_bit_state;
			end
		else
			begin
			data_received<=1'b1;
			cstate<=resync_state;
			end
		end
	resync_state:
		cstate<=idle_state;
	default:
		cstate<=idle_state;
	endcase
end
endmodule
