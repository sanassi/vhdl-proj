library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor_tb is
end entity processor_tb;

architecture testbench of processor_tb is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal Done : boolean := false;
    signal displayData : std_logic_vector(31 downto 0) := (others => '0');
    constant Period : time := 1 us; -- speed up simulation with a 100kHz clock
begin
    clk <= '0' when Done else not CLK after Period / 2;
    process
    begin
        rst <= '0';
        for curr_instruction in 0 to 128 loop -- 7 it de trop
            wait for Period;
        end loop;
    done <= true;
    wait;
end process;
processor : entity work.processor
port map(
            clk => clk,
            rst => rst,
            displayData => displayData
        );

end architecture testbench;
