library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg_bench is
    port (  clk : in std_logic;
            rst : in std_logic;
            w   : in std_logic_vector(31 downto 0);
            ra  : in std_logic_vector(3 downto 0);
            rb  : in std_logic_vector(3 downto 0);
            rw  : in std_logic_vector(3 downto 0);
            we  : in std_logic;
            a   : out std_logic_vector(31 downto 0);
            b   : out std_logic_vector(31 downto 0)
        );
end entity reg_bench;

architecture rtl of reg_bench is
-- Declaration Type Tableau Memoire
    type table is array(15 downto 0) of std_logic_vector(31 downto 0);
-- Fonction d'Initialisation du Banc de Registres
    function init_banc return table is
        variable result : table;
    begin
        for i in 14 downto 0 loop
            result(i) := (others=>'0');
        end loop;
        result(15):=X"00000030";
        return result;
    end init_banc;
-- Déclaration et Initialisation du Banc de Registres 16x32 bits
    signal bench: table:=init_banc;
begin
    a <= bench(to_integer(unsigned(ra)));
    b <= bench(to_integer(unsigned(rb)));
    process (rst, clk)
    begin
        if rst = '1' then
            a <= (others => '0');
            b <= (others => '0');
        elsif rising_edge(clk) then
            if we = '1' then
                if unsigned(rw) < 16 then
                    bench(to_integer(unsigned(rw))) <= w;
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
