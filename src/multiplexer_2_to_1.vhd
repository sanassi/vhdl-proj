library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplexer_2_to_1 is
    generic(N : integer := 8);
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        COM : in std_logic;
        S : out std_logic_vector(N-1 downto 0)
         );
end entity;

architecture RTL of multiplexer_2_to_1 is
begin
S <= A when (COM='0') else
     B when (COM='1') else (others => '0'); -- X or 0 ?
end architecture;
