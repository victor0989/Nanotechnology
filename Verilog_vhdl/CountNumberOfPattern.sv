module CountNumberOfPattern #(
parameter DATA_WIDTH = 32, 
parameter PATTERN_WIDTH = 3,
parameter DATA_OUT_WIDTH = $clog2(DATA_WIDTH)
)( 
input 	logic 	[DATA_WIDTH-1:0]		In,
input 	logic 	[PATTERN_WIDTH-1:0]		Pattern,
output	logic 	[DATA_OUT_WIDTH-1:0] 		CountOut
); 

integer i_count; 

always @(In) begin 
	CountOut = 0; 
	for (i_count = (DATA_WIDTH-1); i_count > (PATTERN_WIDTH-2); i_count--)
		if ( Pattern == In[i_count-:PATTERN_WIDTH] )
			CountOut = CountOut + 1; 
end 

endmodule 
