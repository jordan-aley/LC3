# LC3
Completed the LC3 by:

Designing, in VHDL, the Control Path, Finite State Machine (FSM), of the LC3 data-path, wiring components together, and instantiating the LC3 Data Path.

Designed a program, consisting of 8 Instructions and data. Initialized RAM component with this program. Program executed the following LC3 instructions:
2 x LOAD from memory
AND
NOT
OR
ADD
2 x STORE to memory (required)

Designed, in VHDL, the Control Path, [Finite State Machine (FSM)], of the LC3. Wired it into DATA PATH.

Created the Top-Level LC3 entity: It has the following two inputs:
CLK
RESET

Used LC3 Testbench to test and functionally verify LC3

The simulation requires no I/O. It simulates the program in memory.

The simulation returns to the INITIALIZATION state when all eight instructions have executed

Created .DO file for the simulation and properly sorted signals

BUS (this signal shows exactly which instruction/data is on the bus)
INPUTS/OUTPUTS (these signals show the I/O of each component)
Enables and Selects
Store/Loads (these signals show which instruction/data is loaded and stored)
A sorted block for each component instantiation

SCREENSHOT of the RAM design using the MEMORY VIEW feature in ModelSim included
Screenshots of the DATAFLOW schematics included
