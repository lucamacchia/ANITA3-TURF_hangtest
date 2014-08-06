`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// This file is a part of the Antarctic Impulsive Transient Antenna (ANITA)
// project, a collaborative scientific effort between multiple institutions. For
// more information, contact Peter Gorham (gorham@phys.hawaii.edu).
//
// All rights reserved.
//
// Author: Patrick Allison, Ohio State University (allison.122@osu.edu)
// Author:
// Author:
////////////////////////////////////////////////////////////////////////////////
module ANITA3_deadtime_counter_v2(
		input clk250_i,
		input clk33_i,
		input dead_i,
		input pps_i,
		input pps_clk33_i,
		output [15:0] deadtime_o
    );

	reg deadtime_toggle = 0;
	reg [3:0] deadtime_counter = {4{1'b0}};
	reg deadtime_div32 = 0;
	reg [1:0] deadtime_div32_clk33 = {2{1'b0}};
	reg deadtime_flag = 0;
	reg [22:0] deadtime_counter_clk33 = {23{1'b0}};
	reg [15:0] deadtime_scaler = {16{1'b0}};
	always @(posedge clk250_i) begin
		//  deadtime_toggle is the low bit of the counter
		// deadtime_counter is bits [4:1] of the counter
		if (pps_i) deadtime_counter <= {4{1'b0}};
		else if (dead_i) deadtime_counter <= deadtime_counter + 1;
		
till here.... 
// We don't want this - this generates a flag.	
		if (deadtime_counter = 4'b11111) 	
			deadtime_div32 <= 1'b1;
		else 
			deadtime_div32 <= 1'b0
	end
	// We're now counting 128 ns increments, so we need 23 bits.
	always @(posedge clk33_i) begin
		deadtime_div32_clk33 <= {deadtime_div32_clk33[0],deadtime_div32};
		deadtime_flag <= deadtime_div32_clk33[0] && !deadtime_div32_clk33[1];

		if (pps_clk33_i) deadtime_counter_clk33 <= {23{1'b0}};
		else if (deadtime_flag) deadtime_counter_clk33 <= deadtime_counter_clk33 + 1;

		// These are now 16.384 us increments.
//		if (pps_clk33_i) deadtime_scaler <= deadtime_counter_clk33[22:7];
		if (pps_clk33_i) deadtime_scaler <= deadtime_counter_clk33[21:6];
	end
	assign deadtime_o = deadtime_scaler;
endmodule
