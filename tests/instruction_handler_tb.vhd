library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_handler_tb is
end entity instruction_handler_tb;

architecture testbench of instruction_handler_tb is
    constant Period : time := 1 us; -- speed up simulation with a 100kHz clock

    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '1';
    signal Done : boolean := false;

begin

    CLK <= '0' when Done else not CLK after Period / 2;
    RST <= '1', '0' after Period;
    Tick1ms <= '0' when Done else not Tick1ms after 1 ms - Period, Tick1ms after 1 ms;


    inst_handler : entity work.instruction_handler
    port map (

             );
end architecture testbench;
