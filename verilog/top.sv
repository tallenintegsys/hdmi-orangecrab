`timescale 1ns / 1ps

module top (
    input       clk48,
    input       usr_btn,    // SW0,
    output      rst_n,
    output reg  rgb_led0_r,
    output reg  rgb_led0_g,
    output reg  rgb_led0_b,
    output      gpio_0,        // HDMI 0p
    output      gpio_1,        // HDMI 0n
    output      gpio_5,        // HDMI 1p
    output      gpio_6,        // HDMI 1n
    output      gpio_9,        // HDMI 2p
    output      gpio_10,       // HDMI 2n
    output      gpio_13,       // HDMI cn
    output      gpio_12,       // HDMI cp
    output      gpio_a0,       // clk48
    output      gpio_a1,       // clk_pixel
    output      gpio_a3        // clk_audio
);

    assign rgb_led0_r = ~locked;
    //assign rgb_led0_g = 1;
    //assign rgb_led0_b = 1;

    wire [2:0]  HDMI_OUT;
    wire        HDMI_CLK;

    assign gpio_0  = HDMI_OUT[0];
    assign gpio_1  = ~HDMI_OUT[0];
    assign gpio_5  = HDMI_OUT[1];
    assign gpio_6  = ~HDMI_OUT[1];
    assign gpio_9  = HDMI_OUT[2];
    assign gpio_10 = ~HDMI_OUT[2];
    assign gpio_12 = HDMI_CLK;
    assign gpio_13 = ~HDMI_CLK;

    assign gpio_a0 = clk48;
    assign gpio_a1 = clk_pixel;
    assign gpio_a3 = clk_audio;

    wire clk_pixel_x5;
    wire clk_pixel;
    wire clk_audio;
    wire locked;

    hdmi_pll hdmi_pll(
        .inclk0(clk48),
        .c0(clk_pixel),
        .c1(clk_pixel_x5),
        .c2(clk_audio),
        .locked(locked)
    );

    localparam AUDIO_BIT_WIDTH = 16;
    localparam AUDIO_RATE = 48000;
    localparam WAVE_RATE = 480;

    logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word;
    logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word_dampened; // This is to avoid giving you a heart attack -- it'll be really loud if it uses the full dynamic range.
    assign audio_sample_word_dampened = audio_sample_word >> 9;

    //sawtooth #(.BIT_WIDTH(AUDIO_BIT_WIDTH), .SAMPLE_RATE(AUDIO_RATE), .WAVE_RATE(WAVE_RATE)) sawtooth (.clk_audio(clk_audio), .level(audio_sample_word));

    logic [23:0] rgb;// = 24'd523700000000;
    logic [9:0] cx, cy;

    hdmi #(
      .VIDEO_ID_CODE(4),
      .AUDIO_RATE(AUDIO_RATE),
      .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH))
    hdmi(
      .clk_pixel_x5(clk_pixel_x5),
      .clk_pixel(clk_pixel),
      .clk_audio(clk_audio),
      .rgb(rgb),
      .audio_sample_word('{audio_sample_word_dampened, audio_sample_word_dampened}),
      .tmds(HDMI_OUT),
      .tmds_clock(HDMI_CLK),
      .cx(cx),
      .cy(cy)
    );

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
       .i_Clk(clk48),
       .i_Enable(1),
       .o_LFSR_Data(rgb)
    );

    //console console(.clk_pixel(clk_pixel), .codepoint(character), .attribute({cx[9], cy[8:6], cx[8:5]}), .cx(cx), .cy(cy), .rgb(rgb));
reg [31:0] counter = 0;
always @(posedge clk_pixel_x5) begin
	counter <= counter + 32'd1;
	if ( counter == 32'd125000000 ) begin
		counter <= 32'd0;
		rgb_led0_b <= ~rgb_led0_b;
	end
end

reg [31:0] c = 0;
always @(posedge clk48) begin
	c <= c + 32'd1;
	if ( c == 32'd48000000 ) begin
		c <= 32'd0;
		rgb_led0_g <= ~rgb_led0_g;
	end
end

// Reset logic on button press.
// this will enter the bootloader
reg reset_sr = 1'b1;
always @(posedge clk48) begin
    reset_sr <= {usr_btn};
end
assign rst_n = reset_sr;
endmodule
