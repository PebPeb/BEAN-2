
//
//	flopren.v
//		Enabled Resetable flip-flop
//

// -------------------------------- //
//	By: Bryce Keen	
//	Created: 06/30/2022
// -------------------------------- //
//	Last Modified: 07/09/2023


module flopren(d, q, clk, enable, reset);
	parameter WIDTH = 32;
	parameter INIT = 0;

	input wire                enable, reset, clk;
	input wire [WIDTH - 1:0]	d;
  output wire [WIDTH - 1:0]	q;
	
	reg [WIDTH - 1:0]         q_n;
	
	initial q_n = INIT;
	always @(posedge clk, posedge reset) begin
		q_n <= reset ? {WIDTH{1'b0}} : (enable ? d : q_n);
  end

  assign q = q_n;

endmodule
