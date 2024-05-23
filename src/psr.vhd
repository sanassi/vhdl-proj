LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity PSR is 
port(
        clk : in std_logic;
        rst : in std_logic;
        PSREn : in std_logic; -- Write Enable for the PSR
        dataIn : in std_logic_vector(31 downto 0);
        dataOut : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of PSR is
    signal reg : std_logic_vector(31 downto 0) := (others => '0');

begin
    dataOut <= reg; 
    process (rst, clk)
    begin
        if rst = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if PSREn = '1' then
                reg <= dataIn;
            end if;
        end if;
    end process;



end architecture;

