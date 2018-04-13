TESTBENCH = keyboard_tb
SRCS	  = ps2rx.v ps2tx.v vectorkeys.v ../oneshot.v scan2matrix.v

all: simulate

lint:
	verilator --lint-only +verilog2001ext+v $(SRCS)

simulate:
	iverilog -g2001 -Dx16 -o $(TESTBENCH).vvp $(SRCS) $(TESTBENCH).v
	vvp $(TESTBENCH).vvp

show: simulate
	open $(TESTBENCH).vcd

clean:
	rm -rf $(TESTBENCH).vvp $(TESTBENCH).vcd $(TESTBENCH)_log.txt
