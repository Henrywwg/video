module VGA_logic(
	input clk,
	input rst_n,
	input img_reg,
	
	output red,
	output green,
	output blue,
	output vsync,
	output hsync
);

	parameter H_A_VID = 640;
	parameter H_F_PORCH = 16;
	parameter H_SYNC = 96;
	parameter H_B_PORCH = 48;
	parameter H_TOT = H_A_VID + H_F_PORCH + H_SYNC + H_B_PORCH;
	parameter H_CNTR_BIT_SIZE = $clog2(H_TOT);


	parameter V_A_VID = 480;
	parameter V_F_PORCH = 11;
	parameter V_SYNC = 2;
	parameter V_B_PORCH = 31;
	parameter V_TOT = V_A_VID + V_F_PORCH + V_SYNC + V_B_PORCH;
	parameter V_CNTR_BIT_SIZE = $clog2(V_TOT);

	//Counters for vertical and horizontal timings
	logic [H_CNTR_BIT_SIZE - 1:0]h_cntr;
	logic [V_CNTR_BIT_SIZE - 1:0]v_cntr;
	logic active;
	
	//////////////////////////
	//  Horizontal Counter  //
	//////////////////////////
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			h_cntr <= '0;
		else if(h_cntr == H_TOT - 1)
			h_cntr <= '0;
		else
			h_cntr <= h_cntr + 1;
	end
	
	assign hsync = ~((H_A_VID + H_F_PORCH + H_SYNC > h_cntr) & (h_cntr >= H_A_VID + H_F_PORCH));
	
	////////////////////////
	//  Vertical Counter  //
	////////////////////////
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			v_cntr <= '0;
		else if(v_cntr == V_TOT - 1)
			v_cntr <= '0;
		else if(v_cntr == H_TOT - 1)		//increment v_cntr when h_cntr row finishes
			v_cntr <= v_cntr + 1;
	end
	
	assign vsync = ~((V_A_VID + V_F_PORCH + V_SYNC > v_cntr) & (v_cntr >= V_A_VID + V_F_PORCH));
	
	////////////////////
	//  Video Output  //
	////////////////////
	assign active = (h_cntr < H_A_VID) & (v_cntr < V_A_VID);
	
	assign green = active & img_reg;
	assign blue = active & 0;
	assign red = active & 0;
//	 c68be0dbee81e56f0734651ee1e25d4521b07f61 not sure what this is but we'll figure it out


endmodule
