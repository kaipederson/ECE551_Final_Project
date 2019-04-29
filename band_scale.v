module band_scale(scaled, POT, audio);

input[23:0] POT;
input signed[15:0] audio;
output signed[15:0] scaled;

wire signed[12:0] POT_scale;
assign POT_scale = {1'b0,POT[23:12]};

wire signed[28:0] product;
assign product = POT_scale * audio;

wire sat_flag_neg;
wire sat_flag_pos;

assign sat_flag_neg = product[28] & ~(&product[27:25]);
assign sat_flag_pos = ~product[28] & |product[27:25];

assign scaled = sat_flag_neg ? 16'h8000 : (sat_flag_pos ? 16'h7FFF : product[25:10]);

endmodule  