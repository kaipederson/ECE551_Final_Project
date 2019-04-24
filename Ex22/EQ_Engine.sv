module EQ_Engine(clk, rst_n, vld, aud_in_lft, aud_in_rght, POT_LP, POT_B1,
	POT_B2, POT_B3, POT_HP, VOL_POT, aud_out_lft, aud_out_rght);

input[15:0] aud_in_lft, aud_in_rght;
input[11:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOL_POT;
input clk, rst_n, vld;

output reg[15:0] aud_out_lft, aud_out_rght;

/// Queues ///
wire[15:0] lftqlow, rghtqlow;
wire sequencingLow;
low_freq_queue LOW(.clk(clk), .rst_n(rst_n), .lft_smpl(aud_in_lft), .rght_smpl(aud_in_rght),
	.wrt_smpl(vld), .lft_out(lftqlow), .rght_out(rghtqlow), .sequencing(sequencingLow));

wire[15:0] lftqhigh, rghtqhigh;
wire sequencingHigh;
high_freq_queue HIGH(.clk(clk), .rst_n(rst_n), .lft_smpl(aud_in_lft), .rght_smpl(aud_in_rght),
	.wrt_smpl(vld), .lft_out(lftqhigh), .rght_out(rghtqhigh), .sequencing(sequencingHigh));

reg[15:0] lftqlowPipe, rghtqlowPipe, lftqhighPipe, rghtqhighPipe;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) begin
		lftqlowPipe <= 16'h0000;
		rghtqlowPipe <= 16'h0000;
		lftqhighPipe <= 16'h0000;
		rghtqhighPipe <= 16'h0000;
	end
	else begin
		lftqlowPipe <= lftqlow;
		rghtqlowPipe <= rghtqlow;
		lftqhighPipe <= lftqhigh;
		rghtqhighPipe <= rghtqhigh;
	end

reg sequencingLowPipe, sequencingHighPipe;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) begin
		sequencingLowPipe <= 1'b0;
		sequencingHighPipe <= 1'b0;
	end
	else begin
		sequencingLowPipe <= sequencingLow;
		sequencingHighPipe <= sequencingHigh;
	end

/// Filters ///
wire[15:0] lftLP, rghtLP;
FIR_LP LP(.clk(clk), .rst_n(rst_n), .lft_in(lftqlowPipe), .rght_in(rghtqlowPipe), 
	.sequencing(sequencingLowPipe), .lft_out(lftLP), .rght_out(rghtLP));

wire[15:0] lftB1, rghtB1;
FIR_B1 B1(.clk(clk), .rst_n(rst_n), .lft_in(lftqlowPipe), .rght_in(rghtqlowPipe), 
	.sequencing(sequencingLowPipe), .lft_out(lftB1), .rght_out(rghtB1));

wire[15:0] lftB2, rghtB2;
FIR_B2 B2(.clk(clk), .rst_n(rst_n), .lft_in(lftqhighPipe), .rght_in(rghtqhighPipe), 
	.sequencing(sequencingHighPipe), .lft_out(lftB2), .rght_out(rghtB2));

wire[15:0] lftB3, rghtB3;
FIR_B3 B3(.clk(clk), .rst_n(rst_n), .lft_in(lftqhighPipe), .rght_in(rghtqhighPipe), 
	.sequencing(sequencingHighPipe), .lft_out(lftB3), .rght_out(rghtB3));

wire[15:0] lftHP, rghtHP;
FIR_HP HP(.clk(clk), .rst_n(rst_n), .lft_in(lftqhighPipe), .rght_in(rghtqhighPipe),
	.sequencing(sequencingHighPipe), .lft_out(lftHP), .rght_out(rghtHP));

reg[15:0] lftLPPipe, rghtLPPipe, lftB1Pipe, rghtB1Pipe, lftB2Pipe, rghtB2Pipe,
	lftB3Pipe, rghtB3Pipe, lftHPPipe, rghtHPPipe;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) begin
		lftLPPipe <= 16'h0000;
		rghtLPPipe <= 16'h0000;
		lftB1Pipe <= 16'h0000;
		rghtB1Pipe <= 16'h0000;
		lftB2Pipe <= 16'h0000;
		rghtB2Pipe <= 16'h0000;
		lftB3Pipe <= 16'h0000;
		rghtB3Pipe <= 16'h0000;
		lftHPPipe <= 16'h0000;
		rghtHPPipe <= 16'h0000;
	end
	else begin
		lftLPPipe <= lftLP;
		rghtLPPipe <= rghtLP;
		lftB1Pipe <= lftB1;
		rghtB1Pipe <= rghtB1;
		lftB2Pipe <= lftB2;
		rghtB2Pipe <= rghtB2;
		lftB3Pipe <= lftB3;
		rghtB3Pipe <= rghtB3;
		lftHPPipe <= lftHP;
		rghtHPPipe <= rghtHP;
	end
	
		     

/// Band Scales ///
wire[15:0] lft_scaled_LP, rght_scaled_LP, lft_scaled_B1, rght_scaled_B1, lft_scaled_B2, rght_scaled_B2,
	lft_scaled_B3, rght_scaled_B3, lft_scaled_HP, rght_scaled_HP;

band_scale lftScaleLP(.POT(POT_LP), .audio(lftLPPipe), .scaled(lft_scaled_LP));
band_scale rghtScaleLP(.POT(POT_LP), .audio(rghtLPPipe), .scaled(rght_scaled_LP));
band_scale lftScaleB1(.POT(POT_B1), .audio(lftB1Pipe), .scaled(lft_scaled_B1));
band_scale rghtScaleB1(.POT(POT_B1), .audio(rghtB1Pipe), .scaled(rght_scaled_B1));
band_scale lftScaleB2(.POT(POT_B2), .audio(lftB2Pipe), .scaled(lft_scaled_B2));
band_scale rghtScaleB2(.POT(POT_B2), .audio(rghtB2Pipe), .scaled(rght_scaled_B2));
band_scale lftScaleB3(.POT(POT_B3), .audio(lftB3Pipe), .scaled(lft_scaled_B3));
band_scale rghtScaleB3(.POT(POT_B3), .audio(rghtB3Pipe), .scaled(rght_scaled_B3));
band_scale lftScaleHP(.POT(POT_HP), .audio(lftHPPipe), .scaled(lft_scaled_HP));
band_scale rghtScaleHP(.POT(POT_HP), .audio(rghtHPPipe), .scaled(rght_scaled_HP));

/// Summation ///
reg[15:0] lftSum, rghtSum;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) begin
		lftSum <= 16'h0000;
		rghtSum <= 16'h0000;
	end
	else begin
		lftSum <= lft_scaled_LP + lft_scaled_B1 + lft_scaled_B2 + 
			lft_scaled_B3 + lft_scaled_HP;
		rghtSum <= rght_scaled_LP + rght_scaled_B1 + rght_scaled_B2 + 
			rght_scaled_B3 + rght_scaled_HP;
	end

/// Volume ///
reg[28:0] lftMult, rghtMult;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) begin
		lftMult <= 29'd0;
		rghtMult <= 29'd0;
	end
	else begin
		lftMult <= {1'b0, VOL_POT} * lftSum;
		rghtMult <= {1'b0, VOL_POT} * rghtSum;
	end

/// Output ///
always @ (posedge clk, negedge rst_n)
	if(!rst_n) begin
		aud_out_lft <= 16'h0000;
		aud_out_rght <= 16'h0000;
	end
	else begin
		aud_out_lft <= lftMult[27:12];
		aud_out_rght <= rghtMult[27:12];
	end
 
endmodule 