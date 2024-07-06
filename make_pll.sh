#!/bin/bash -x

pixel="25.2" 
pixelx5=`echo "$pixel * 5" | bc`

ecppll \
  -n hdmi_pll \
  --clkin_name inclk0 -i48 \
  --clkout0_name c1 -o $pixelx5 \
  --clkout1_name c0 --clkout1 $pixel \
  --clkout2_name c2 --clkout2 .048 \
  -f verilog/hdmi_pll.v

