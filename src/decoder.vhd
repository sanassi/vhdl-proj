LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity decoder is
port(
       clk : in std_logic;
       rst : in std_logic;
       instruction  : in std_logic_vector(3 downto 0);
       regPSR_OUT : in std_logic_vector(3 downto 0)
    )

end entity;
architecture rtl of decoder is

type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT);

signal curr_instr: enum_instruction;
-- process sensible sur la sortie de la mémoire instructions : set curr_instr

--  process sensible sur les signaux instructions et curr_instr qui donnera la
--    valeur des commandes des registres et opérateurs du processeur.

end architecture;


