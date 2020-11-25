General Description
--------------------------------------------------------------------------

A simple design to test the workflow and style. 
Each time you press the pushbutton, it increases the LED brightness.

Directory structure
--------------------------------------------------------------------------

DOC
	DOX_HDL : Auto-generated Doxygen documentation

HDL
	RTL	: Synthesized RTL codes.
	BHV	: Behavioral codes.
	TB	: Testbenches.

PYTHON

VIVADO
	BIN    : Binary files
	CONSTR : Constraint files
	IMPL   : Implementation files
	SYNTH  : Synthesis files
	TCL    : Vivado scripts
	WORK   : Working directory for TCL based operations

Hardware
--------------------------------------------------------------------------

CMOD-A7 is used for verification. 
* FPGA: Xilinx Artix-7 (XC7A35T-1CPG236C)
* 12 MHz clock

Simulation
--------------------------------------------------------------------------

	cd GHDL/
	make

Synthesis
--------------------------------------------------------------------------

To generate the bitstream with Vivado TCL mode, in `VIVADO/WORK` directory:

	cmd
	vivado -mode tcl
	source ../TCL/build.tcl

Implementation results:

- Area  : 45 LUT + 37 FF

Programming the FPGA
--------------------------------------------------------------------------

Run program.tcl to program the FPGA:

	vivado -mode tcl
	source ../TCL/program.tcl

Run flash.tcl to program the configuration flash memory:
	
	source ../TCL/flash.tcl

Verification
--------------------------------------------------------------------------

CMOD-A7: press the pushbutton and observe LED brightness.
