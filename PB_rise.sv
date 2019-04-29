module PB_rise(PB, clk, rst_n, rise);

input PB, clk, rst_n;
output reg rise;
reg q1, q2, q3;

always @ (posedge clk, negedge rst_n) 
	if(!rst_n) begin
		q1 <= 1'b1;
		q2 <= 1'b1;
		q3 <= 1'b1;
	end
	else begin
		q1 <= PB;
		q2 <= q1;
		q3 <= q2;
	end
	
assign rise = q2 & ~q3;

endmodule


