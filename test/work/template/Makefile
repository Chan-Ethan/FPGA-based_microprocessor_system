#VERDI_HOME = /home/synopsys/verdi/Verdi_O-2018.09-SP2
FILE_LIST = ../../top/flist.f
tc = simple_test
VERBOSITY = HIGH
MAX_QUIT_COUNT = 500
UVM_HOME = ../../uvm-1.1d/uvm-1.1d

compile:
	vcs	\
	+v2k \
	+define+SIMULATION \
	-full64 \
	-sverilog \
	-top top_tb \
	-debug_pp \
	-ntb_opts uvm-1.1 \
	-timescale=1ns/1ns \
	-fsdb \
	+incdir+dirctory+$(UVM_HOME)/src \
	$(UVM_HOME)/src/uvm.sv \
	-f $(FILE_LIST) \
	../../testcase/$(tc).sv \
	-l ./comp_log/$(tc).log \
	#-o $(tc).o

sim:
	#./$(tc)
	./simv \
	-l ./sim_log/$(tc).log \
	+UVM_VERBOSITY=$(VERBOSITY) \
	+UVM_TESTNAME=$(tc)	\
	+UVM_MAX_QUIT_COUNT=$(MAX_QUIT_COUNT) \
	+define+SIMULATION \
	+fsdb+autoflush \
	+fsdbfile+./fsdb/$(tc).fsdb \
	#+UVM_TR_RECORD \

# show the code coverage
wave:
	verdi \
    -sv \
    +define+SIMULATION \
    -f $(FILE_LIST) \
	-top top_tb \
    -ssf ./fsdb/$(tc).fsdb \
    & 

clean:
	rm -rf *.log ucli.key vc_hdrs.h csrc simv* verdiLog novas* ./comp_log/* ./sim_log/* ./fsdb/*

all: clean compile sim
all2: all wave
