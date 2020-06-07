`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:39:59 06/06/2020 
// Design Name: 
// Module Name:    uart_tx 
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
// no of clk per bit=input_clk_frequency/baud rate;
//
//////////////////////////////////////////////////////////////////////////////////
module uart_tx(i_clk,data_valid,data_in,serial_data_out,tx_active,tx_done);
parameter no_clk_per_bit=32;
input i_clk,data_valid;
input [7:0] data_in;
output serial_data_out,tx_active,tx_done;
parameter idle_state=3'b000;
parameter send_start_bit_state=3'b001;
parameter send_data_state=3'b010;
parameter send_stop_bit_state=3'b011;
parameter resync_state=3'b100;

reg [7:0] data;  // store all data in parallel mode 
reg serial_data=1'b1;  
reg [2:0] cstate=idle_state;
reg [2:0] index;
reg [7:0]  clk_count=0;  // assuming maximum no of clk per bit can have 256
reg make_tx_active;
reg make_tx_done;
assign serial_data_out=serial_data;
assign tx_active=make_tx_active;
assign tx_done=make_tx_done;
always@(posedge i_clk)
	begin
	case(cstate)
	idle_state:
		begin
		data<=0;
		index<=0;
		clk_count<=0;
		make_tx_active<=1'b0;
		make_tx_done<=1'b0;
		serial_data<=1'b1;  // set intially serial_data line to high
		if(data_valid==1'b1)
			begin
			data<=data_in;
			make_tx_active<=1'b1;
			cstate<=send_start_bit_state;
			end
		else
			cstate<=idle_state;
		end
	send_start_bit_state:
		begin
			serial_data<=1'b0;
			if(clk_count<(no_clk_per_bit-1))
				begin
				clk_count<=clk_count+1;
				cstate<=send_start_bit_state;
				end
			else
				begin
				clk_count<=0;
				cstate<=send_data_state;
			end
		end
	send_data_state:
		begin
			serial_data<=data[index];
			if(clk_count<(no_clk_per_bit-1))
				begin
				clk_count<=clk_count+1;
				cstate<=send_data_state;
				end
			else 
				begin
				if(index<7)
					begin
					index<=index+1;
					clk_count<=0;
					cstate<=send_data_state;
					end
				else
					begin
					clk_count<=0;
					cstate<=send_stop_bit_state;
					end
			end
		end
	send_stop_bit_state:
		begin
		serial_data<=1'b1;
		if(clk_count<(no_clk_per_bit-1))
			begin
			clk_count<=clk_count+1;
			cstate<=send_stop_bit_state;
			end
		else
			begin
			make_tx_done<=1'b1;
			clk_count<=0;
			cstate<=resync_state;
			end
		end
	resync_state:
		begin
		make_tx_active<=1'b0;
		cstate<=idle_state;
		end
	default:cstate<=idle_state;
	endcase				
				
					
		
	end		
	



endmodule
