module tpnco (clock, resetb, step,	mod, mask, ticks, sine_out1, sine_out2);

parameter W_ACCUM = 24; 						// Width of the Accumulator
parameter W_TICK  = 8;  						// Width of the Tick counter.
parameter W_STEP  = 24;							// steps number width
parameter W_MOD   = 24;							// modulo width

input	clock, resetb;     						//clock and reset
input [W_STEP-1:0] step; 						// Step input is continuously added to the modulo counter
input [W_MOD-1:0]	mod;   						// modulo
input [W_TICK-1:0]	mask;						// Mask is ANDed with ticks to produce sine_outs
output [W_TICK-1:0]	ticks;					// Tick counter output
output sine_out1, sine_out2;					// Outputs

reg [W_ACCUM-1:0]	accum, accum_in;
reg [W_TICK-1:0]	ticks;

reg		wrap;

wire [W_ACCUM-1:0]	sum = accum + step; 	//defining sum as accumulation + next step size
wire [W_ACCUM-1:0]	rem = sum - mod;    	//remainder is the sum - modulo
wire			over = (sum >= mod);

always @(posedge clock or negedge resetb) //asynchronous active low reset
   if (~resetb) accum <= 0;					//if reseting then reset the accumulator 
   else         accum <= accum_in;			//otherwise update accumulator
   
always @(over or rem or sum) begin
   if (over) begin
      accum_in <= rem; 							//if wrapping load remainder instead of sum
      wrap <= 1;
   end
   else begin
      accum_in <= sum;							//else add sum
      wrap <= 0;
   end
end

always @(posedge clock) begin
   if (~resetb) ticks <= 0;					//reset tick counter if reset active
   else begin
      if (wrap) 
         ticks <= ticks + 2;					// Whenever Modulo counter wraps, increment the tick counter.
   end
end

assign sine_out1 = |(ticks & mask);
assign sine_out2 = |((ticks+1) & mask);

endmodule

/*
This NCO design is based on the concept of a wrapping modulo counter, where the modulo would then determine 
the amplitude of the wave. This concept of NCO allows for an efficient implementation that does not necessitate 
much space and does not requre a sine look up table like over traditional NCO implementations that can be very 
tedious to implement or require an external hex file to find sine function values from. The ticks incrament in 
twos to allow for 2 parallel sample outputs per clock input rather than one. The step function determines the rate
of wrapping. The number of wraps is given as (clock frequency)*(Step Input)/(modulo). These wrap incraments determine
the ticks that are the out bits of the function. 

A trade off with this design is the need for a Mask input, this 8 bit input should contain only one 1 bit and the remaining
zeros as a way to use different bits of the ticks output to have different sinewave outputs. Although, this is a more 
intuitive implementation of a numerically controlled oscillator there are even more efficient ways of taking digital inputs
and resulting in wave functions.
*/