module A2D_intf(chnnl, strt_cnv, clk, rst_n, MISO, 
		cnv_cmplt, res, SS_n, SCLK, MOSI);

input[2:0] chnnl;
input strt_cnv, clk, rst_n, MISO;

output[11:0] res;
output reg cnv_cmplt;
output SS_n, SCLK, MOSI;


typedef enum reg [1:0] {DFLT, CONV, WAIT, FETCH} state_t;
state_t state, nxt;

always_ff @ (posedge clk, negedge rst_n)
	if(!rst_n) state <= DFLT;
	else state <= nxt;


reg wrt, fin;
wire done;

SPI_mstr mstr(.wrt(wrt), .done(done), .rd_data(res), .SS_n(SS_n), .SCLK(SCLK), .clk(clk),
		.MOSI(MOSI), .MISO(MISO), .wt_data({2'b00,chnnl,11'h000}), .rst_n(rst_n));

always_comb begin
	wrt = 1'b0;
	fin = 1'b0;
	nxt = DFLT;
	
	case(state) 
		CONV:  
			if(done) begin
				nxt = WAIT;
				end
			else	begin
				nxt = CONV;
				end
		WAIT: 	
			begin
				wrt = 1'b1;
				nxt = FETCH;
			end
		FETCH:
			if(done) begin
				fin = 1'b1;
			end
			else begin
				nxt = FETCH;
			end
		default:
			if(strt_cnv) begin
				wrt = 1'b1;
				nxt = CONV;
			end
			
	endcase
end

always @ (posedge clk, negedge rst_n)
	if(!rst_n) cnv_cmplt <= 1'b0;
	else if (fin)
          cnv_cmplt <= 1'b1;
        else
           cnv_cmplt <= 1'b0;



endmodule 
	
	