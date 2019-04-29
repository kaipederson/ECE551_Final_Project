module spkr_drv(lft_chnnl, vld, rght_chnnl, clk, rst_n,
	lft_PDM, rght_PDM);
input[15:0] lft_chnnl, rght_chnnl;
input vld, clk, rst_n;
output lft_PDM, rght_PDM;

reg[15:0] lftF, rghtF;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) lftF <= 16'h0000;
	else if(vld) lftF <= lft_chnnl;

always @ (posedge clk, negedge rst_n)
	if(!rst_n) rghtF <= 16'h0000;
	else if(vld) rghtF <= rght_chnnl;

PDM lPDM(.clk(clk), .rst_n(rst_n), .duty(lftF), .PDM(lft_PDM));

PDM rPDM(.clk(clk), .rst_n(rst_n), .duty(rghtF), .PDM(rght_PDM));

endmodule



