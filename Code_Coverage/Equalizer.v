module Equalizer(clk,RST_n,LED,ADC_SS_n,ADC_MOSI,ADC_SCLK,ADC_MISO,
                 I2S_data,I2S_ws,I2S_sclk,cmd_n,sht_dwn,lft_PDM,
				 rght_PDM,Flt_n,next_n,prev_n,RX,TX);
				  
    input clk;			// 50MHz CLOCK
	input RST_n;		// unsynched active low reset from push button
	output [7:0] LED;	// Extra credit opportunity, otherwise tie low
	output ADC_SS_n;	// Next 4 are SPI interface to A2D
	output ADC_MOSI;
	output ADC_SCLK;
	input ADC_MISO;
	input I2S_data;		// serial data line from BT audio
	input I2S_ws;		// word select line from BT audio
	input I2S_sclk;		// clock line from BT audio
	output cmd_n;		// hold low to put BT module in command mode
	output reg sht_dwn;	// hold high for 5ms after reset
	output lft_PDM;		// Duty cycle of this drives left speaker
	output rght_PDM;	// Duty cycle of this drives right speaker
	input Flt_n;		// when low Amp(s) had a fault and needs sht_dwn
	input next_n;		// active low to skip to next song
	input prev_n;		// active low to repeat previous song
	input RX;			// UART RX (115200) from BT audio module
	output TX;			// UART TX to BT audio module
		
	///////////////////////////////////////////////////////
	// Declare and needed wires or registers below here //
	/////////////////////////////////////////////////////
	wire rst_n; 
	wire[23:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP;
	wire[11:0] VOLUME;
	wire[23:0] lftI2S, rghtI2S;
	wire vld;
	wire[15:0] aud_eq_lft, aud_eq_rght;

	/////////////////////////////////////
	// Instantiate Reset synchronizer //
	///////////////////////////////////
	rst_synch iRST(.clk(clk), .rst_n(rst_n), .RST_n(RST_n));

	//////////////////////////////////////
	// Instantiate Slide Pot Interface //
	////////////////////////////////////					
	slide_intf iSLD(.clk(clk), .rst_n(rst_n), .MISO(ADC_MISO), .MOSI(ADC_MOSI),
		.SCLK(ADC_SCLK), .SS_n(ADC_SS_n), .POT_LP(POT_LP), .POT_B1(POT_B1),
		.POT_B2(POT_B2), .POT_B3(POT_B3), .POT_HP(POT_HP), .VOLUME(VOLUME));
				  
	//////////////////////////////////////
	// Instantiate BT module interface //
	////////////////////////////////////
	BT_intf iBT(.clk(clk), .rst_n(rst_n), .next_n(next_n), .prev_n(prev_n), 
		.RX(RX), .TX(TX), .cmd_n(cmd_n));

    	//////////////////////////////////////
    	// Instantiate I2S_Slave interface //
    	////////////////////////////////////
	I2S_Slave iSlave(.clk(clk), .rst_n(rst_n), .lft_chnnl(lftI2S), .rght_chnnl(rghtI2S),
		.vld(vld), .I2S_sclk(I2S_sclk), .I2S_ws(I2S_ws), .I2S_data(I2S_data));
		
    	//////////////////////////////////////////
    	// Instantiate EQ_engine or equivalent //
    	////////////////////////////////////////
	EQ_Engine iEng(.clk(clk), .rst_n(rst_n), .vld(vld), .aud_in_lft(lftI2S[23:8]), .aud_in_rght(rghtI2S[23:8]),
		.POT_LP(POT_LP), .POT_B1(POT_B1), .POT_B2(POT_B2), .POT_B3(POT_B3), .POT_HP(POT_HP),
		.VOL_POT(VOLUME), .aud_out_lft(aud_eq_lft), .aud_out_rght(aud_eq_rght));

	
	/////////////////////////////////////
	// Instantiate PDM speaker driver //
	///////////////////////////////////
	spkr_drv iSPKR(.clk(clk), .rst_n(rst_n), .lft_chnnl(aud_eq_lft), .rght_chnnl(aud_eq_rght),
		.vld(vld), .lft_PDM(lft_PDM), .rght_PDM(rght_PDM));
	
	///////////////////////////////////////////////////////////////
	// Infer sht_dwn/Flt_n logic or incorporate into other unit //
	/////////////////////////////////////////////////////////////
	reg[17:0] cnt;
	wire clr_cnt;
	assign clr_cnt = (!Flt_n) ? (1'b1) : (cnt == 18'd250000) ? 1'b1 : 1'b0;
	always @ (posedge clk, negedge rst_n, negedge Flt_n) begin
		if(!rst_n) begin 
			sht_dwn <= 1'b1;
		end
		else begin
		if(!Flt_n)
			begin
			sht_dwn <= 1'b1;
	
		end
		else if(cnt == 18'd250000) begin
			sht_dwn <= 1'b0;
		
		end
		end
	end

	always @ (posedge clk, negedge rst_n)
		if(!rst_n) cnt <= 18'd0;
		else begin
			cnt <= cnt + 1'b1;
			if(clr_cnt) cnt <= 18'd0;
		end
	
	assign LED = 8'h00;


endmodule
