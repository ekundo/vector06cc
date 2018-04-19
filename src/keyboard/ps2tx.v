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


reg		[1:0]	ps2_data_ss;
wire			ps2_data_s;

always @(posedge clk)
	if (reset)
		ps2_data_ss	<=	2'b0;
	else
		ps2_data_ss	<=	{ps2_data_ss[0:0], ps2_data};

assign	ps2_data_s = ps2_data_ss[1:1];


reg	[3:0]	state;
reg	[11:0]	delay;
reg	[11:0]	clock_delay;
reg [8:0]	shiftreg;
reg [3:0]	bitcount;

always @(posedge clk)
	if (reset) 
		begin
			state		<=	4'b0000;
			ps2_clkr	<=	1'bZ;
			ps2_datar	<=	1'bZ;
			clock_delay	<=	12'd0;
			bitcount	<=	4'd0;
			shiftreg	<=	8'b0;
		end
	else 
		case(state)
			4'b0000:
				if (wren)
					begin
						state		<=	4'b0001;
						bitcount	<=	4'd0;
						shiftreg	<=	{~^d, d};
						clock_delay	<=	12'd2500;
						delay		<=	12'd2500;
					end
			4'b0001:
				if	(delay > 12'd0)
					delay			<=	delay - 12'd1;
				else
					state			<=	4'b0010;
			4'b0010:
				begin
					ps2_clkr		<=	1'b0;
					state			<=	4'b0011;
				end
			4'b0011:
				if	(clock_delay > 12'd0)
					clock_delay		<=	clock_delay - 12'd1;
				else
					state			<=	4'b0100;
			4'b0100:
				begin
					ps2_datar		<=	1'b0;
					ps2_clkr		<=	1'bZ;
					state			<=	4'b0101;
				end
			4'b0101:
				if (ps2_clk_filtered == 1'b1 && ps2_data_s == 1'b0)
					state			<=	4'b0110;
			4'b0110:
				if (ps2_clk_filtered == 1'b0)
					state			<=	4'b0111;
			4'b0111:
				begin
					ps2_datar		<=	shiftreg[0];
					state			<= 4'b1000;
				end
			4'b1000:
				if (ps2_clk_filtered == 1'b1)
					state			<=	4'b1001;
			4'b1001:
				if (ps2_clk_filtered == 1'b0)
					state			<=	4'b1010;
			4'b1010:
				if (bitcount < 4'd8)
					begin
						bitcount	<=	bitcount + 4'd1;
						shiftreg	<=	{1'b0, shiftreg[8:1]};
						state		<=	4'b0111;
					end
				else
					state			<=	4'b1011;
			4'b1011:
				begin
					ps2_datar		<=	1'bZ;
					state			<=	4'b1100;
				end
			4'b1100:
				if (ps2_data_s == 1'b0)
					state			<=	4'b1101;
			4'b1101:
				if (ps2_clk_filtered == 1'b0)
					state			<=	4'b1110;
			4'b1110:
				if (ps2_data_s == 1'b1 && ps2_clk_filtered == 1'b1)
					state			<=	4'b0000;
		endcase

assign write = state != 4'b0000;

endmodule