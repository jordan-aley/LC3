library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ALEY_FSM is 
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

end ALEY_FSM;

architecture FSM of ALEY_FSM is
type LC3_STATE_TYPE IS (INITIAL, FETCH0, FETCH1, FETCH2, FETCH3, FETCH4, FETCH5, DECODE, CLOSEREG, LOAD2, LOAD3, LOAD4, LOAD5, STORE2, STORE3, STORE4);

SIGNAL cpu_state: LC3_STATE_TYPE;
SIGNAL next_state: LC3_STATE_TYPE;

constant OP_NOT :std_logic_vector(3 downto 0):= "1001"; 
constant ADD :std_logic_vector(3 downto 0):= "0001"; 
constant LOAD :std_logic_vector(3 downto 0):= "0010"; 
constant OP_AND :std_logic_vector(3 downto 0):= "0101";
constant STORE :std_logic_vector(3 downto 0):= "0011";
constant BRANCH :std_logic_vector(3 downto 0):= "0000";

begin

nextstagelogic:process(CLK)
begin
	if (CLK = '1' AND CLK'EVENT) then
		if (RST = '1') then
			cpu_state <= INITIAL;
		else
			cpu_state <= next_state;
		end if;
	end if;
end process;

FSM: process(IR_IN, NZP_IN, cpu_state,next_state)

variable TRAPVECTOR: std_logic_vector(7 downto 0);
variable OPCODE: std_logic_vector(3 downto 0);
variable PC_OFF: std_logic_vector(8 downto 0);
variable NZP: std_logic_vector(2 downto 0);
variable SR1: std_logic_vector(2 downto 0);
variable SR2: std_logic_vector(2 downto 0);
variable DRIN: std_logic_vector(2 downto 0);
variable IR_5: std_logic;
variable IMMEDIATE: std_logic_vector(4 downto 0);
variable BASEREG: std_logic_vector(2 downto 0);

begin

case cpu_state is
------------INITIALIZE CASE--------
	when INITIAL =>
	 REG_EN	<= '0';
	 DR_EN<=(OTHERS=>'0');
	 SR1_EN <=(OTHERS=>'0');
	 SR2_EN <=(OTHERS=>'0');
	 ALU_EN <=(OTHERS=>'0');
	 SR2MUX_EN <= '0';
	 GATE_ALU <= '0';
	 MAR_EN	<= '0';
	 MDR_EN	<= '0';
	 MEM_EN	<= '0';
	 GATE_MDR<= '0';
	 read_write_en	<= '0';
	 MARMUX_EN<= '0';
	 A1M_EN <= '0';
	 A2M_EN <=(OTHERS=>'0');
    	 GATE_MARMUX <= '0';
	 PC_EN	<= '0';
	 GATE_PC <= '0';
	 PCMUX_EN<=(OTHERS=>'0'); 
	 IR_EN	<= '0';
	 NZP_EN	<= '0';
	 next_state<= FETCH0;

------------FETCH------
	when FETCH0=>
	 Gate_PC<='1';
	 MAR_EN<='1';
	 PCMUX_EN<="10";
	 next_state <= FETCH2;

	when FETCH1=>
	 PC_EN<='0';
	 Gate_PC<='1';
	 MAR_EN<='1';
	 PCMUX_EN<="10";
	 next_state <= FETCH2;

	when FETCH2=>
	 Gate_PC<='0';
	 MAR_EN<='0';
	 MEM_EN<='1';
	 next_state <= FETCH3;

	when FETCH3=>
	 next_state <= FETCH4;

	when FETCH4=>
	 Gate_MDR<='1';
	 MEM_EN<='0';
	 IR_EN<='1';
	 next_state <= FETCH5;


	when FETCH5=>
	 Gate_MDR<='0';
	 IR_EN<='0';
	 next_state <= DECODE;

-------------DECODE--------
	when DECODE =>
	 MDR_EN <= '0';
	 GATE_MDR <= '0';

	 OPCODE := IR_IN(15 DOWNTO 12);
	 IR_5 := IR_IN(5);
	 DRIN := IR_IN(11 DOWNTO 9);
	 SR1 := IR_IN(8 DOWNTO 6);
	 SR2 := IR_IN(2 DOWNTO 0);
	 PC_OFF := IR_IN(8 DOWNTO 0);
	 NZP := IR_IN(11 DOWNTO 9);
	 
	 CASE OPCODE IS
		when ADD =>
		  if( IR_5 = '0') then
			NZP_EN <='1';
			REG_EN <='1';
			GATE_ALU<='1';
			SR1_EN <= SR1;
			SR2_EN <= SR2;
			DR_EN <= DRIN;
			SR2MUX_EN<='0';
			ALU_EN<="11";
			next_state<=CLOSEREG;
		  else
			NZP_EN <='1';
			REG_EN <='1';
			GATE_ALU<='1';
			SR1_EN <= SR1;
			DR_EN <= DRIN;
			SR2MUX_EN<='1';
			ALU_EN<="11";
			next_state<=CLOSEREG;
		end if;	
		
	  	when LOAD =>			
			A1M_EN<='1';
			A2M_EN<="01";
			MARMUX_EN <='1';
		   	GATE_MARMUX <='1';
			MAR_EN <='1';

			next_state<=LOAD2;
	
		when OP_AND =>
		  if( IR_5 = '0') then
			NZP_EN <='1';
			REG_EN <='1';
			GATE_MDR <= '0';
			GATE_MARMUX <= '0';
			GATE_ALU<='1';
			SR1_EN <= SR1;
			SR2_EN <= SR2;
			DR_EN <= DRIN;
			SR2MUX_EN<='0';
			ALU_EN<="10";
			next_state<=CLOSEREG;
		  else
			NZP_EN <='1';
			REG_EN <='1';
			GATE_MDR <= '0';
			GATE_MARMUX <= '0';
			GATE_ALU<='1';
			SR1_EN <= SR1;
			DR_EN <= DRIN;
			SR2MUX_EN<='1';
			ALU_EN<="10";
			next_state<=CLOSEREG;
		end if;

		when OP_NOT =>
		 NZP_EN <='1';
		 REG_EN <='1';
		 GATE_MDR <= '0';
		 GATE_MARMUX <= '0';
		 GATE_ALU<='1';
		 SR1_EN <= SR1;
		 DR_EN <= DRIN;
		 SR2MUX_EN<='0';
		 ALU_EN<="00";
		 next_state<=CLOSEREG;

		when STORE =>
		 A1M_EN<='1';
		 A2M_EN<="01";
		 SR1_EN<= DRIN;
		 SR2_EN<= DRIN;
		 MARMUX_EN <='1';
		 GATE_MARMUX <='1';
		 MAR_EN <='1';
		 MEM_EN <='0';
		 next_state <= STORE2;

		when BRANCH =>
		 if NZP = "000" then
			MARMUX_EN<='0';
			GATE_MARMUX<='1';
			PCMUX_EN<="00";
			PC_EN<='1';
			next_state<=FETCH1;	
		 else	
			A1M_EN<='1';
			A2M_EN<="01";
			MARMUX_EN <='1';
			PCMUX_EN<="00";
			PC_EN<='1';
			GATE_MARMUX<='1';
			next_state<=FETCH1;
		end if;
		when others=>
			next_state<=INITIAL;
	 end case;

	when CLOSEREG =>
	 NZP_EN <='0';
	 SR1_EN <= (OTHERS=>'0');
	 SR2_EN <= (OTHERS=>'0');
	 REG_EN <='0';
	 GATE_ALU<='0';
	 PC_EN <='1';
	 next_state <= FETCH1;

-------EXECUTE/STORE--------
	when LOAD2 =>

	 GATE_MARMUX <= '0';
	 MAR_EN <= '0';
	 MEM_EN <= '1';
	 next_state<=LOAD3;

	when LOAD3 =>
	 next_state<=LOAD4;

	when LOAD4 =>
	 GATE_MDR <='1';
	 REG_EN <='1';
	 DR_EN <= DRIN;
	 next_state<=LOAD5;

	when LOAD5 =>
	 GATE_MDR <='0';
	 REG_EN <='0';
	 PC_EN <='1';
	 next_state <= FETCH1;

	when STORE2 =>
	 GATE_MARMUX <= '1';
	 MARMUX_EN <= '1';
	 MAR_EN <= '0';
	 MDR_EN <= '1';
	 next_state <= STORE3;

	when STORE3 =>
	 GATE_MARMUX <= '0';
	 GATE_ALU <= '0';
	 MDR_EN <= '0';
	 read_write_en <= '1';
	 MEM_EN <= '1';
	 next_state <= STORE4;

	when STORE4 =>
	 read_write_en <= '0';
	 MEM_EN <= '0';
	 PC_EN <= '1';
	 next_state <= FETCH1;

end case;
end process;
end FSM;