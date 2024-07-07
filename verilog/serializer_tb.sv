`include "serializer.sv"

module serializer_tb;

   logic clk_pixel       = 0;
   logic clk_pixel_x10   = 0;
   logic clk_pixel_x5    = 0;
   logic reset           = 0;
   logic [9:0] tmds_internal [2:0];
   logic [2:0] tmds;

   initial begin
    $dumpfile("serializer.vcd");
    $dumpvars(0, uut);
    //$dumpoff;
    #0
    clk_pixel = 0;
    clk_pixel_x5 = 0;
    clk_pixel_x10 = 0;
    tmds_internal[2] = 10'd0;
    tmds_internal[1] = 10'd0;
    tmds_internal[0] = 10'd0;
    //#500000
    // $dumpon;
    #5000
    $finish;
   end
   
   serializer #(
       .NUM_CHANNELS(3),
       .VIDEO_RATE(5)
   ) uut (
       .clk_pixel(clk_pixel),		//i
       .clk_pixel_x10(clk_pixel_x10),  //i
       .clk_pixel_x5(clk_pixel_x5),  //i
       .reset(reset),          //i
       .tmds_internal(tmds_internal),  //i
       .tmds(tmds),  //o [2:0]
       .tmds_clock(tmds_clock)   //o
   );

always begin
    #1
	clk_pixel_x10 = !clk_pixel_x10;
end
always begin
	#2
	clk_pixel_x5 = !clk_pixel_x5;
end
always begin
	#10
	clk_pixel = !clk_pixel;
	tmds_internal[0] = tmds_internal[0] + 1;
end
endmodule
