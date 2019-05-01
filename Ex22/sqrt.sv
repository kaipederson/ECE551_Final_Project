module sqrt(mag,go,clk,rst_n,sqrt,done);
   input reg[15:0]mag;
   input go,clk,rst_n;
   output reg[7:0]sqrt=8'b00000000;
   output reg done;
   reg [7:0] count=8'b1000_0000;
   reg [7:0] sqrt1 = 8'b1000_0000;



   always@(posedge clk,negedge rst_n)begin
	if(go)begin
	if(!rst_n) begin
	   count<=8'b1000_0000;
	end
	if(sqrt1*sqrt1 > mag)begin
	   count<={count[0],count[7:1]};
	   sqrt1<=sqrt1^count;
	end
	else if(sqrt1*sqrt1<=mag)begin
	   count<={count[0],count[7:1]};
	   sqrt1<=sqrt1|{count[0],count[7:1]};
	end
	if(count==8'b0000_0001) done <= 1;
	else done <= 0;
	end
	sqrt <= sqrt1;
   end

endmodule



/* module sqrt(mag, go, clk, rst_n, sqrt, done);

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

endmodule */