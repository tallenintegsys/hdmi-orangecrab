`timescale 1 ps / 1 ps

// FPGA-TN-02200-1-3-ECP5-and-ECP5-5G-sysCLOCK-PLL-DLL-Design-and-User-Guide%20(2).pdf

module hdmi_pll (
	input inclk0,
	output c0,
	output c1,
	output c2);

/*
	ECP5_PLL
	#( .IN_MHZ(25)
	, .OUT0_MHZ(74.176)
	, .OUT1_MHZ(370.88)
	, .OUT3_MHZ(0.048)
	) pll
	( .clkin(inclk)
	, .reset(1'b0)
	, .standby(1'b0)
	, .locked()
	, .clkout0(c0)
	, .clkout1(c1)
	, .clkout3(c3)
	);
*/
	EHXPLLL #(
    .CLKI_DIV(1),
    .CLKFB_DIV(1),
    .CLKOP_DIV(8),
    .CLKOS_DIV(8),
    .CLKOS2_DIV(8),
    .CLKOS3_DIV(8),
    .CLKOP_ENABLE("ENABLED"),
    .CLKOS_ENABLE("DISABLED"),
    .CLKOS2_ENABLE("ENABLED"),
    .CLKOS3_ENABLE("ENABLED"),
    .CLKOP_CPHASE(0),
    .CLKOS_CPHASE(0),
    .CLKOS2_CPHASE(0),
    .CLKOS3_CPHASE(0),
    .CLKOP_FPHASE(0),
    .CLKOS_FPHASE(0),
    .CLKOS2_FPHASE(0),
    .CLKOS3_FPHASE(0),
    .FEEDBK_PATH("CLKOP"),
    .CLKOP_TRIM_POL("RISING"),
    .CLKOP_TRIM_DELAY(0),
    .CLKOS_TRIM_POL("RISING"),
    .CLKOS_TRIM_DELAY(0),
    .OUTDIVIDER_MUXA("DIVA"),
    .OUTDIVIDER_MUXB("DIVB"),
    .OUTDIVIDER_MUXC("DIVC"),
    .OUTDIVIDER_MUXD("DIVD"),
    .PLL_LOCK_MODE(0),				// 0 = unsticky?
    .PLL_LOCK_DELAY(200),
    .STDBY_ENABLE("DISABLED"),		// enable the STDBY port below
    .REFIN_RESET("DISABLED"),
    .SYNC_ENABLE("DISABLED"),
    .INT_LOCK_STICKY("ENABLED"),
    .DPHASE_SOURCE("DISABLED"),
    .PLLRST_ENA("DISABLED"),
    .INTFB_WAKE("DISABLED")
	) pll (
    .CLKI(inclk),	 	// I Input Clock to PLL
   	.CLKFB(), 	 	    // I Feedback Clock
    .PHASESEL1(),	 	// I Select the output affected by Dynamic Phase adjustment.
	.PHASESEL0(),		// I Select the output affected by Dynamic Phase adjustment.
	.PHASEDIR(), 	    // I Dynamic Phase adjustment direction. 0=Delayed (lagging), 1=Advanced (leading)
	.PHASESTEP(),		// I Dynamic Phase adjustment step.
	.PHASELOADREG(),    // I Load dynamic phase adjustment values into PLL.
    .STDBY(0),			// I Standby signal to power down the PLL.
	.PLLWAKESYNC(),		// I Enable PLL switching from internal feedback to user feedback path when PLL wake up.
    .RST(0),			// I Resets the whole PLL.
    .ENCLKOP(1),		// I Enable PLL output CLKOP
    .ENCLKOS(1),		// I Enable PLL output CLKOS
	.ENCLKOS2(1),		// I Enable PLL output CLKOS2
	.ENCLKOS3(1),		// I Enable PLL output CLKOS3
    .CLKOP(c0), 		// O PLL main output clock.
    .CLKOS(),			// O PLL output clock.
	.CLKOS2(c1),        // O PLL output clock.
	.CLKOS3(c2),        // O PLL output clock.
    .LOCK(),            // O PLL LOCK to CLKI, Asynchronous signal. Active high indicates PLL lock.
	.INTLOCK(),			// O Internal Lock Signal.
    .REFCLK(),			// O Output of Reference clock mux.
	.CLKINTFB());		// O Internal Feedback Clock.

endmodule
