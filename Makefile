PROJ=hdmi-orangecrab
VFLAGS= -Wall -g2005
BIN=$(HOME)/Projects/hw/synlig/out/current/bin/
YOSYS=$(BIN)yosys
SRCS = $(wildcard verilog/*.sv) $(wildcard verilog/*.v)

all: ${PROJ}.json

bit: $(PROJ).bit

dfu: ${PROJ}.dfu
	dfu-util -a0 -D $<

%.json: $(SRCS)
	$(YOSYS) -p "plugin -i systemverilog" -p "read_systemverilog $(SRCS); synth_ecp5 -json $@"

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --25k --package CSFBGA285 --lpf orangecrab_r0.2.pcf

%.bit: %_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

%.dfu : %.bit
	cp $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

.PHONY: sim clean

sim:
	iverilog -g2012 -s top -I verilog -o $(PROJ).idunno $(SRCS)

clean:
	rm -rf *.vcd a.out *.svf *.bit *.config *.json *.dfu 
