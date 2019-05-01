module snd_cmd(cmd_start, send, cmd_len, clk, rst_n, RX,
		TX, resp_rcvd);

input clk, rst_n, send, RX;
input[4:0] cmd_start;
input[3:0] cmd_len;
output TX;
output reg resp_rcvd;

//////////////////
// cmdROM input //
//////////////////
reg[4:0] inROM;
logic inc_addr;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) inROM <= 5'h00;
	else if(send) inROM <= cmd_start;
	else if(inc_addr) inROM <= inROM + 1;

////////////////////////
// Instantiate cmdROM //
////////////////////////
wire[7:0] dout;
cmdROM iROM(.clk(clk), .addr(inROM), .dout(dout));

//////////////////////
// Instantiate UART //
//////////////////////
wire[7:0] rx_data;
wire rx_rdy, tx_done;
reg trmt;
UART iUART(.clk(clk), .rst_n(rst_n), .RX(RX), .TX(TX), .rx_rdy(rx_rdy), .clr_rx_rdy(rx_rdy),
		.rx_data(rx_data), .trmt(trmt), .tx_data(dout), .tx_done(tx_done));

assign resp_rcvd = (rx_rdy && (rx_data == 8'h0A));

///////////////////////////
// Last byte computation //
/////////////////////////// 
reg[4:0] last;
wire last_byte;
always @ (posedge clk, negedge rst_n)
	if(!rst_n) last <= 5'h00;
	else if(send) last <= cmd_start + cmd_len;

assign last_byte = (inROM == last) ? 1'b1 : 1'b0;

///////////////////
// State Machine //
///////////////////
typedef enum reg[1:0] {IDLE, ROM, SEND, WAIT} state_t;
state_t state, nxt;

always_ff @ (posedge clk, negedge rst_n)
	if(!rst_n) state <= IDLE;
	else state <= nxt;

always_comb begin
	trmt = 0;
	inc_addr = 0;
	nxt = IDLE;
	case(state)
	 ROM: nxt = SEND;
	 SEND:
		begin  	
			trmt = 1;
			inc_addr = 1;
			nxt = WAIT;
		end
	 WAIT:	
		if(last_byte) nxt = IDLE;
		else if(tx_done)nxt = SEND;
		else nxt = WAIT;
	 default:
		if(send)
			nxt = ROM;

	endcase

		
end
	

endmodule 
