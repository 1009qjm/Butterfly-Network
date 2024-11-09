OUTPUT = butterfly
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name ${OUTPUT}
CM_DIR = -cm_dir ./${OUTPUT}.vdb

all: listfile com sim verdi clean

listfile:
	find -name "*.sv" > filelist.f

com:
	vcs -full64 -sverilog -debug_access -timescale=1ns/10ps \
	-f filelist.f -l com.log -kdb -lca ${CM} ${CM_NAME} ${CM_DIR}

sim:
	./simv -l sim.log ${CM}	${CM_NAME} ${CM_DIR}

cov:
	dve -full64 -covdir *.vdb &

urg:
	urg -dir *.vdb

verdi:
	verdi -f filelist.f -ssf *.fsdb -nologo &

clean:
	rm -rf csrc *.log *.key *simv* *.vpd *DVE*
	rm -rf verdiLog *.fsdb *.bak *.conf *.rc *.f

