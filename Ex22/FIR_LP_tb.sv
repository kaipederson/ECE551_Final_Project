module FIR_LP_tb();
wire cmd_n,RX,TX,I2S_sclk,I2S_data,I2S_ws,vld,sequencing;
wire[23:0]lft_chnnl,rght_chnnl;
wire[15:0]lft_in,rght_in,lft_sig,rght_sig;
reg[15:0]lft_out,rght_out;
assign RX = 1'b1;
assign cmd_n = 1'b0;
reg clk,rst_n;

RN52 iRN52(.clk(clk),.RST_n(rst_n),.cmd_n(cmd_n),.RX(RX),.TX(TX),
	.I2S_sclk(I2S_sclk),.I2S_data(I2S_data),.I2S_ws(I2S_ws));
I2S_Slave iI2S_Slave(.clk(clk),.rst_n(rst_n),.lft_chnnl(lft_chnnl),
	.rght_chnnl(rght_chnnl),.vld(vld),.I2S_sclk(I2S_sclk), .I2S_ws(I2S_ws),.I2S_data(I2S_data));
low_freq_queue iLFQ(.clk(clk), .rst_n(rst_n), .lft_smpl(lft_chnnl[23:8]), .rght_smpl(rght_chnnl[23:8]),
	.wrt_smpl(vld), .lft_out(lft_in), .rght_out(rght_in), .sequencing(sequencing));
FIR_B2 iFIR_B2(.lft_in(lft_in),.sequencing(sequencing),.rght_in(rght_in),
	.lft_out(lft_sig),.rght_out(rght_sig),.clk(clk),.rst_n(rst_n));

initial begin
	clk = 0;
	rst_n = 0;
	#5;
	rst_n = 1;
	repeat (100000000)@(posedge clk);
	$stop;
end	
	
always@(posedge clk,negedge rst_n)begin
	if(vld)begin
		lft_out = lft_sig;
		rght_out = rght_sig;
	end
end

always
  #5 clk = ~clk;


endmodule
