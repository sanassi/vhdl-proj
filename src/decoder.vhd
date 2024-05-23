LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity decoder is
port(
       instruction, PSR  : in std_logic_vector(31 downto 0);
       rd, rn, rm : out std_logic_vector(31 downto 0);
       PCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, ALUCtr, PSREn, WrSrc : out
       std_logic
    );

end entity;
architecture rtl of decoder is

type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT, UNSUPPORTED_INSTR);
signal curr_instr: enum_instruction;
begin
-- process sensible sur la sortie de la mémoire instructions : set curr_instr
process (instruction)
        variable opcode : std_logic_vector(3 downto 0) := (others => '0');
begin
    opcode := instruction(24 downto 21);
    if instruction(27 downto 26) = "00" then -- instr de traitement
        case(opcode) is
            when "1101" => curr_instr <= MOV ;
            when "0000" =>
                if instruction(25) = '1' then
                    curr_instr <= ADDi;
                else
                    curr_instr <= ADDr;
                end if;
            when "1010" => curr_instr <= CMP;
            when others => curr_instr <= UNSUPPORTED_INSTR;
        end case;
    elsif instruction(27 downto 26) = "01" then -- instr de transfert
        if instruction(20) = '1' then
            curr_instr <= LDR;
        else
            curr_instr <= STR;
        end if;
    elsif instruction(27 downto 25) = "101" then  -- instr de branchement
        if instruction(31 downto 28) = "1011" then -- LT / Less Than
            curr_instr <= BLT;
        elsif instruction(31 downto 28) = "1110" then -- AL / Always
            curr_instr <= BAL;
        else
            curr_instr <= UNSUPPORTED_INSTR;
        end if;
    else
        curr_instr <= UNSUPPORTED_INSTR;
    end if;
end process;

--  process sensible sur les signaux instructions et curr_instr qui donnera la
--    valeur des commandes des registres et opérateurs du processeur.
-- process ()
-- begin
-- end process;

end architecture;


