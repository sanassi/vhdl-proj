library ieee;
use IEEE.numeric_std.all;
use ieee.std_logic_1164.all;

entity top_level is
port (
      CLOCK_50          :  in   std_logic;
      SW                : IN STD_LOGIC_VECTOR(9 downto 0);
      KEY               : in std_logic_vector(1 downto 0);
		HEX0 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX1 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX2 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX3 			:  OUT  STD_LOGIC_VECTOR(0 TO 6)
     );
end entity;

architecture rtl of top_level is
    signal pol : std_logic := '0';
    signal rst, IRQ0, IRQ1 : std_logic := '0';
    signal displayData : std_logic_vector(31 downto 0) := (others => '0');
begin

pol <= SW(9);
rst <= not SW(0);
IRQ0 <= not KEY(0);
IRQ1 <= not KEY(1);

  processor : entity work.processor
  port map(
      clk => CLOCK_50,
      rst => rst,
      IRQ0 => IRQ,
      IRQ1 => IRQ,
      displayData => displayData
  );

SEG0: entity work.seven_seg
    port map (Data => displayData(3 downto 0), pol => pol, Segout => HEX0);

SEG1: entity work.seven_seg
    port map (Data => displayData(7 downto 4), pol => pol, Segout => HEX1);

SEG2: entity work.seven_seg
    port map (Data => displayData(11 downto 8), pol => pol, Segout => HEX2);

SEG3: entity work.seven_seg
    port map (Data => displayData(15 downto 12), pol => pol, Segout => HEX3);

end architecture rtl;

