module PDM(clk, rst_n, duty, PDM);

	input clk, rst_n;
	input [15:0] duty;
	
	reg update;
	wire unsigned [15:0] out1, out2;

	reg [15:0] duty_out, out3;
	
	output PDM;
	
	always @(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			duty_out = 16'h0000;
		else 
			if (update)
				duty_out = duty + 16'h8000;
	end

	always @(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			update = 1'b0;
		else
			update = ~update;
	end

	assign out1 = ((PDM ? 16'hffff : 16'h0000) - duty_out);
	assign out2 = out1 + out3;
	
	always @(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			out3 = 16'h0000;
		else 
			if (update)
				out3 = out2;
	end

	assign PDM = (duty_out >= out3) ? 1'b1 : 1'b0;
	
endmodule
	
	
	