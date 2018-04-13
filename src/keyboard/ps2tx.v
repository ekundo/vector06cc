`default_nettype none

module ps2tx(
	input			clk,
	input			reset,
	inout			ps2_clk,
	inout			ps2_data,
	input			wren,
	input	[7:0]	d,
	output			write
);

reg			ps2_clkr;
reg			ps2_datar;

assign	ps2_clk = ps2_clkr;
assign	ps2_data = ps2_datar;


reg	[3:0]	state;
reg	[11:0]	clock_delay;
reg [8:0]	shiftreg;
reg [3:0]	bitcount;

always @(posedge clk)
	if (reset) 
		begin
			state		<=	4'd0;
			ps2_clkr	<=	1'bZ;
			ps2_datar	<=	1'bZ;
			clock_delay	<=	12'd0;
			bitcount	<=	4'd0;
			shiftreg	<=	8'b0;
		end
	else 
		begin
			case(state)
				4'd0:
					if (wren)
						begin
							state		<=	4'd1;
							bitcount	<=	4'd0;
							shiftreg	<=	{^d, d};
						end
				4'd1:
					begin
						clock_delay		<=	12'd2500;
						ps2_clkr		<=	1'b0;
						state			<=	4'd2;
					end
				4'd2:
					if	(clock_delay > 12'd0)
						clock_delay		<=	clock_delay - 12'd1;
					else
						state			<=	4'd3;
				4'd3:
					begin
						ps2_datar		<=	1'b0;
						ps2_clkr		<=	1'bZ;
						state			<=	4'd4;
					end
				4'd4:
					if (ps2_clk == 1'b0)
						state			<=	4'd5;
				4'd5:
					begin
						ps2_datar		<=	shiftreg[0];
						state			<= 4'd6;
					end
				4'd6:
					if (ps2_clk == 1'b1)
						state			<=	4'd7;
				4'd7:
					if (ps2_clk == 1'b0)
						state			<=	4'd8;
				4'd8:
					if (bitcount < 4'd8)
						begin
							bitcount	<=	bitcount + 4'd1;
							shiftreg	<=	{1'b0, shiftreg[8:1]};
							state		<=	4'd5;
						end
					else
						state			<=	4'd9;
				4'd9:
					begin
						ps2_datar		<=	1'bZ;
						state			<=	4'd10;
					end
				4'd10:
					if (ps2_data == 1'b0)
						state			<=	4'd11;
				4'd11:
					if (ps2_clk == 1'b0)
						state			<=	4'd12;
				4'd12:
					if (ps2_data == 1'b1 && ps2_clk == 1'b1)
						state			<=	4'd0;
			endcase
		end

assign write = state != 4'd0;

endmodule