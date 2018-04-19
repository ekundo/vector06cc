module ps2rx(
	input				clk,
	input				reset,
	input				ps2_clk,
	input				ps2_data,
	input				samplen,
	input				rden,
	output	reg	[7:0]	q,
	output	reg			dsr,
	output				overflow);

reg [7:0] qreg;

reg [1:0] state = 2'b00;


reg	[7:0]	ps2_clk_filter;
wire		ps2_clk_filtered;

always @(posedge clk)
	if (reset)
		ps2_clk_filter	<=	8'b0;
	else
		ps2_clk_filter	<=	{ps2_clk_filter[6:0], ps2_clk};

assign ps2_clk_filtered = 
			(ps2_clk_filter == 8'b11111111) ? 1'b1 :
			(ps2_clk_filter == 8'b00000000) ? 1'b0 :
			ps2_clk_filtered;


reg [4:0] sampledelay;
reg [1:0] samplebuf;
reg sample_ce;
always @(posedge clk) begin
	if (samplen)
		begin
			samplebuf <= {samplebuf[0], ps2_clk_filtered};
			sample_ce <= samplebuf[1] & ~samplebuf[0];
		end
end

reg [9:0] shiftreg;
reg [3:0] bitcount = 4'b0;

always @(posedge clk) begin
	if (reset)
		begin
			bitcount <= 4'b0;
			q <= 8'b0;
			state <= 2'b00;
			dsr <= 1'b0;
		end
	else
		begin
			case (state)
				2'b00:
					begin
						if (sample_ce) begin
							if (~ps2_data) begin
								bitcount <= 9;
								state <= 2'b01;
							end
							else state <= 2'b11;
						end
					end
				2'b01:
					begin
						if (sample_ce) begin
							shiftreg <= {ps2_data, shiftreg[9:1]};
							bitcount <= bitcount - 1'b1;
							if (bitcount == 0) state <= 2'b10;
						end 
					end
				2'b10:
					begin
						if (shiftreg[9] && (^shiftreg[8:0])==1'b1)
							qreg <= shiftreg[7:0];
						else
							qreg <= 8'hFF;
						dsr <= 1'b1;
						state <= 2'b00;
					end
				2'b11:
					begin
						state <= 2'b00;
					end
			endcase
			
			if (dsr & rden) begin
				q <= qreg;
				dsr <= 1'b0;
			end
		end
end

endmodule