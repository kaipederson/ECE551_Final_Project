module I2S_Slave(clk,rst_n,lft_chnnl,rght_chnnl,vld,I2S_sclk, I2S_ws,I2S_data);

	input clk, rst_n, I2S_data, I2S_sclk, I2S_ws;

	output logic [23:0] lft_chnnl, rght_chnnl;
	output logic vld;
	
    reg[47:0] shft_reg;
	reg[5:0] bit_cntr;
	reg clr_cnt, sclk_rise;
	reg risedetect1,risedetect2,risedetect3,falldetect1,falldetect2,falldetect3,ws_fall;

	typedef enum reg [2:0] {IDLE, REC, WAIT, END} state_t;
	state_t state, nxt_state;


	//bit counter
	always @(posedge clk, negedge rst_n)
		begin
			if (!rst_n)
				bit_cntr = 6'b000000;
			else	
			begin
				if (clr_cnt)
					bit_cntr = 6'b000000;
				else if (sclk_rise)
					bit_cntr = bit_cntr + 1'b1;
			end
		end
	
	assign eq46 = (bit_cntr == 6'h2D);
	assign eq47 = (bit_cntr == 6'h2E);
	assign eq48 = (bit_cntr == 6'h30);
	
	//shift reg
	always @(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			shft_reg <= 48'h000000000000;
		else
		begin
			if (sclk_rise)
			begin	
				shft_reg <= {shft_reg[46:0], I2S_data};
			end
		end
	end
	
	//synch & + edge detect
    always @(posedge clk) begin
        risedetect1 <= I2S_sclk;
        risedetect2 <= risedetect1;
        risedetect3 <= risedetect2;
        falldetect1 <= I2S_ws;
        falldetect2 <= falldetect1;
        falldetect3 <= falldetect2;
    end
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            sclk_rise = 1'b0;
            ws_fall = 1'b0;
        end
        else begin
            sclk_rise = (!risedetect3 && risedetect2);
            ws_fall = (falldetect3 && !falldetect2);
        end
    end
		
	//State Machine
	always_ff @(posedge clk, negedge rst_n)
		begin
			if (!rst_n)
				state <= IDLE;
			else
				state <= nxt_state;
		end
		
	always_comb
		begin
		vld = 1'b0;
		clr_cnt = 1'b0;
		nxt_state = IDLE;
		case (state)
			WAIT:
				begin
					if (sclk_rise)
						begin
							nxt_state = REC;
							clr_cnt = 1'b1;
						end
					else
						nxt_state = WAIT;
				end
			REC:
				begin
					if (eq46 | eq47)
						begin
						if (!I2S_ws)
							nxt_state = IDLE;
						else
							nxt_state = REC;
						end
					else if (eq48)
						begin
						if (!I2S_ws)
						begin
								vld = 1'b1;
								lft_chnnl = shft_reg[23:0];
								rght_chnnl = shft_reg[47:24];
								clr_cnt = 1'b1;
								nxt_state = REC;
						end
						end
					else
						nxt_state = REC;
				end	
			//IDLE STATE
			default:
				begin
					if (ws_fall)
						nxt_state = WAIT;
				end
		endcase	
		end	
		
endmodule