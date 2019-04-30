module sqrt(mag, go, clk, rst_n, sqrt, done);

input go, clk, rst_n;
input unsigned [15:0] mag;

output reg done;
output reg unsigned [7:0] sqrt;

reg calc_done;
reg unsigned [7:0] mask;
reg unsigned [7:0] res;


typedef enum reg [2:0] {IDLE, CALC, DONE, EXT} state_t;
	state_t state, nxt_state;

always_comb
begin
	if (rst_n)
		nxt_state = IDLE;
	if (!go)
		nxt_state = IDLE;
	else if (calc_done)
		nxt_state = DONE;
	else if (go)
		nxt_state = CALC;
	else
		nxt_state = IDLE;
end

always @(posedge clk, negedge rst_n)
begin
	if (rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

always @(posedge clk, negedge rst_n)
begin
	if (state == IDLE & nxt_state == CALC)
	begin
	calc_done = 1'b0;
	done = 1'b0;
	mask = 8'h80;
	res  = 8'h00;
	end

	else if (state == CALC)
	begin
		if (mask == 8'h00)
			calc_done = 1'b1;
		else 
			if (((mask | res) * (mask | res)) <= mag)
				res = (res | mask);
			mask = mask >> 1;
	end

	else if (state == DONE)	
	begin
		done = 1'b1;
		sqrt = res;
		calc_done = 1'b0;
	end

	else
	begin
		calc_done = 1'b0;
		done = 1'b0;
		mask = 8'h00;
		res = 8'h00;
	end
end

endmodule