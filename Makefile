###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project) and the Quartus II
# Settings File (.qsf)
###################################################################

PROJECT = vector06cc
TOP_LEVEL_ENTITY = vector06cc
ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf
QUARTUS_DIR = $(HOME)/altera/13.0sp1

###################################################################
# Part, Family, Boardfile DE1 or DE2
FAMILY = "Cyclone II"
PART = EP2C20F484C7
BOARDFILE = DE1
###################################################################

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
# prog: program your device with the compiled design
###################################################################

all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt 

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db incremental_db reports

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = --read_settings_files=on $(addprefix --source=,$(SRCS)) -l ./src -l ./src/altmodules -l ./src/DE1 -l ./src/T80
FIT_ARGS = --part=$(PART) --read_settings_files=on
ASM_ARGS =
STA_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(PROJECT).map.rpt: map.chg ./src
	quartus_map $(PROJECT).qpf
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT) 

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

###################################################################
# Project initialization
###################################################################

$(ASSIGNMENT_FILES):
map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg

###################################################################
# Programming the device
###################################################################

prog: reports/$(PROJECT).sof
	quartus_pgm --no_banner --mode=jtag -o "P;reports/$(PROJECT).sof"

flash: reports/$(PROJECT).pof
	quartus_pgm --no_banner --mode=as -o "P;reports/$(PROJECT).pof"
