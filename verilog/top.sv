
`timescale 1ns / 1ps

module top (
	input		clk48,
	input		usr_btn,	// SW0,
	output		rst_n,
	output 		rgb_led0_r,	// [0:0]LED,
	output 		rgb_led0_g,	// [0:0]LED,
	output 		rgb_led0_b,	// [0:0]LED,
    output		gpio_0,		// HDMO 0p
	output		gpio_1,		// HDMI 0n
	output 		gpio_5,		// HDMO 1p
	output 		gpio_6,		// HDMO 1n
	output		gpio_9,		// HDMI 2p
    output		gpio_10,	// HDMO 2n
	output 		gpio_11,	// HDMO cp
	output 		gpio_12		// HDMO cn
);

	assign rgb_led0_r = 0;
	assign rgb_led0_g = 0;
	assign rgb_led0_b = 0;

	wire [2:0]  HDMI_OUT;
	wire		HDMI_CLK;

	assign gpio_0  = HDMI_OUT[0];
	assign gpio_1  = ~HDMI_OUT[0];
	assign gpio_5  = HDMI_OUT[1];
	assign gpio_6  = ~HDMI_OUT[1];
	assign gpio_9  = HDMI_OUT[2];
	assign gpio_10 = ~HDMI_OUT[2];
	assign gpio_11 = HDMI_CLK;
	assign gpio_12 = ~HDMI_CLK;

    wire clk_pixel_x5;
    wire clk_pixel;
    wire clk_audio;
    hdmi_pll hdmi_pll(.inclk0(CLOCK_50), .c0(clk_pixel), .c1(clk_pixel_x5), .c2(clk_audio));

    localparam AUDIO_BIT_WIDTH = 16;
    localparam AUDIO_RATE = 48000;
    localparam WAVE_RATE = 480;

    logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word;
    logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word_dampened; // This is to avoid giving you a heart attack -- it'll be really loud if it uses the full dynamic range.
    assign audio_sample_word_dampened = audio_sample_word >> 9;

    //sawtooth #(.BIT_WIDTH(AUDIO_BIT_WIDTH), .SAMPLE_RATE(AUDIO_RATE), .WAVE_RATE(WAVE_RATE)) sawtooth (.clk_audio(clk_audio), .level(audio_sample_word));

    logic [23:0] rgb;// = 24'd523700000000;
    logic [9:0] cx, cy;
    hdmi #( .VIDEO_ID_CODE(4),
            .AUDIO_RATE(AUDIO_RATE),
            .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH))
        hdmi(.clk_pixel_x5(clk_pixel_x5),
             .clk_pixel(clk_pixel),
             .clk_audio(clk_audio),
             .rgb(rgb),
             .audio_sample_word('{audio_sample_word_dampened, audio_sample_word_dampened}),
             .tmds(HDMI_OUT),
             .tmds_clock(HDMI_CLK),
             .cx(cx),
             .cy(cy));

    logic [7:0] character = 8'h30;
    logic [5:0] prevcy = 6'd0;
    always @(posedge clk_pixel) begin
        if (cy == 10'd0) begin
            character <= 8'h30;
            prevcy <= 6'd0;
        end else if (prevcy != cy[9:4]) begin
            character <= character + 8'h01;
            prevcy <= cy[9:4];
        end
    end

	// RNG
    LFSR #(.NUM_BITS(24)) LSFR (
       .i_Clk(CLOCK_50),
       .i_Enable(1),
       .o_LFSR_Data(rgb)
    );

    //console console(.clk_pixel(clk_pixel), .codepoint(character), .attribute({cx[9], cy[8:6], cx[8:5]}), .cx(cx), .cy(cy), .rgb(rgb));


// Reset logic on button press.
// this will enter the bootloader
reg reset_sr = 1'b1;
always @(posedge clk48) begin
	reset_sr <= {usr_btn};
end
assign rst_n = reset_sr;
endmodule
