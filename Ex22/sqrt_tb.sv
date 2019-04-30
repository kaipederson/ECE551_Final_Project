module sqrt_tb();

reg unsigned [15:0] stm_mag;
reg stm_go, clk, stm_rst_n;

wire unsigned [7:0] sqrt_mon;
wire done_mon;

sqrt	iDUT(.mag(stm_mag), .go(stm_go), .clk(clk), .rst_n(stm_rst_n), .sqrt(sqrt_mon), .done(done_mon));


initial begin
	clk = 1'b0;

	stm_rst_n = 1'b0;
	repeat (5)
		@(posedge clk);
		stm_rst_n = 1'b0;
	for (int i = 1; i < 128; i = i + 1)
	begin
		stm_go = 1'b0;
		@(posedge clk);
	
		stm_go = 1'b1;
		stm_mag = (i*i);
	
		@(posedge done_mon)	
			$display("SQRT of %0d is %0d", (i*i), sqrt_mon);
	end
	$stop;
end

always
	#5 clk = ~clk;
endmodule
