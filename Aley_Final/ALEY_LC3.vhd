library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity ALEY_PATH is
	generic(
		ADD_WIDTH: integer := 9;
		WIDTH: integer := 16;
		z8: std_logic_vector (7 downto 0) := (others => '0');
		z16: std_logic_vector (15 downto 0) := (others => '0'); 
		Sel4: integer:=2;
		REG_ADD: integer :=3;
		E: natural:= 8;
		k: std_logic:='0'
);	
	port (
		CLK: in std_logic;
		RSTn: in std_logic

);
end ALEY_PATH;

architecture PATH_arch of ALEY_PATH is

------------------------------------------------------------------
--Component Declarations
------------------------------------------------------------------

component ALEY_MAR
	generic(
		ADD_WIDTH: integer := 9;
		WIDTH: integer := 16
);	
	port (
		CLK: in std_logic;
		MAR_EN: in std_logic;
		RST: in std_logic;
		BUS_IN: in std_logic_vector(WIDTH-1 downto 0);
		MAR_OUT: out std_logic_vector (ADD_WIDTH-1 downto 0)
);
end component;

component ALEY_MEMORY
	generic(
		ADD_WIDTH: integer := 9;
		WIDTH: integer := 16
);	

	port (
		CLK: in std_logic;
		mem_wr_rd_add: in std_logic_vector(ADD_WIDTH-1 downto 0);
		Data_in: in std_logic_vector(WIDTH-1 downto 0);
		read_write_en: in std_logic;
		mem_en: in std_logic;
		MEM_OUT: out std_logic_vector (WIDTH-1 downto 0)	
);
end component;

component ALEY_MDR
	generic(WIDTH: integer := 16);	
	port (
		CLK: in std_logic;
		MDR_EN: in std_logic;
		RST: in std_logic;
		MDR_IN: in std_logic_vector(WIDTH-1 downto 0);
		MEM_IN: in std_logic_vector (WIDTH-1 downto 0);
		MDR_OUT: out std_logic_vector (WIDTH-1 downto 0)
); 
end component;

component ALEY_GATE_MDR
	generic(
		WIDTH: integer := 16
);	  
	port (
		OP_A: in std_logic_vector (WIDTH-1 downto 0);
		EN: in std_logic;
		OP_Q: out std_logic_vector (WIDTH-1 downto 0)
);
end component;

component ALEY_IR
	generic(
		WIDTH: natural:= 16
);

	port (
		clk: in std_logic;
		OP_A: in std_logic_vector (WIDTH-1 downto 0);
		RST: in std_logic;
		EN: in std_logic;
		OP_Q: out std_logic_vector (WIDTH-1 downto 0)
); 
end component;

component ALEY_6SEXT
generic(
		WIDTH: natural:= 16
);
	port (
		OP_A: in std_logic_vector(5 downto 0);
		OP_Q: out std_logic_vector(WIDTH-1 downto 0)
);
end component;

component ALEY_9SEXT
generic(
		WIDTH: natural:= 16
);
	port (
		OP_A: in std_logic_vector(8 downto 0);
		OP_Q: out std_logic_vector(WIDTH-1 downto 0)
); 
end component;

component ALEY_11SEXT
generic(
		WIDTH: natural:= 16
); 
	port (
		OP_A: in std_logic_vector(10 downto 0);
		OP_Q: out std_logic_vector(WIDTH-1 downto 0)
); 
end component;

component ALEY_8ZEXT
generic(
		WIDTH: natural:= 16;
		z8: std_logic_vector (7 downto 0) := (others => '0')
);
	port (
		OP_A: in std_logic_vector(7 downto 0);
		OP_Q: out std_logic_vector(WIDTH-1 downto 0)
); 
end component;

component ALEY_5SEXT
generic(
		WIDTH: integer:= 16
);
	port (
		OP_A: in std_logic_vector(4 downto 0);
		OP_Q: out std_logic_vector(WIDTH-1 downto 0)
);
end component;

component ALEY_A2M
generic( 
	WIDTH: INTEGER:= 16;
	Sel4: INTEGER:= 2;
	z16: std_logic_vector (15 downto 0) := (others => '0')
);  
port (
	a: in std_logic_vector( WIDTH-1 downto 0);
	b: in std_logic_vector( WIDTH-1 downto 0);
	c: in std_logic_vector( WIDTH-1 downto 0);
	d: in std_logic_vector( WIDTH-1 downto 0);
	s: in std_logic_vector(Sel4-1 downto 0);
	y: out std_logic_vector(WIDTH-1 downto 0)
); 
end component;

component ALEY_MARMUX
generic( 
	WIDTH: INTEGER:= 16
);
port (
	a: in std_logic_vector(WIDTH-1 downto 0);
	b: in std_logic_vector(WIDTH-1 downto 0);
	s: in std_logic;
	y: out std_logic_vector(WIDTH-1 downto 0)
); 
end component;

component ALEY_ADDER
generic(
	WIDTH: integer := 16
); 
port (
	OP_A, OP_B: in std_logic_vector (WIDTH-1 downto 0);
	OP_Q: out std_logic_vector (WIDTH-1 downto 0)
);
end component;

component ALEY_A1M
generic( WIDTH: INTEGER:= 16
);  
port (
	a: in std_logic_vector(WIDTH-1 downto 0);
	b: in std_logic_vector(WIDTH-1 downto 0);
	s: in std_logic;
	y: out std_logic_vector(WIDTH-1 downto 0)
);
end component;

component ALEY_SR2MUX
generic( WIDTH: INTEGER:= 16
);  
port (
	a: in std_logic_vector(WIDTH-1 downto 0);
	b: in std_logic_vector(WIDTH-1 downto 0);
	s: in std_logic;
	y: out std_logic_vector(WIDTH-1 downto 0)
);
end component;

component ALEY_ALU
generic(
		WIDTH: integer:=16;
		Sel4: INTEGER:= 2 
);
	port (
		OP_A, OP_B: in std_logic_vector (WIDTH-1 downto 0);
		sel: in std_logic_vector (Sel4-1 downto 0);
		OP_Q: out std_logic_vector (WIDTH-1 downto 0)
); 
end component;

component ALEY_GATE_MARMUX
	generic(
		WIDTH: integer := 16
);	  
	port (
		OP_A: in std_logic_vector (WIDTH-1 downto 0);
		EN: in std_logic;
		OP_Q: out std_logic_vector (WIDTH-1 downto 0)
);
end component;

component ALEY_GATE_ALU
	generic(
		WIDTH: integer := 16
);	  
	port (
		OP_A: in std_logic_vector (WIDTH-1 downto 0);
		EN: in std_logic;
		OP_Q: out std_logic_vector (WIDTH-1 downto 0)
);
end component;

component ALEY_NZP
generic(
	WIDTH: integer:=16
);
port (
	clk: in std_logic;
	RST: in std_logic;
	EN: in std_logic;
	OP_A: in std_logic_vector (WIDTH-1 downto 0);
	OP_NZP: out std_logic_vector (2 downto 0)
);
end component;

component ALEY_PCMUX
generic( WIDTH: INTEGER:= 16;
	 Sel4: INTEGER:= 2 
);  
port (
        a: in std_logic_vector(WIDTH-1 downto 0);
	b: in std_logic_vector(WIDTH-1 downto 0);
	c: in std_logic_vector(WIDTH-1 downto 0);
	s: in std_logic_vector(Sel4-1 downto 0);
	y: out std_logic_vector(WIDTH-1 downto 0)
);
end component;

component ALEY_PC
generic(
	WIDTH: integer:=16
);
port (
	clk: in std_logic;
	RST: in std_logic;
	EN: in std_logic;
	OP_A: in std_logic_vector (WIDTH-1 downto 0);
	OP_Bus: out std_logic_vector (WIDTH-1 downto 0);
	OP_Inc: out std_logic_vector (WIDTH-1 downto 0)
);
end component;

component ALEY_GATE_PC
generic(
	WIDTH: integer := 16
);	  
port (
	OP_A: in std_logic_vector (WIDTH-1 downto 0);
	EN: in std_logic;
	OP_Q: out std_logic_vector (WIDTH-1 downto 0)
);
end component;

component ALEY_REGARRAY
generic(
	WIDTH: integer:=16;
	REG_ADD: integer:=3;
	E: natural:= 8
);
port (
	CLK: in std_logic;
	OP_A: in std_logic_vector (WIDTH-1 downto 0);
	DR: in std_logic_vector(REG_ADD-1 downto 0);
	LD_REG: in std_logic; --enable
	RST: in std_logic;
	SR1: in std_logic_vector (REG_ADD-1 downto 0);
	SR2: in std_logic_vector (REG_ADD-1 downto 0);
	OP_Q1: out std_logic_vector (WIDTH-1 downto 0);
	OP_Q2: out std_logic_vector (WIDTH-1 downto 0)
);
end component;


component ALEY_16bitREG
	
	generic(
		k: std_logic:='0'
);
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
		OP_A: in std_logic_vector(15 downto 0);
                OP_Q: out std_logic_vector(15 downto 0)
);

end component;



component ALEY_FSM
	generic(
	WIDTH: integer:= 16;
	REG_ADD: integer :=3
);
port(
	CLK: in std_logic;
	IR_IN: in std_logic_vector(WIDTH-1 downto 0);
	RST: in std_logic;
	NZP_IN: in std_logic_vector(REG_ADD-1 downto 0);
	SR2MUX_EN: out std_logic;
	ALU_EN: out std_logic_vector(1 downto 0);
	Gate_ALU: out std_logic;
	NZP_EN: out std_logic;
	IR_EN: out std_logic;
	DR_EN: out std_logic_vector(REG_ADD-1 downto 0);
	SR1_EN: out std_logic_vector(REG_ADD-1 downto 0);
	SR2_EN: out std_logic_vector(REG_ADD-1 downto 0);
	REG_EN: out std_logic;
	MAR_EN: out std_logic;
	MEM_EN: out std_logic;
	read_write_en: out std_logic;
	MDR_EN: out std_logic;
	Gate_MDR: out std_logic;
	A2M_EN: out std_logic_vector(1 downto 0);
	A1M_EN: out std_logic;
	MARMUX_EN: out std_logic;
	Gate_MARMUX: out std_logic;
	PCMUX_EN: out std_logic_vector(1 downto 0);
	PC_EN: out std_logic;
	Gate_PC: out std_logic
);
end component;

------------------------------------------------------------------
--Signals
------------------------------------------------------------------

signal S_MAR_OUT: std_logic_vector (ADD_WIDTH-1 downto 0);
signal S_MEM_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_MDR_BUS: std_logic_vector (WIDTH-1 downto 0);
signal S_IR_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_6SEXT_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_9SEXT_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_11SEXT_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_8ZEXT_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_5SEXT_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_A1M_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_A2M_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_ADDER_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_MARMUX_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_SR2MUX_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_SR1_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_SR2_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_PC_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_PCP_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_ALU_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_NZP_OUT: std_logic_vector (2 downto 0);
signal S_PCMUX_OUT: std_logic_vector (WIDTH-1 downto 0);
signal S_BUSSS: std_logic_vector (WIDTH-1 downto 0);

signal mem_en: std_logic;
signal read_write_en: std_logic;
signal MDR_EN: std_logic;
signal MAR_EN: std_logic;
signal Gate_MDR: std_logic;
signal Gate_MARMUX: std_logic;
signal Gate_ALU: std_logic;
signal Gate_PC: std_logic;
signal IR_EN: std_logic;
signal A1M_EN: std_logic;
signal SR2MUX_EN: std_logic;
signal MARMUX_EN: std_logic;
signal NZP_EN: std_logic;
signal PC_EN: std_logic;
signal REG_EN: std_logic;
signal DR_EN: std_logic_vector(REG_ADD-1 downto 0);
signal SR1_EN: std_logic_vector(REG_ADD-1 downto 0);
signal SR2_EN: std_logic_vector(REG_ADD-1 downto 0);
signal A2M_EN: std_logic_vector(Sel4-1 downto 0);
signal ALU_EN: std_logic_vector(Sel4-1 downto 0);
signal PCMUX_EN: std_logic_vector(Sel4-1 downto 0);
signal BUSSS: std_logic_vector (WIDTH-1 downto 0);

------------------------------------------------------------------
--Instantiations
------------------------------------------------------------------

BEGIN

Inst1_MAR:ALEY_MAR generic map(ADD_WIDTH,WIDTH) port map(CLK, MAR_EN, RSTn, S_BUSSS, S_MAR_OUT);
Inst2_MEM:ALEY_MEMORY generic map(ADD_WIDTH,WIDTH) port map(CLK, S_MAR_OUT, S_MDR_BUS, read_write_en, mem_en, S_MEM_OUT);
Inst3_MDR:ALEY_MDR generic map(WIDTH) port map(CLK,MDR_EN,RSTn,S_BUSSS,S_MEM_OUT,S_MDR_BUS);
Inst4_GATE_MDR:ALEY_GATE_MDR generic map(WIDTH) port map(S_MDR_BUS,GATE_MDR,S_BUSSS);
Inst5_IR:ALEY_IR generic map(WIDTH) port map(CLK, S_BUSSS, RSTn, IR_EN, S_IR_OUT);
Inst6_6SEXT:ALEY_6SEXT generic map(WIDTH) port map(S_IR_OUT(5 downto 0), S_6SEXT_OUT);
Inst7_9SEXT:ALEY_9SEXT generic map(WIDTH) port map(S_IR_OUT(8 downto 0),S_9SEXT_OUT);
Inst8_11SEXT:ALEY_11SEXT generic map(WIDTH) port map(S_IR_OUT(10 downto 0),S_11SEXT_OUT);
Inst9_8ZEXT:ALEY_8ZEXT generic map(WIDTH) port map(S_IR_OUT(7 downto 0),S_8ZEXT_OUT);
Inst10_5SEXT:ALEY_5SEXT generic map(WIDTH) port map(S_IR_OUT(4 downto 0), S_5SEXT_OUT);
Inst11_A2M:ALEY_A2M generic map(WIDTH,Sel4,z16) port map(S_11SEXT_OUT,S_9SEXT_OUT,S_6SEXT_OUT,z16,A2M_EN, S_A2M_OUT);
Inst12_MARMUX:ALEY_MARMUX generic map(WIDTH) port map(S_8ZEXT_OUT,S_ADDER_OUT,MARMUX_EN,S_MARMUX_OUT);
Inst13_ADDER:ALEY_ADDER generic map(WIDTH) port map(S_A1M_OUT,S_A2M_OUT,S_ADDER_OUT);
Inst14_A1M:ALEY_A1M generic map(WIDTH) port map(S_SR1_OUT,S_PCP_OUT,A1M_EN,S_A1M_OUT);
Inst15_SR2MUX:ALEY_SR2MUX generic map(WIDTH) port map(S_SR2_OUT,S_5SEXT_OUT,SR2MUX_EN,S_SR2MUX_OUT);
Inst16_ALU:ALEY_ALU generic map(WIDTH, Sel4) port map(S_SR1_OUT,S_SR2MUX_OUT,ALU_EN,S_ALU_OUT);
Inst17_GATE_MARMUX:ALEY_GATE_MARMUX generic map(WIDTH) port map(S_MARMUX_OUT,GATE_MARMUX,S_BUSSS);
Inst18_GATE_ALU:ALEY_GATE_ALU generic map(WIDTH) port map(S_ALU_OUT,GATE_ALU,S_BUSSS);
Inst19_NZP:ALEY_NZP generic map(WIDTH) port map(CLK,RSTn,NZP_EN,S_BUSSS,S_NZP_OUT);
Inst20_PCMUX:ALEY_PCMUX generic map(WIDTH,Sel4) port map (S_BUSSS,S_ADDER_OUT,S_PCP_OUT,PCMUX_EN,S_PCMUX_OUT);
Inst21_PC:ALEY_PC generic map(WIDTH) port map (CLK,RSTn,PC_EN,S_PCMUX_OUT,S_PC_OUT,S_PCP_OUT);
Inst22_GATE_PC:ALEY_GATE_PC generic map(WIDTH) port map(S_PC_OUT,GATE_PC,S_BUSSS);
Inst23_REGARRAY:ALEY_REGARRAY generic map(WIDTH,REG_ADD,E) port map(CLK,S_BUSSS,DR_EN,REG_EN,RSTn,SR1_EN,SR2_EN,S_SR1_OUT,S_SR2_OUT);
Inst24_FSM:ALEY_FSM generic map(WIDTH) port map(CLK,S_IR_OUT,RSTn,S_NZP_OUT,SR2MUX_EN,ALU_EN,Gate_ALU,NZP_EN,IR_EN,DR_EN,SR1_EN,SR2_EN,REG_EN,MAR_EN,mem_en,read_write_en,MDR_EN,Gate_MDR,A2M_EN,A1M_EN,MARMUX_EN,Gate_MARMUX,PCMUX_EN,PC_EN,Gate_PC);

BUSSS <= S_BUSSS;

end PATH_arch;