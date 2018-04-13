// ====================================================================
//                          VECTOR-06C FPGA REPLICA
//
//                Copyright (C) 2007, 2008 Viacheslav Slavinsky
//
// This core is distributed under modified BSD license. 
// For complete licensing information see LICENSE.TXT.
// -------------------------------------------------------------------- 
//
// An open implementation of Vector-06C home computer
//
// Author: Viacheslav Slavinsky, http://sensi.org/~svo
// 
// Design File: scan2matrix.v
//
// Convert PS/2 scancodes into Vector-06C keyboard matrix coordinates.
//
// --------------------------------------------------------------------

module scan2matrix(
	input				clk,
	input		[7:0]	scancode,
	input				jcuken_mode,
	output	reg	[2:0]	qrow,
	output	reg	[2:0]	qcol,
	output  reg			qerror
);

wire[6:0] jcuken_q;
jcuken jcuken_inst(scancode, jcuken_q);

wire[6:0] qwerty_q;
qwerty qwerty_inst(scancode, qwerty_q);

wire[6:0] common_q;
common common_inst(scancode, common_q);


always @(posedge clk)
	if (~&common_q)
		begin
			qrow	<= 	common_q[5:3];
			qcol	<= 	common_q[2:0];
			qerror	<=	&common_q;
		end
	else
		if (jcuken_mode)
			begin
				qrow	<= 	jcuken_q[5:3];
				qcol	<= 	jcuken_q[2:0];
				qerror	<=	&jcuken_q;
			end
		else
			begin
				qrow	<= 	qwerty_q[5:3];
				qcol	<= 	qwerty_q[2:0];
				qerror	<=	&qwerty_q;
			end
endmodule

module common(
	input		[7:0]	addr, 
	output	reg	[6:0]	q
);

always @*
	case (addr)
		default:	q <= 	{7'b1111111};
		8'h0D:		q <= 	{4'h0, 3'h0};
		8'h1F:		q <= 	{4'h0, 3'h1};
		8'h27:		q <= 	{4'h0, 3'h1};
		8'h5A:		q <= 	{4'h0, 3'h2};
		8'h66:		q <= 	{4'h0, 3'h3};
		8'h6B:		q <= 	{4'h0, 3'h4};
		8'h71:		q <= 	{4'h0, 3'h4};
		8'h75:		q <= 	{4'h0, 3'h5};
		8'h6C:		q <= 	{4'h0, 3'h5};
		8'h74:		q <= 	{4'h0, 3'h6};
		8'h7A:		q <= 	{4'h0, 3'h6};
		8'h72:		q <= 	{4'h0, 3'h7};
		8'h69:		q <= 	{4'h0, 3'h7};
		8'h70:		q <= 	{4'h1, 3'h0};
		8'h7D:		q <= 	{4'h1, 3'h1};
		8'h76:		q <= 	{4'h1, 3'h2};
		8'h05:		q <= 	{4'h1, 3'h3};
		8'h06:		q <= 	{4'h1, 3'h4};
		8'h04:		q <= 	{4'h1, 3'h5};
		8'h0C:		q <= 	{4'h1, 3'h6};
		8'h03:		q <= 	{4'h1, 3'h7};
		8'h45:		q <= 	{4'h2, 3'h0};
		8'h16:		q <= 	{4'h2, 3'h1};
		8'h1E:		q <= 	{4'h2, 3'h2};
		8'h26:		q <= 	{4'h2, 3'h3};
		8'h25:		q <= 	{4'h2, 3'h4};
		8'h2E:		q <= 	{4'h2, 3'h5};
		8'h36:		q <= 	{4'h2, 3'h6};
		8'h3D:		q <= 	{4'h2, 3'h7};
		8'h3E:		q <= 	{4'h3, 3'h0};
		8'h46:		q <= 	{4'h3, 3'h1};
		8'h0E:		q <= 	{4'h3, 3'h3};
		8'h4E:		q <= 	{4'h3, 3'h5};
		8'h55:		q <= 	{4'h3, 3'h7};
		8'h52:		q <= 	{4'h7, 3'h4};
		8'h29:		q <= 	{4'h7, 3'h7};
	endcase
endmodule


module jcuken(
	input		[7:0]	addr, 
	output	reg	[6:0]	q
);

always @*
	case (addr)
		default:	q <= 	{7'b1111111};
		8'h5B:		q <= 	{4'h3, 3'h2};
		8'h4A:		q <= 	{4'h3, 3'h4};
		8'h5D:		q <= 	{4'h3, 3'h6};
		8'h49:		q <= 	{4'h4, 3'h0};
		8'h2B:		q <= 	{4'h4, 3'h1};
		8'h41:		q <= 	{4'h4, 3'h2};
		8'h1D:		q <= 	{4'h4, 3'h3};
		8'h4B:		q <= 	{4'h4, 3'h4};
		8'h2C:		q <= 	{4'h4, 3'h5};
		8'h1C:		q <= 	{4'h4, 3'h6};
		8'h3C:		q <= 	{4'h4, 3'h7};
		8'h54:		q <= 	{4'h5, 3'h0};
		8'h32:		q <= 	{4'h5, 3'h1};
		8'h15:		q <= 	{4'h5, 3'h2};
		8'h2D:		q <= 	{4'h5, 3'h3};
		8'h42:		q <= 	{4'h5, 3'h4};
		8'h2A:		q <= 	{4'h5, 3'h5};
		8'h35:		q <= 	{4'h5, 3'h6};
		8'h3B:		q <= 	{4'h5, 3'h7};
		8'h34:		q <= 	{4'h6, 3'h0};
		8'h1A:		q <= 	{4'h6, 3'h1};
		8'h33:		q <= 	{4'h6, 3'h2};
		8'h21:		q <= 	{4'h6, 3'h3};
		8'h31:		q <= 	{4'h6, 3'h4};
		8'h24:		q <= 	{4'h6, 3'h5};
		8'h4C:		q <= 	{4'h6, 3'h6};
		8'h23:		q <= 	{4'h6, 3'h7};
		8'h3A:		q <= 	{4'h7, 3'h0};
		8'h1B:		q <= 	{4'h7, 3'h1};
		8'h4D:		q <= 	{4'h7, 3'h2};
		8'h43:		q <= 	{4'h7, 3'h3};
		8'h44:		q <= 	{4'h7, 3'h5};
		8'h22:		q <= 	{4'h7, 3'h6};
	endcase
endmodule


module qwerty(
	input		[7:0]	addr, 
	output	reg	[6:0]	q
);

always @*
	case (addr)
		default:	q <= 	{7'b1111111};
		8'h4C:		q <= 	{4'h3, 3'h2};
		8'h41:		q <= 	{4'h3, 3'h4};
		8'h49:		q <= 	{4'h3, 3'h6};
		8'h5D:		q <= 	{4'h4, 3'h0};
		8'h1C:		q <= 	{4'h4, 3'h1};
		8'h32:		q <= 	{4'h4, 3'h2};
		8'h21:		q <= 	{4'h4, 3'h3};
		8'h23:		q <= 	{4'h4, 3'h4};
		8'h24:		q <= 	{4'h4, 3'h5};
		8'h2B:		q <= 	{4'h4, 3'h6};
		8'h34:		q <= 	{4'h4, 3'h7};
		8'h33:		q <= 	{4'h5, 3'h0};
		8'h43:		q <= 	{4'h5, 3'h1};
		8'h3B:		q <= 	{4'h5, 3'h2};
		8'h42:		q <= 	{4'h5, 3'h3};
		8'h4B:		q <= 	{4'h5, 3'h4};
		8'h3A:		q <= 	{4'h5, 3'h5};
		8'h31:		q <= 	{4'h5, 3'h6};
		8'h44:		q <= 	{4'h5, 3'h7};
		8'h4D:		q <= 	{4'h6, 3'h0};
		8'h15:		q <= 	{4'h6, 3'h1};
		8'h2D:		q <= 	{4'h6, 3'h2};
		8'h1B:		q <= 	{4'h6, 3'h3};
		8'h2C:		q <= 	{4'h6, 3'h4};
		8'h3C:		q <= 	{4'h6, 3'h5};
		8'h2A:		q <= 	{4'h6, 3'h6};
		8'h1D:		q <= 	{4'h6, 3'h7};
		8'h22:		q <= 	{4'h7, 3'h0};
		8'h35:		q <= 	{4'h7, 3'h1};
		8'h1A:		q <= 	{4'h7, 3'h2};
		8'h54:		q <= 	{4'h7, 3'h3};
		8'h5B:		q <= 	{4'h7, 3'h5};
		8'h4A:		q <= 	{4'h7, 3'h6};
	endcase
endmodule