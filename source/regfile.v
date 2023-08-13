
//
//	regfile.v
//		Register file for the RV32I
//

// -------------------------------- //
//	By: Bryce Keen	
//	Created: 09/29/2022
// -------------------------------- //
//	Last Modified: 08/13/2023

// Change Log:	rd -> rs3

module regfile(rs1, rs2, wrs3, rs3, we, clk, reset, rdout1, rdout2);
	input wire 				clk, we, reset;
	input wire [4:0]		rs1, rs2, rs3;
	input wire [31:0]		wrs3;
	output wire [31:0]		rdout1, rdout2;
	
	reg [31:0] x [31:0];
	
	assign rdout1 = x[rs1];
	assign rdout2 = x[rs2];
	
	integer i = 0;
	always @(posedge clk, posedge reset) begin
		if (reset) begin						// Reset
			for (i = 0; i < 32; i = i + 1) begin 
				x[i] <= 0;
			end
		end
		else if (we & (rs3 != 0)) begin			// Write enable and can not overwrite x0
			x[rs3] <= wrs3;						// Store wrs3 to rs3 register
		end 
	
	end
	
endmodule




