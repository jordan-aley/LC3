------------------------------------------------------------
--File Name:		tb_ALEY_LC3.vhd
--Jordan Aley
--ADvanced Digital Design
--Fall 2019
-----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.all;

entity tb_ALEY_LC3 is
end tb_ALEY_LC3;


architecture TB1 of tb_ALEY_LC3 is

constant ADD_WIDTH: integer := 9;
constant WIDTH: integer := 16;
constant z8: std_logic_vector (7 downto 0) := (others => '0');
constant z16: std_logic_vector (15 downto 0) := (others => '0'); 
constant Sel4: integer:=2;
constant REG_ADD: integer :=3;
constant E: natural:= 8;
constant k: std_logic:='0';

component ALEY_PATH is
port (
	CLK: in std_logic;  
	RSTn: in std_logic
     );
end component ALEY_PATH;

signal	CLKtb	: std_logic; 				
signal	RSTntb	: std_logic;				

begin

CLK_GEN: process 
begin 
while now <= 6000 ns loop 
CLKtb <='1'; wait for 5 ns; CLKtb <='0'; wait for 5 ns; 
end loop; 
wait; 
end process; 

Reset: process
begin
RSTntb  <='1','0' after 10 ns;
wait;
end process;


--------------------------------------do not change-----------------------------------------------
datap: ALEY_PATH port map ( CLK=>CLKtb, RSTn=>RSTntb);

end TB1;

configuration CFG_tb_ALEY_LC3 of tb_ALEY_LC3 is
	for TB1
	end for;
end CFG_tb_ALEY_LC3;