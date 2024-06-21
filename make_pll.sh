#!/bin/bash

ecppll -n hdmi_pll --clkin_name inclk0 -i48 --clkout0_name c0 -o 25.2 --clkout1_name c1 --clkout1 126 --clkout2_name c2 --clkout2 .048 -f verilog/hdmi_pll.v

