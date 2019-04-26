module BT_intf(clk, rst_n, next_n, prev_n, RX, TX, cmd_n);

input clk, rst_n, next_n, prev_n, RX;
output reg cmd_n;
output TX;

wire nxtRise;
PB_rise iNext(.PB(next_n), .clk(clk), .rst_n(rst_n), .rise(nxtRise));
wire prevRise;
PB_rise iPrev(.PB(prev_n), .clk(clk), .rst_n(rst_n), .rise(prevRise));

reg[16:0] cnt;
reg full;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) cnt <= 17'd0;
	else cnt <= cnt + 1;
//assign full = &cnt;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) full <= 0;
	else if(&cnt == 1'b1) full <= 1;

reg[4:0] cmd_start;
reg[3:0] cmd_len;
reg send;
wire resp_rcvd;

snd_cmd iSND(.clk(clk), .rst_n(rst_n), .cmd_start(cmd_start), .cmd_len(cmd_len),
	.send(send), .resp_rcvd(resp_rcvd), .RX(RX), .TX(TX));

typedef enum reg [1:0] {INIT, CMD1, CMD2, SWITCH} state_t;
state_t state, nxt;

always_ff @ (posedge clk, negedge rst_n)
	if(!rst_n) state <= INIT;
	else state <= nxt;

always_comb begin
	nxt = INIT;
	cmd_n = 1'b1;
	cmd_start = 5'b00000;
	cmd_len = 4'b0110;
	send = 1'b0;
case(state)
	INIT: 	if(full) begin
			cmd_n = 1'b0;
			if(resp_rcvd) begin
				nxt = CMD1;
				send = 1'b1;
			end
		end
	CMD1: begin
		cmd_n = 1'b0; 	
		if(resp_rcvd) begin 
			nxt = CMD2;
			send = 1'b1;
			cmd_start = 5'b00110;
			cmd_len = 4'b1010;
		end
		else begin
			nxt = CMD1;
		end
	end
	CMD2: begin
		cmd_n = 1'b0;
		if(resp_rcvd)
			nxt = SWITCH;
		else
			nxt = CMD2;
	end
	SWITCH: begin
		cmd_n = 1'b0;
		nxt = SWITCH;
		if(nxtRise) begin
			send = 1'b1;
			cmd_start = 5'b10000;
			cmd_len = 4'b0100;
		end
		if(prevRise) begin
			send = 1'b1;
			cmd_start = 5'b10100;
			cmd_len = 4'b0100;
		end
	end
endcase
end

endmodule
			
	      
	
	
