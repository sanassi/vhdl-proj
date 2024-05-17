library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg_bench is
    port ( clk : in std_logic;
           rst : in std_logic;
           w   : in std_logic_vector(31 downto 0);
           ra, rb : in std_logic_vector(3 downto 0);
           rw  : in std_logic_vector(3 downto 0);
           we  : in std_logic;
           a, b: out std_logic_vector(31 downto 0)
         );

end entity;

architecture RTL of reg_bench is

    type table is array (15 downto 0) of std_logic_vector(31 downto 0);

    -- Reset registers content
    function init_banc return table is
        variable result : table;
    begin
        for i in 14 downto 0 loop
            result(i) := (others=>'0');
        end loop;
        result(15) := X"00000030";
        return result;
    end init_banc;

    signal registers : table := init_banc;

begin

    A <= registers(to_integer(unsigned(ra)));
    B <= registers(to_integer(unsigned(rb)));
    process (clk, rst)
    begin
        if rst = '1' then
            registers <= init_banc;
        elsif rising_edge(clk) then
            if we = '1' and unsigned(rw) < 16 then
                registers(to_integer(UNSIGNED(rw))) <= w;
            end if;
        end if;
    end process;

end architecture rtl;

