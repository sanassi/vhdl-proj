library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity seven_seg is
port (
        data   : in  std_logic_vector(3 downto 0);
        Pol    : in  std_logic;
        Segout : out std_logic_vector(1 to 7)
     );
end entity seven_seg;

--       A=Seg(1)
--      -----
--    F|     |B=Seg(2)
--     |  G  |
--      -----
--     |     |C=Seg(3)
--    E|     |
--      -----
--        D=Seg(4)

architecture rtl of seven_seg is
    signal sevseg : std_logic_vector(1 to 7);
begin
process(Data, Pol)
begin
    case(Data) is
        when x"0" => sevseg <= "1111110";
        when x"1" => sevseg <= "0110000";
        when x"2" => sevseg <= "1101101";
        when x"3" => sevseg <= "1111001";
        when x"4" => sevseg <= "0110011";
        when x"5" => sevseg <= "1011011";
        when x"6" => sevseg <= "1011111";
        when x"7" => sevseg <= "1110000";
        when x"8" => sevseg <= "1111111";
        when x"9" => sevseg <= "1111011";

        when x"a" => sevseg <= "1110111";
        when x"b" => sevseg <= "0011111";
        when x"c" => sevseg <= "1001110";
        when x"d" => sevseg <= "0111101";
        when x"e" => sevseg <= "1001111";
        when x"f" => sevseg <= "1000111";
        when others => sevseg <= (others => '-');
    end case;
    if (Pol='1') then
        Segout <= sevseg;
    else
        Segout <= not(sevseg);
    end if;
end process;

end architecture rtl;

