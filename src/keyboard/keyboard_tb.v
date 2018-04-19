`timescale 1ns / 1ps
module keyboard_tb();

reg reset, clk, ps2_clkr, ps2_datar, rd_en, led_rus;
reg [7:0] rowselect;
wire dsr, key_ctrl, key_shift, key_rus, key_blkvvod, key_blksbr, key_bushold, ps2_clk, ps2_data;
wire [7:0] rowbits;

task scan;
    input[7:0] code;
    begin
        repeat (1000) @(posedge clk);
        ps2_datar    <= 0;               //start
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[0:0];
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[1:1];
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[2:2];
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[3:3];
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[4:4];
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[5:5];
        repeat (50) @(posedge clk);
        ps2_clkr	    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[6:6];
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= code[7:7];
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= ~^code[7:0];     //parity
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1;
        ps2_datar   <= 1;               //stop
        repeat (50) @(posedge clk);
        ps2_clkr    <= 0;
        repeat (50) @(posedge clk);
        ps2_clkr    <= 1'bZ;
        ps2_datar   <= 1'bZ;
    end
endtask

task check_empty;
    begin
        check_scan(4'd8, 4'd8);
        check_ctrl(1'b0);
        check_rus(1'b0);
        check_blkvvod(1'b0);
        check_blksbr(1'b0);
        check_shift(1'b0);
        check_osd(1'b0);
    end
endtask

task check_scan;
    input[3:0] row;
    input[3:0] col;

    reg [3:0] i;
    for( i = 0; i <= 7; i++ ) 
    begin
        rowselect <= 8'b1 << i;
        repeat (2) @(posedge clk);
        if (rowbits !== (i === row ? 8'b1 << col : 8'b0))
            begin
                $display("ASSERTION FAILURE: unexpected rowbits %b in row %d %b", rowbits, i, (8'b1 << col));
                $finish;
            end
    end
endtask

task check_ctrl;
    input state;

    if (key_ctrl !== state)
        begin
            $display("ASSERTION FAILURE: unexpected key_ctrl %b", key_ctrl);
            $finish;
        end
endtask

task check_ctrl_key;
    input[7:0] code;

    begin
        check_empty();
        scan(code);
        check_ctrl(1'b1);
        scan(8'hF0);
        check_ctrl(1'b1);
        scan(code);
        check_empty();
    end
endtask

task check_ctrl_ekey;
    input[7:0] code1;
    input[7:0] code2;

    begin
        check_empty();
        scan(code1);
        check_empty();
        scan(code2);
        check_ctrl(1'b1);
        scan(code1);
        check_ctrl(1'b1);
        scan(8'hF0);
        check_ctrl(1'b1);
        scan(code2);
        check_empty();
    end
endtask

task check_shift;
    input state;

    if (key_shift !== state)
        begin
            $display("ASSERTION FAILURE: unexpected key_shift %b", key_shift);
            $finish;
        end
endtask

task check_shift_key;
    input[7:0] code;

    begin
        check_empty();
        scan(code);
        check_shift(1'b1);
        scan(8'hF0);
        check_shift(1'b1);
        scan(code);
        check_empty();
    end
endtask


task check_rus;
    input state;

    if (key_rus !== state)
        begin
            $display("ASSERTION FAILURE: unexpected key_rus %b", key_rus);
            $finish;
        end
endtask

task check_rus_key;
    input[7:0] code;

    begin
        check_empty();
        scan(code);
        check_rus(1'b1);
        scan(8'hF0);
        check_rus(1'b1);
        scan(code);
        check_empty();
    end
endtask

task check_blkvvod;
    input state;

    if (key_blkvvod !== state)
        begin
            $display("ASSERTION FAILURE: unexpected key_blkvvod %b", key_blkvvod);
            $finish;
        end
endtask

task check_blkvvod_key;
    input[7:0] code;

    begin
        check_empty();
        scan(code);
        check_blkvvod(1'b1);
        scan(8'hF0);
        check_blkvvod(1'b1);
        scan(code);
        check_empty();
    end
endtask

task check_blksbr;
    input state;

    if (key_blksbr !== state)
        begin
            $display("ASSERTION FAILURE: unexpected key_blksbr %b", key_blksbr);
            $finish;
        end
endtask

task check_blksbr_key;
    input[7:0] code;

    begin
        check_empty();
        scan(code);
        check_blksbr(1'b1);
        scan(8'hF0);
        check_blksbr(1'b1);
        scan(code);
        check_empty();
    end
endtask

task check_osd;
    input state;

    if (key_bushold !== state)
        begin
            $display("ASSERTION FAILURE: unexpected key_bushold %b", key_bushold);
            $finish;
        end
endtask

task check_osd_key;
    input[7:0] code;

    begin
        check_empty();
        scan(code);
        check_osd(1'b1);
        scan(8'hF0);
        check_osd(1'b1);
        scan(code);
        check_empty();
    end
endtask


task check_key;
    input[7:0] code;
    input[2:0] row;
    input[2:0] col;

    begin
        check_empty();
        scan(code);
        check_scan(row, col);
        scan(8'hF0);
        check_scan(row, col);
        scan(code);
        check_empty();
    end
endtask

task check_ekey;
    input[7:0] code1;
    input[7:0] code2;
    input[2:0] row;
    input[2:0] col;

    begin
        check_empty();
        scan(code1);
        check_empty();
        scan(code2);
        check_scan(row, col);
        scan(code1);
        check_scan(row, col);
        scan(8'hF0);
        check_scan(row, col);
        scan(code2);
        check_empty();
    end
endtask

task check_common;
    begin
        check_key(8'h0E, 3'd3, 3'd3);         //    ;           3-3         `               0E
        check_key(8'h16, 3'd2, 3'd1);         //    1           2-1         1               16
        check_key(8'h1E, 3'd2, 3'd2);         //    2           2-2         2               1E
        check_key(8'h26, 3'd2, 3'd3);         //    3           2-3         3               26
        check_key(8'h25, 3'd2, 3'd4);         //    4           2-4         4               25
        check_key(8'h2E, 3'd2, 3'd5);         //    5           2-5         5               2E
        check_key(8'h36, 3'd2, 3'd6);         //    6           2-6         6               36
        check_key(8'h3D, 3'd2, 3'd7);         //    7           2-7         7               3D
        check_key(8'h3E, 3'd3, 3'd0);         //    8           3-0         8               3E
        check_key(8'h46, 3'd3, 3'd1);         //    9           3-1         9               46
        check_key(8'h45, 3'd2, 3'd0);         //    0           2-0         0               45
        check_key(8'h4E, 3'd3, 3'd5);         //    -           3-5         -               4E
        check_key(8'h55, 3'd3, 3'd7);         //    /           3-7         =               55
        check_ctrl_key(8'h14);                //    УС          -           Ctrl            14
        check_ctrl_ekey(8'hE0, 8'h14);        //    УС          -           Ctrl            E0 14
        check_key(8'h52, 3'd7, 3'd4);         //    \           7-4         '               52
        check_shift_key(8'h12);               //    СС          -           Shift           12
        check_shift_key(8'h59);               //    СС          -           Shift           59
        check_key(8'h5A, 3'd0, 3'd2);         //    ВК          0-2         Enter           5A
        check_rus_key(8'h58);                 //    РУС/LAT     -           Caps            58
        check_key(8'h0D, 3'd0, 3'd0);         //    ТАБ         0-0         TAB             0D
        check_key(8'h29, 3'd7, 3'd7);         //    ПРОБЕЛ      7-7         Space           29
        check_ekey(8'hE0, 8'h1F, 3'd0, 3'd1); //    ПС          0-1         Windows         E0 1F
        check_ekey(8'hE0, 8'h27, 3'd0, 3'd1); //    ПС          0-1         Windows         E0 27
        check_key(8'h66, 3'd0, 3'd3);         //    ЗБ          0-3         BSpace          66
        check_blkvvod_key(8'h78);             //    ВВОД+БЛК    -           F11             78
        check_blksbr_key(8'h07);              //    БЛК+СБР     -           F12             07
        check_osd_key(8'h7E);                 //    OSD         -           ScrLock         7E
        check_key(8'h05, 3'd1, 3'd3);         //    F1          1-3         F1              05
        check_key(8'h06, 3'd1, 3'd4);         //    F2          1-4         F2              06
        check_key(8'h04, 3'd1, 3'd5);         //    F3          1-5         F3              04
        check_key(8'h0C, 3'd1, 3'd6);         //    F4          1-6         F4              0C
        check_key(8'h03, 3'd1, 3'd7);         //    F5          1-7         F5              03
        check_key(8'h76, 3'd1, 3'd2);         //    АР2         1-2         Esc             76
        check_ekey(8'hE0, 8'h70, 3'd1, 3'd0); //    ↖           1-0         Ins             E0 70
        check_ekey(8'hE0, 8'h75, 3'd0, 3'd5); //    ↑           0-5         ↑               E0 75
        check_ekey(8'hE0, 8'h6C, 3'd0, 3'd5); //    ↑           0-5         Home            E0 6C
        check_ekey(8'hE0, 8'h7D, 3'd1, 3'd1); //    СТР         1-1         PgUp            E0 7D
        check_ekey(8'hE0, 8'h6B, 3'd0, 3'd4); //    ←           0-4         ←               E0 6B
        check_ekey(8'hE0, 8'h71, 3'd0, 3'd4); //    ←           0-4         Del             E0 71
        check_ekey(8'hE0, 8'h72, 3'd0, 3'd7); //    ↓           0-7         ↓               E0 72
        check_ekey(8'hE0, 8'h69, 3'd0, 3'd7); //    ↓           0-7         End             E0 69
        check_ekey(8'hE0, 8'h74, 3'd0, 3'd6); //    →           0-6         →               E0 74
        check_ekey(8'hE0, 8'h7A, 3'd0, 3'd6); //    →           0-6         PgDn            E0 7A
    end
endtask

task check_jcuken;
    begin
        check_key(8'h15, 3'd5, 3'd2);         //    J           5-2         Q               15
        check_key(8'h1D, 3'd4, 3'd3);         //    C           4-3         W               1D
        check_key(8'h24, 3'd6, 3'd5);         //    U           6-5         E               24
        check_key(8'h2D, 3'd5, 3'd3);         //    K           5-3         R               2D
        check_key(8'h2C, 3'd4, 3'd5);         //    E           4-5         T               2C
        check_key(8'h35, 3'd5, 3'd6);         //    N           5-6         Y               35
        check_key(8'h3C, 3'd4, 3'd7);         //    G           4-7         U               3C
        check_key(8'h43, 3'd7, 3'd3);         //    [           7-3         I               43
        check_key(8'h44, 3'd7, 3'd5);         //    ]           7-5         O               44
        check_key(8'h4D, 3'd7, 3'd2);         //    Z           7-2         P               4D
        check_key(8'h54, 3'd5, 3'd0);         //    H           5-0         [               54
        check_key(8'h5B, 3'd3, 3'd2);         //    :           3-2         ]               5B
        check_key(8'h5D, 3'd3, 3'd6);         //    .           3-6         \               5D
        check_key(8'h1C, 3'd4, 3'd6);         //    F           4-6         A               1C
        check_key(8'h1B, 3'd7, 3'd1);         //    Y           7-1         S               1B
        check_key(8'h23, 3'd6, 3'd7);         //    W           6-7         D               23
        check_key(8'h2B, 3'd4, 3'd1);         //    A           4-1         F               2B
        check_key(8'h34, 3'd6, 3'd0);         //    P           6-0         G               34
        check_key(8'h33, 3'd6, 3'd2);         //    R           6-2         H               33
        check_key(8'h3B, 3'd5, 3'd7);         //    O           5-7         J               3B
        check_key(8'h42, 3'd5, 3'd4);         //    L           5-4         K               42
        check_key(8'h4B, 3'd4, 3'd4);         //    D           4-4         L               4B
        check_key(8'h4C, 3'd6, 3'd6);         //    V           6-6         ;               4C
        check_key(8'h1A, 3'd6, 3'd1);         //    Q           6-1         Z               1A
        check_key(8'h22, 3'd7, 3'd6);         //    ^           7-6         X               22
        check_key(8'h21, 3'd6, 3'd3);         //    S           6-3         C               21
        check_key(8'h2A, 3'd5, 3'd5);         //    M           5-5         V               2A
        check_key(8'h32, 3'd5, 3'd1);         //    I           5-1         B               32
        check_key(8'h31, 3'd6, 3'd4);         //    T           6-4         N               31
        check_key(8'h3A, 3'd7, 3'd0);         //    X           7-0         M               3A
        check_key(8'h41, 3'd4, 3'd2);         //    B           4-2         ,               41
        check_key(8'h49, 3'd4, 3'd0);         //    @           4-0         .               49
        check_key(8'h4A, 3'd3, 3'd4);         //    ,           3-4         /               4A
    end
endtask

task check_qwerty;
    begin
        check_key(8'h3B, 3'd5, 3'd2);         //    J           5-2         J               3B
        check_key(8'h21, 3'd4, 3'd3);         //    C           4-3         C               21
        check_key(8'h3C, 3'd6, 3'd5);         //    U           6-5         U               3C
        check_key(8'h42, 3'd5, 3'd3);         //    K           5-3         K               42
        check_key(8'h24, 3'd4, 3'd5);         //    E           4-5         E               24
        check_key(8'h31, 3'd5, 3'd6);         //    N           5-6         N               31
        check_key(8'h34, 3'd4, 3'd7);         //    G           4-7         G               34
        check_key(8'h54, 3'd7, 3'd3);         //    [           7-3         [               54
        check_key(8'h5B, 3'd7, 3'd5);         //    ]           7-5         ]               5B
        check_key(8'h1A, 3'd7, 3'd2);         //    Z           7-2         Z               1A
        check_key(8'h33, 3'd5, 3'd0);         //    H           5-0         H               33
        check_key(8'h4C, 3'd3, 3'd2);         //    :           3-2         ;               4C
        check_key(8'h49, 3'd3, 3'd6);         //    .           3-6         .               49
        check_key(8'h2B, 3'd4, 3'd6);         //    F           4-6         F               2B
        check_key(8'h35, 3'd7, 3'd1);         //    Y           7-1         Y               35
        check_key(8'h1D, 3'd6, 3'd7);         //    W           6-7         W               1D
        check_key(8'h1C, 3'd4, 3'd1);         //    A           4-1         A               1C
        check_key(8'h4D, 3'd6, 3'd0);         //    P           6-0         P               4D
        check_key(8'h2D, 3'd6, 3'd2);         //    R           6-2         R               2D
        check_key(8'h44, 3'd5, 3'd7);         //    O           5-7         O               44
        check_key(8'h4B, 3'd5, 3'd4);         //    L           5-4         L               4B
        check_key(8'h23, 3'd4, 3'd4);         //    D           4-4         D               23
        check_key(8'h2A, 3'd6, 3'd6);         //    V           6-6         V               2A
        check_key(8'h15, 3'd6, 3'd1);         //    Q           6-1         Q               15
        check_key(8'h4A, 3'd7, 3'd6);         //    ^           7-6         /               4A
        check_key(8'h1B, 3'd6, 3'd3);         //    S           6-3         S               1B
        check_key(8'h3A, 3'd5, 3'd5);         //    M           5-5         M               3A
        check_key(8'h43, 3'd5, 3'd1);         //    I           5-1         I               43
        check_key(8'h2C, 3'd6, 3'd4);         //    T           6-4         T               2C
        check_key(8'h22, 3'd7, 3'd0);         //    X           7-0         X               22
        check_key(8'h32, 3'd4, 3'd2);         //    B           4-2         B               32
        check_key(8'h5D, 3'd4, 3'd0);         //    @           4-0         \               5D
        check_key(8'h41, 3'd3, 3'd4);         //    ,           3-4         ,               41
    end
endtask

task jcuken;
    begin
        scan(8'hE0);
        scan(8'h11);
        scan(8'hE0);
        scan(8'hF0);
        scan(8'h11);
    end
endtask

task qwerty;
    begin
        scan(8'h11);
        scan(8'hF0);
        scan(8'h11);
    end
endtask

task check_lctrl_z;
    begin
        check_empty();
        scan(8'h14);
        check_ctrl(1'b1);
        scan(8'h1A);
        check_ctrl(1'b1);
        check_scan(4'h7, 3'h2);
        scan(8'hF0);
        scan(8'h1A);
        check_ctrl(1'b1);
        check_scan(4'hF, 3'h7);
        scan(8'hF0);
        scan(8'h14);
        check_empty();
    end
endtask

task check_rctrl_z;
    begin
        check_empty();
        scan(8'hE0);
        scan(8'h14);
        check_ctrl(1'b1);
        scan(8'h1A);
        check_ctrl(1'b1);
        check_scan(4'h7, 3'h2);
        scan(8'hF0);
        scan(8'h1A);
        check_ctrl(1'b1);
        check_scan(4'hF, 3'h7);
        scan(8'hE0);
        scan(8'hF0);
        scan(8'h14);
        check_empty();
    end
endtask

task check_lshift_z;
    begin
        check_empty();
        scan(8'h12);
        check_shift(1'b1);
        scan(8'h1A);
        check_shift(1'b1);
        check_scan(4'h7, 3'h2);
        scan(8'hF0);
        scan(8'h1A);
        check_shift(1'b1);
        check_scan(4'hF, 3'h7);
        scan(8'hF0);
        scan(8'h12);
        check_empty();
    end
endtask

task check_rshift_z;
    begin
        check_empty();
        scan(8'h59);
        check_shift(1'b1);
        scan(8'h1A);
        check_shift(1'b1);
        check_scan(4'h7, 3'h2);
        scan(8'hF0);
        scan(8'h1A);
        check_shift(1'b1);
        check_scan(4'hF, 3'h7);
        scan(8'hF0);
        scan(8'h59);
        check_empty();
    end
endtask

reg [11:0] ps2_data_wait;
reg [8:0] read_shiftreg;
task read;
    input[7:0] code;
    begin
        ps2_data_wait = 0;
        read_shiftreg = 9'b0;
        while (ps2_data && ps2_data_wait < 6000)
            begin
                repeat (1) @(posedge clk);
                ps2_data_wait = ps2_data_wait + 1;
            end
        if (ps2_data)
            begin
                $display("ASSERTION FAILURE: ps2_data low wait timeout");
                $finish;
            end
        repeat (1000) @(posedge clk);
        repeat (9) @(posedge clk)
            begin
                ps2_clkr    <= 0;
                repeat (50) @(posedge clk);
                ps2_clkr    <= 1;
                read_shiftreg <= {ps2_data, read_shiftreg[8:1]};
                repeat (50) @(posedge clk);
            end
            if (read_shiftreg[8:8] != ~^read_shiftreg[7:0])
                begin
                    $display("ASSERTION FAILURE: unexpected parity bit");
                    $finish;
                end
            if (read_shiftreg[7:0] != code)
                begin
                    $display("ASSERTION FAILURE: unexpected code %b", read_shiftreg[7:0]);
                    $finish;
                end

            ps2_clkr    <= 0;
            repeat (50) @(posedge clk);
            ps2_clkr    <= 1;
            repeat (50) @(posedge clk);
            ps2_clkr    <= 0;
            ps2_datar   <= 0;
            repeat (50) @(posedge clk);
            ps2_clkr    <= 1'bZ;
            ps2_datar   <= 1'bZ;
    end
endtask


initial
    begin
    	$dumpfile("keyboard_tb.vcd");
    	$dumpvars(0, keyboard_tb);

        reset		<= 1;
        ps2_clkr    <= 1'bZ;
        ps2_datar   <= 1'bZ;
        rd_en       <= 0;
        rowselect   <= 8'h00;
        led_rus     <= 1'b0;

        repeat (10) @(posedge clk);
        reset		<= 0;
        repeat (10) @(posedge clk);


        read(8'hF4);

        qwerty();
        check_common();
        check_qwerty();

        jcuken();
        check_common();
        check_jcuken();

        qwerty();
        check_lctrl_z();
        check_rctrl_z();
        check_lshift_z();
        check_rshift_z();

        led_rus <= 1'b1;
        repeat (1) @(posedge clk);
        read(8'hED);
        scan(8'hFA);
        read(8'b00000100);
        scan(8'hFA);

        led_rus <= 1'b0;
        repeat (1) @(posedge clk);
        read(8'hED);
        scan(8'hFA);
        read(8'b00000000);
        scan(8'hFA);

        $finish;
    end


initial
	begin
		clk <= 1;
		forever #20 clk <= !clk;
	end

assign ps2_clk = ps2_clkr;
assign ps2_data = ps2_datar;
pullup(ps2_clk);
pullup(ps2_data);

vectorkeys vectorkeys_inst (
    .clk(clk),
    .reset(reset),
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_data),
    .rowselect(rowselect),
    .rowbits(rowbits),
    .key_ctrl(key_ctrl),
    .key_shift(key_shift),
    .key_rus(key_rus),
    .key_blkvvod(key_blkvvod),
    .key_blksbr(key_blksbr),
    .key_bushold(key_bushold),
    .osd_active(1'b0),
    .led_rus(led_rus),
    .retrace(1'b0)
);

endmodule
