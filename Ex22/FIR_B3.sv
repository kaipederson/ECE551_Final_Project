module FIR_B3(lft_in,sequencing,rght_in,lft_out,rght_out,clk,rst_n);
	input[15:0] lft_in,rght_in;
	input sequencing,clk,rst_n;
	output[15:0] lft_out,rght_out;
	
	logic accum,clr_accum,clr_ROM_pntr;
	reg signed [31:0] lft_sig,rght_sig;
	wire signed [31:0] rght_fltd_sig, lft_fltd_sig;
	reg[10:0] addr;
	wire signed [15:0] scaler;
	
	typedef enum reg[1:0]{WAIT,SEQ} state_t;
	state_t state,nxt_state;
	
	ROM_B3 coeff(.clk(clk),.addr(addr),.dout(scaler));
	
	//Multiplier
	assign rght_fltd_sig = scaler*rght_in;
	assign lft_fltd_sig = scaler*lft_in;
	
	//State Machine
	always@(posedge clk,negedge rst_n)begin
		if(!rst_n)begin
			state <= WAIT;
		end
		else state <= nxt_state;
	end
	
	always_comb begin
		accum = 1'b0;
		clr_accum = 1'b0;
		clr_ROM_pntr = 1'b1;
		nxt_state = WAIT;
		case(state)
			WAIT: begin
				if(sequencing)begin
					nxt_state = SEQ;
					clr_accum = 1'b1;
					clr_ROM_pntr = 1'b0;
				end
			end
			SEQ: begin
				if(sequencing)begin
					accum = 1'b1;
					nxt_state = SEQ;
					clr_ROM_pntr = 1'b0;
				end
				else begin
					clr_ROM_pntr = 1'b1;
				end
			end
		endcase
	end
	
	
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			lft_sig = 32'h00000000;
			rght_sig = 32'h00000000;
		end
		else begin
			if(clr_accum)begin
				lft_sig = 32'h00000000;
				rght_sig = 32'h00000000;
			end
			else if (accum)begin
				lft_sig = lft_fltd_sig+lft_sig;
				rght_sig = rght_fltd_sig+rght_sig;
			end
		end
	end
	
	assign lft_out = lft_fltd_sig[30:15];
	assign rght_out = rght_fltd_sig[30:15];
	
	//counter
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			addr = 11'h000;
		end
		else begin
			if(!clr_ROM_pntr)begin
				addr = addr +1'b1;
			end
			else addr = 11'h000;
		end
	end
	
	
endmodule