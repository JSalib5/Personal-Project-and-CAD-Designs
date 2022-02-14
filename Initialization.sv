module initialization (inclock, pll_areset, rx_reset, rx_locked, rx_dpa_locked, rx_fifo_reset, rx_cda_reset);
	input inclock;											//reference PLL clock in IVDS IP core
	output reg rx_locked, rx_dpa_locked, pll_areset, rx_reset, rx_fifo_reset, rx_cda_reset; //outputing the reset and lock values to the FPGA 
	
	initial@(posedge inclock) begin
		pll_areset = 1'b1;
		rx_reset = 1'b1;									//asserting rx_reset and pll_areset
	#1	pll_areset = 1'b0;								//de-asserting pll_areset					
		wait(rx_locked == 1'b1);						//monitoring rx_locked waiting until it is asserted
	end
	assert property(CheckStable);						//checking if rx_locked is stable for 20ns to continue
	initial@(posedge inclock) begin
		rx_reset = 1'b0;									//de-asserting rx_reset
		wait(rx_dpa_locked == 1'b1); 					//waiting for rx_dpa_locked to assert
		rx_fifo_reset = 1'b1; 							//asserting rx_fifo_reset	
	#1 rx_fifo_reset = 1'b0; 							//de-asserting rx_fifo_reset after 1 clock cycle
	#1 rx_cda_reset = 1'b1;								//asserting rx_cda_reset
	#1 rx_cda_reset = 1'b0;								//de-asserting rx_cda_reset after 1 clock cycle
	end
	
	property CheckStable; 								//property defining stability criteria for rx_locked
		@(posedge inclock) $stable(rx_locked)[*20];
	endproperty
endmodule 