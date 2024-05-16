library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity process_unit_tb is
end entity process_unit_tb;

architecture testbench of process_unit_tb is
    constant Period : time := 10 us; -- speed up simulation with a 100kHz clock

    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '1';
    signal TICK1MS  : std_logic := '0';
    signal Done : boolean;

    signal op  :  std_logic_vector(2 downto 0);
    signal we  :  std_logic;
    signal rw  :  std_logic_vector(3 downto 0);
    signal ra  :  std_logic_vector(3 downto 0);
    signal rb  :  std_logic_vector(3 downto 0);
    signal s   :  std_logic_vector(31 downto 0);

    component process_unit
        port (
            clk : in std_logic;
            rst : in std_logic;
            --key : in std_logic_vector(1 downto 0);
            op  : in std_logic_vector(2 downto 0);
            we  : in std_logic;
            rw  : in std_logic_vector(3 downto 0);
            ra  : in std_logic_vector(3 downto 0);
            rb  : in std_logic_vector(3 downto 0);               
            s   : out std_logic_vector(31 downto 0)
        );
    end component;
begin

    CLK <= '0' when Done else not CLK after Period / 2;
    RST <= '1', '0' after Period;
    Tick1ms <= '0' when Done else not Tick1ms after 1 ms - Period, Tick1ms after 1 ms;

    unit : process_unit
        port map(
            clk => clk,
            --key => key,
            rst => rst,
            op  => op,
            we  => we,
            rw  => rw,
            ra  => ra,
            rb  => rb,
            s => s
        );

    stimulus : process
    begin
        -- Load R(15) into A
        -- Write in R(1) the result
        we <= '1';
        ra <= std_logic_vector(to_unsigned(15, 4));
        rw <= std_logic_vector(to_unsigned(1, 4));
        op <= "011";
        wait for Period;
        assert (s = X"00000030") report "Test Case 1 failed" severity error;

        we <= '1';
        ra <= std_logic_vector(to_unsigned(1, 4));
        rb <= std_logic_vector(to_unsigned(15, 4));
        rw <= std_logic_vector(to_unsigned(1, 4));
        op <= "000";
        wait for Period;
        assert (s = X"00000060") report "Test Case 2 failed" severity error;

        done <= true;
        wait;

    end process;

end architecture testbench;
