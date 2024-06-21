module serializer #(
    parameter int NUM_CHANNELS = 3,
    parameter real VIDEO_RATE = 5
)(
    input logic clk_pixel,
    input logic clk_pixel_x5,
    input logic reset,
    input logic [9:0] tmds_internal [NUM_CHANNELS-1:0],
    output logic [2:0] tmds,
    output logic tmds_clock
);
logic [9:0] tmds_reversed [NUM_CHANNELS-1:0];
genvar i, j;
generate
	for (i = 0; i < NUM_CHANNELS; i++)
	begin: tmds_rev
		for (j = 0; j < 10; j++)
		begin: tmds_rev_channel
			assign tmds_reversed[i][j] = tmds_internal[i][9-j];
		end // for j
	end // for i
endgenerate
logic [9:0] tmds_shift [NUM_CHANNELS-1:0] = {10'd0, 10'd0, 10'd0};

logic tmds_control = 1'd0;
always_ff @(posedge clk_pixel)
begin
	tmds_control <= !tmds_control;
end

logic [3:0] tmds_control_synchronizer_chain = 4'd0;
always_ff @(posedge clk_pixel_x5)
begin
	tmds_control_synchronizer_chain <= {tmds_control, tmds_control_synchronizer_chain[3:1]};
end

logic load;
assign load = tmds_control_synchronizer_chain[1] ^ tmds_control_synchronizer_chain[0];
logic [9:0] tmds_mux [NUM_CHANNELS-1:0];
always_comb
begin
	if (load)
		tmds_mux = tmds_internal;
	else
		tmds_mux = tmds_shift;
end

// See Section 5.4.1
generate
	for (i = 0; i < NUM_CHANNELS; i++)
	begin: tmds_shifting
		always_ff @(posedge clk_pixel_x5)
		begin
			tmds_shift[i] <= load ? tmds_mux[i] : tmds_shift[i] >> 2;
		end
	end // for i
endgenerate

logic [9:0] tmds_shift_clk_pixel = 10'b0000011111;
always_ff @(posedge clk_pixel_x5)
begin
	tmds_shift_clk_pixel <= load ? 10'b0000011111 : {tmds_shift_clk_pixel[1:0], tmds_shift_clk_pixel[9:2]};
end

logic [NUM_CHANNELS-1:0] tmds_shift_negedge_temp;
generate
	for (i = 0; i < NUM_CHANNELS; i++)
	begin: tmds_driving
		always_ff @(posedge clk_pixel_x5) begin
			if (clk_pixel_x5) begin
				tmds[i] <= tmds_shift[i][0];
				tmds_shift_negedge_temp[i] <= tmds_shift[i][1];
			end else begin
				tmds[i] <= tmds_shift_negedge_temp[i];
			end
		end
	/*				
		always_ff @(posedge clk_pixel_x5)
		begin
			tmds[i] <= tmds_shift[i][0];
			tmds_shift_negedge_temp[i] <= tmds_shift[i][1];
		end
		always_ff @(negedge clk_pixel_x5)
		begin
			tmds[i] <= tmds_shift_negedge_temp[i];
		end
		*/
	end // for i
endgenerate
logic tmds_clock_negedge_temp;
always @(posedge clk_pixel_x5) begin
	if (clk_pixel_x5) begin
		tmds_clock <= tmds_shift_clk_pixel[0];
		tmds_clock_negedge_temp <= tmds_shift_clk_pixel[1];
	end else begin
		tmds_clock <= tmds_shift_negedge_temp[0] | tmds_shift_negedge_temp[1] | tmds_shift_negedge_temp[2]; // XXX I'm guessing
	end
end
/*
always @(posedge clk_pixel_x5)
begin
	tmds_clock <= tmds_shift_clk_pixel[0];
	tmds_clock_negedge_temp <= tmds_shift_clk_pixel[1];
end
always @(negedge clk_pixel_x5)
begin
	tmds_clock <= tmds_shift_negedge_temp;
end
*/
endmodule
