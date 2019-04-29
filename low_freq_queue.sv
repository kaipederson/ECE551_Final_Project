module low_freq_queue(clk, rst_n, lft_smpl, rght_smpl, wrt_smpl, 
		lft_out, rght_out, sequencing);

input clk, rst_n, wrt_smpl;
input[15:0] lft_smpl, rght_smpl;
output reg sequencing;
output reg [15:0] lft_out, rght_out;

reg[9:0] new_ptr, old_ptr, read_ptr;

dualPort1024x16 iLFT(.clk(clk), .we(wrt_smpl), .waddr(new_ptr), .raddr(read_ptr),
	.wdata(lft_smpl), .rdata(lft_out));

dualPort1024x16 iRGHT(.clk(clk), .we(wrt_smpl), .waddr(new_ptr), .raddr(read_ptr),
	.wdata(rght_smpl), .rdata(rght_out));

reg full, rst_rd, inc_old, inc_new, inc_read;
wire[9:0] end_ptr;
wire done;

always @ (posedge clk, negedge rst_n)
	if(!rst_n) full <= 0;
	else if(new_ptr == 10'd1020) full <= 1;

always @ (posedge clk, negedge rst_n)
	if(!rst_n) old_ptr <= 10'd0;
	else if(inc_old) old_ptr <= old_ptr + 1;

always @ (posedge clk, negedge rst_n)
	if(!rst_n) new_ptr <= 10'd0;
	else if(inc_new) new_ptr <= new_ptr + 1;

always @ (posedge clk, posedge rst_rd)
	if(rst_rd) read_ptr <= old_ptr;
	else begin
		if(inc_read) read_ptr <= read_ptr + 1;
	end

assign end_ptr = old_ptr + 10'd1020;
assign done = (read_ptr == end_ptr);

typedef enum reg {WRITE, SEQ} state_t;
state_t state, nxt;

always @ (posedge clk, negedge rst_n)
	if(!rst_n) state <= WRITE;
	else state <= nxt;

always_comb begin
	inc_new = 1'b0;
	inc_old = 1'b0;
	inc_read = 1'b0;
	sequencing = 1'b0;
	rst_rd = 1'b0;
	nxt = WRITE;
	case(state)
	 WRITE: begin
		if(wrt_smpl) begin
			if(!full) begin 
				inc_new = 1'b1;
			end
			else begin
				inc_new = 1'b1;
				inc_old = 1'b1;
				inc_read = 1'b1;
				rst_rd = 1'b1;
				nxt = SEQ;
			end
		end
	end
	 SEQ: begin
		if(!done) begin
			inc_read = 1'b1;
			sequencing = 1'b1;
			nxt = SEQ;
		end
		else begin
			sequencing = 1'b1;
			rst_rd = 1'b1;
		end
	end
	endcase
end
			 
endmodule 