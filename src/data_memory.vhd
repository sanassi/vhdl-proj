library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_memory is
    port (
            clk : in std_logic;
            rst : in std_logic;
            dataIn : in std_logic_vector(31 downto 0);
            dataOut : out std_logic_vector(31 downto 0);
            addr : in std_logic_vector(5 downto 0);
            WrEn : in std_logic
         );
end entity;

architecture RTL of data_memory is
-- Declaration Type Tableau Memoire
    type table is array(63 downto 0) of std_logic_vector(31 downto 0);
-- Fonction d'Initialisation des registre (64 mots de 32 bits)
    function init_regs return table is
        variable result : table;
    begin
        for i in 62 downto 0 loop
            result(i) := std_logic_vector(to_signed(1,32));
        end loop;
        result(63):=X"00000030";
        result(32):=X"00000A00";
        result(42):=X"00000042";
        return result;
    end init_regs;
-- Déclaration et Initialisation des 64 mots de 32 bits
    signal registers: table:=init_regs;

begin
    dataOut <= registers(to_integer(unsigned(addr)));
    process(clk, rst)
    begin
        if rst = '1' then
            registers <= init_regs;
        elsif rising_edge(clk) then
            if WrEn = '1' then
                if to_integer(unsigned(addr)) <= 63 then
                    registers(to_integer(unsigned(addr))) <= dataIn;
                end if;
            end if;
        end if;
    end process;
end architecture RTL;
