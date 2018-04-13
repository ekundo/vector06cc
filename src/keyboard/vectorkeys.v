// ====================================================================
//                         VECTOR-06C FPGA REPLICA
//
//               Copyright (C) 2007,2008 Viacheslav Slavinsky
//
// This core is distributed under modified BSD license. 
// For complete licensing information see LICENSE.TXT.
// -------------------------------------------------------------------- 
//
// An open implementation of Vector-06C home computer
//
// Author: Viacheslav Slavinsky, http://sensi.org/~svo
// 
// Design File: vectorkeys.v
//
// Keyboard interface. This module maps PS/2 keyboard keypresses
// and releases into a keyboard matrix model used in Vector-06C.
// 
// Can be optimized space-wise by reducing the giant rowbits
// expression into a sequential process. 
//
// See http://www.quadibloc.com/comp/scan.htm
// for information about why shift key is being de-pressed and pressed 
// when grey arrows are pressed
//
// --------------------------------------------------------------------



`default_nettype none
module vectorkeys(
	input				clk,
	input				reset,
	inout				ps2_clk,
	inout				ps2_dat,
	input	[7:0]		rowselect,		// PA output inverted
	input				osd_active,
	output	reg[7:0]	rowbits,		// PB input  inverted
	output	reg			key_shift,
	output	reg			key_ctrl,
	output	reg			key_rus,
	output	reg			key_blksbr,
	output	reg			key_blkvvod,
	output	reg			key_bushold,
	output	reg[5:0]	key_osd
);


reg				ps2wren;
reg		[7:0]	ps2d;
wire			ps2write;

ps2tx ps2tx_inst(
	.clk(clk),
	.reset(reset),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_dat),
	.wren(ps2wren),
	.d(ps2d),
	.write(ps2write)
);


reg				ps2rden;
wire			ps2dsr;
wire	[7:0]	ps2q;

ps2rx ps2rx_inst(
	.clk(clk),
	.reset(reset),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_dat),
	.samplen(!ps2write),
	.rden(ps2rden),
	.q(ps2q),
	.dsr(ps2dsr),
	.overflow()
);


reg				key_jcuken;
wire	[2:0]	matrix_row;
wire	[2:0]	matrix_col;
wire			neo_raw;			// not in matrix
wire			neo = osd_active | neo_raw;
wire	[7:0]	decoded_col;

scan2matrix scan2matrix_inst(
			.clk(clk), 
			.scancode(ps2q), 
			.jcuken_mode(key_jcuken),
			.qrow(matrix_row), 
			.qcol(matrix_col),
			.qerror(neo_raw)
);

keycolumndecoder column_dc1(matrix_col,decoded_col);

reg [4:0] state = 0;
reg [7:0] keymatrix[0:7];

always @(posedge clk) begin
	if (reset) begin
		keymatrix[0] <= 0;
		keymatrix[1] <= 0;
		keymatrix[2] <= 0;
		keymatrix[3] <= 0;
		keymatrix[4] <= 0;
		keymatrix[5] <= 0;
		keymatrix[6] <= 0;
		keymatrix[7] <= 0;
		key_shift <= 0;
		key_ctrl  <= 0;
		key_rus	  <= 0;
		key_blksbr <= 0;
		key_blkvvod <= 0;
		key_bushold <= 0;
		key_osd <= 0;
		key_jcuken <= 0;
		state <= 0;
		ps2rden <= 0;
	end 
	else
		case (state)
			0:	state <= 18;

			1:	state <= 2;

			2:	if (ps2dsr)
					begin
						ps2rden <= 1;
						state <= 3;
					end

			3:	begin
					ps2rden <= 0;
					state <= 4;
				end

			4:	case(ps2q)
					8'hE0:		state	<=	10;
					8'hF0:		state	<=	6;
					default:	state	<=	5;
				endcase
				
			5:	begin
					case(ps2q)
						8'h12:		key_shift	<=	1;
						8'h59:		key_shift	<=	1;
						8'h14:		key_ctrl	<=	1;
						8'h58:		key_rus		<=	1;
						8'h78:		key_blkvvod	<=	1;
						8'h07:		key_blksbr	<=	1;
						8'h7E:		key_bushold	<=	1;
						8'h11:		key_jcuken	<=	0;
						default:	begin
										case (ps2q) 
											8'h75:	key_osd[2]	<=	osd_active;
											8'h72:	key_osd[1]	<=	osd_active;
											8'h6b:	key_osd[4]	<=	osd_active;
											8'h74:	key_osd[3]	<=	osd_active;
											8'h5a:	key_osd[0]	<=	osd_active;
										endcase
										
										if (!neo)
											keymatrix[matrix_row] <= keymatrix[matrix_row] | decoded_col;
									end
					endcase
					state <= 1;
				end
				
			6:	if (ps2dsr)
					begin
						ps2rden <= 1;
						state <= 7;
					end
				
			7:	begin
					ps2rden <= 0;
					state <= 8;
				end
				
			8:	state <= 9;
			
			9:	begin
					case(ps2q)
						8'h12:		key_shift	<= 0;
						8'h59:		key_shift	<= 0;
						8'h14:		key_ctrl	<= 0;
						8'h58:		key_rus		<= 0;
						8'h78:		key_blkvvod	<= 0;
						8'h07:		key_blksbr	<= 0;
						8'h7E:		key_bushold	<= 0;
						default:	begin
										case (ps2q) 
											8'h75:	key_osd[2]	<=	0;
											8'h72:	key_osd[1]	<=	0;
											8'h6b:	key_osd[4]	<=	0;
											8'h74:	key_osd[3]	<=	0;
											8'h5a:	key_osd[0]	<=	0;
										endcase
									
										if (!neo)
											keymatrix[matrix_row] <=  keymatrix[matrix_row] & ~decoded_col;
									end
					endcase
					state <= 1;
				end

			10:	if (ps2dsr)
					begin
						ps2rden <= 1;
						state <= 11;
					end

			11:	begin
					ps2rden <= 0;
					state <= 12;
				end

			12:	state <= ps2q == 8'hF0 ? 14 : 13;
				
			13:	begin
					case(ps2q)
						8'h14:		key_ctrl	<=	1;
						8'h11:		key_jcuken	<=	1;
						default:	begin
										case (ps2q) 
											8'h75:	key_osd[2]	<=	osd_active;
											8'h72:	key_osd[1]	<=	osd_active;
											8'h6b:	key_osd[4]	<=	osd_active;
											8'h74:	key_osd[3]	<=	osd_active;
											8'h5a:	key_osd[0]	<=	osd_active;
										endcase
										
										if (!neo)
											keymatrix[matrix_row] <= keymatrix[matrix_row] | decoded_col;
									end
					endcase
					state <= 1;
				end

			14:	if (ps2dsr)
					begin
						ps2rden <= 1;
						state <= 15;
					end
				
			15:	begin
					ps2rden <= 0;
					state <= 16;
				end
				
			16:	state <= 17;
			
			17:	begin
					case(ps2q)
						8'h14:		key_ctrl	<= 0;
						default:	begin
										case (ps2q) 
											8'h75:	key_osd[2]	<=	0;
											8'h72:	key_osd[1]	<=	0;
											8'h6b:	key_osd[4]	<=	0;
											8'h74:	key_osd[3]	<=	0;
											8'h5a:	key_osd[0]	<=	0;
										endcase
									
										if (!neo)
											keymatrix[matrix_row] <=  keymatrix[matrix_row] & ~decoded_col;
									end
					endcase
					state <= 1;
				end
			
			18: begin
					ps2d	<=	8'hAD;
					ps2wren	<=	1'b1;
					state	<=	19;
				end

			19: begin
					ps2d	<=	8'bZ;
					ps2wren	<=	1'b0;
					state	<=	20;
				end

			20: if (!ps2write)
					state	<=	1;
		endcase
end

always @(posedge clk)
	rowbits <= 
		(rowselect[0] ? keymatrix[0] : 8'h0) |
		(rowselect[1] ? keymatrix[1] : 8'h0) |
		(rowselect[2] ? keymatrix[2] : 8'h0) | 
		(rowselect[3] ? keymatrix[3] : 8'h0) |
		(rowselect[4] ? keymatrix[4] : 8'h0) |
		(rowselect[5] ? keymatrix[5] : 8'h0) |
		(rowselect[6] ? keymatrix[6] : 8'h0) |
		(rowselect[7] ? keymatrix[7] : 8'h0);

endmodule


module keycolumndecoder(
	input		[2:0]	d,
	output	reg	[7:0]	q
);

always @*
	case (d)
		3'b000:	q <= 8'b00000001;
		3'b001: q <= 8'b00000010;
		3'b010: q <= 8'b00000100;
		3'b011: q <= 8'b00001000;
		3'b100: q <= 8'b00010000;
		3'b101: q <= 8'b00100000;
		3'b110: q <= 8'b01000000;
		3'b111: q <= 8'b10000000;
	endcase

endmodule