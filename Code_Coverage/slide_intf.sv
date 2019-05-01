module slide_intf(clk, rst_n, MISO, MOSI, SCLK, SS_n,
		POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME);

input clk, rst_n, MISO;
output MOSI, SCLK, SS_n;
output reg[23:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP;
output reg[11:0] VOLUME;

wire cnv_cmplt;
wire[11:0] res;
reg strt_cnv;
reg[2:0] chnnl;

A2D_intf iA2D(.clk(clk), .rst_n(rst_n), .MISO(MISO), .MOSI(MOSI), .SCLK(SCLK), .SS_n(SS_n), 
.strt_cnv(strt_cnv), .chnnl(chnnl), .cnv_cmplt(cnv_cmplt), .res(res)); 

/// Counter ////
always @ (posedge clk, negedge rst_n)
	if(!rst_n) chnnl <= 3'b000;
	else if(cnv_cmplt && (chnnl != 3'b100)) chnnl <= chnnl + 1;
	else if(cnv_cmplt && (chnnl == 3'b100)) chnnl <= 3'b111;


/// State machine ///
typedef enum reg {WAIT, GO} state_t;
state_t state, nxt;

always_ff @ (posedge clk, negedge rst_n)
	if(!rst_n) state <= WAIT;
	else state <= nxt;

always_comb begin
	nxt = WAIT;
	strt_cnv = 0;
	case(state)
	 WAIT: begin
		strt_cnv = 1;
		nxt = GO;
	 end
	 GO: if(!cnv_cmplt) nxt = GO;
	endcase  
	
end


reg[23:0] resSqr;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) resSqr <= 24'd0;
	else resSqr <= res * res;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) POT_LP <= 24'h000000;
	else if((chnnl == 3'b001) && cnv_cmplt) POT_LP <= resSqr;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) POT_B1 <= 24'h000000;
	else if((chnnl == 3'b000) && cnv_cmplt) POT_B1 <= resSqr;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) POT_B2 <= 24'h000000;
	else if((chnnl == 3'b100) && cnv_cmplt) POT_B2 <= resSqr;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) POT_B3 <= 24'h000000;
	else if((chnnl == 3'b010) && cnv_cmplt) POT_B3 <= resSqr;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) POT_HP <= 24'h000000;
	else if((chnnl == 3'b011) && cnv_cmplt) POT_HP <= resSqr;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) VOLUME <= 12'h000;
	else if((chnnl == 3'b111) && cnv_cmplt) VOLUME <= res;

endmodule 
