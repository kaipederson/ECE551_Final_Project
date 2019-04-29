module SPI_mstr(clk, rst_n, SS_n, SCLK, MOSI, MISO,
		wrt, wt_data, done, rd_data);

input clk, rst_n, MISO, wrt;
input[15:0] wt_data;

output reg SS_n, SCLK, MOSI, done;
output reg[15:0] rd_data;

reg init;

// Bit Counter/////////////////////////////////
reg done16;
reg[4:0] bit_cntr;
reg shft;

always @ (posedge clk or negedge rst_n) begin

	if(!rst_n) bit_cntr <= 5'b00000;
	else if(init) bit_cntr <= 5'b00000;
	else if(shft) bit_cntr <= bit_cntr + 1;

end

assign done16 = bit_cntr[4];
///////////////////////////////////////////////

// SCLK Counter////////////////////////////////
reg[3:0] SCLK_div;
reg ld_SCLK;
reg full;

always @ (posedge clk or negedge rst_n) begin
	
	if(!rst_n) SCLK_div <= 4'b1011;
	else if(ld_SCLK) SCLK_div <= 4'b1011;
	else SCLK_div <= SCLK_div + 1;
		
end
		
assign SCLK = SCLK_div[3];
assign full = (SCLK_div == 4'b1110) ? 1 : 0;
assign shft = (SCLK_div == 4'b1001) ? 1 : 0;
///////////////////////////////////////////////

// Shift Reg///////////////////////////////////
reg[15:0] shft_reg;

always @ (posedge clk or negedge rst_n) begin

	if(!rst_n) shft_reg <= 16'h0000;
	else if(init == 1) shft_reg <= wt_data;
	else if((init == 0) && (shft == 1)) shft_reg <= {shft_reg[14:0],MISO};

end

assign MOSI = shft_reg[15];
assign rd_data = shft_reg;
//////////////////////////////////////////////

// State Machine//////////////////////////////
typedef enum reg [1:0] {IDLE, SHIFT, PORCH} state_t;
state_t state, nxt;

always_ff @ (posedge clk or negedge rst_n) begin

	if(!rst_n) state <= IDLE;
	else state <= nxt;

end

reg set_done;

always_comb begin
	//defaults
	init = 0;
	ld_SCLK = 0;
	set_done = 0;
	
	case(state)
	 IDLE : begin
		ld_SCLK = 1;
		if(wrt) begin
			init = 1;
			nxt = SHIFT;
		end
		else nxt = IDLE;
		end
	
	 SHIFT: if(done16) nxt = PORCH;
		else nxt = SHIFT;

	 PORCH: if(full) begin
			set_done = 1;
			nxt = IDLE;
		end
		else nxt = PORCH;
	 
	endcase
end	

// Done latch
always @ (posedge clk or negedge rst_n) begin
	//if(!rst_n || init) done <= 0;
	if(!rst_n) done <= 0;
	else if(init) done <= 0;
	else if (set_done) done <= 1;
end

// SS_n latch
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) SS_n <= 1;
	else if (init) SS_n <= 0;
	else if (set_done) SS_n <= 1;
end

endmodule
