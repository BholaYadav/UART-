`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:11:55 06/06/2020
// Design Name:   uart_tx
// Module Name:   F:/xilinx projects/UART/uart_tb.v
// Project Name:  UART
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart_tx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// no of clock per bit =clock freq/baud rate
////////////////////////////////////////////////////////////////////////////////
// test at  baud rate 9600 and clock freq 1MHz
module uart_tb;

	// Inputs
parameter no_clk_per_bit=104;
parameter clk_period=1000;

	reg i_clk;
	reg t_data_valid;
	reg [7:0] data_in;

	// Outputs
	wire serial_data_out;
	wire tx_active;
	wire tx_done;

	// Instantiate the Unit Under Test (UUT)
	uart_tx #(.no_clk_per_bit(no_clk_per_bit)) uut_tx (
		.i_clk(i_clk), 
		.data_valid(t_data_valid), 
		.data_in(data_in), 
		.serial_data_out(serial_data_out), 
		.tx_active(tx_active), 
		.tx_done(tx_done)
	);


	// Outputs
	wire [7:0] data_out;
	wire rx_data_valid;

	// Instantiate the Unit Under Test (UUT)
	uart_rx #(.no_clk_per_bit(no_clk_per_bit)) uut_rx (
		.i_clk(i_clk), 
		.serial_in(serial_data_out), 
		.data_out(data_out), 
		.data_valid(rx_data_valid)
	);
	
	initial begin
	i_clk=0;
	forever #(clk_period/2) i_clk=~i_clk;
	end
	
	initial begin
		// Initialize Inputs
		t_data_valid = 0;
		data_in = 0;

		// Wait 100 ns for global reset to finish
		#100;
		data_in=8'hAB;
		#5;
		t_data_valid=1;
		wait(tx_done)
		wait(rx_data_valid)
		#100;
		if(data_in==data_out)
		  begin
		$display("test case passed ! \ninput data:  %X",data_in);
		$display("data out :  %X",data_out);
		end
		else
		$display("failed");
		#200 $finish;

	end
      
endmodule

