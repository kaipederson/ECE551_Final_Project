module LED(clk, rst_n, audio_out,LED);
input  [15:0] audio_out;
input clk,rst_n;
output reg unsigned [7:0] LED;

reg go,done;
reg  [15:0] avg_intens_signed;
reg  [15:0] avg_intens;
reg  [7:0] sqrt;
reg [15:0] audio_out1,audio_out2,audio_out3,audio_out4;

sqrt iSqrt(.mag(avg_intens),.go(go),.clk(clk),.rst_n(rst_n),.sqrt(sqrt),.done(done));


//do average of 10 audio_outs
always @(posedge clk,negedge rst_n)begin
	if(!rst_n) begin
		audio_out1 = 16'h0000;
		audio_out2 = 16'h0000;
		audio_out3 = 16'h0000;
		audio_out4 = 16'h0000;
	end
	audio_out1 <= audio_out;
	audio_out1 <= audio_out;
 	audio_out2 <= audio_out1;
	audio_out3 <= audio_out2;
	audio_out4 <= audio_out3;
end
always@(posedge clk, negedge rst_n)begin
	if(!rst_n) begin
		avg_intens_signed = 16'h0000;
		LED = 8'h00;
		go = 1'b0;
	end
	else begin
		avg_intens_signed = (audio_out + audio_out1 + audio_out2 + audio_out3 + audio_out4)/3'b101;
		//avg_intens_signed = audio_out;
		avg_intens = {1'b0,avg_intens_signed[14:0]};
		go = 1'b1;
	end
	if(done) LED = sqrt;
end

endmodule
