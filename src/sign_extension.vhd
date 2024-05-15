library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity sign_extension is
    generic(N : integer := 8);
    port (
    E : in std_logic_vector(N-1 downto 0);
    S : out std_logic_vector(31 downto 0)
         );
end entity;

architecture RTL of sign_extension is
begin
S <= std_logic_vector(resize(signed(E), E'length));
end architecture;
