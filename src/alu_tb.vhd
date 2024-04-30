library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture testbench of alu_tb is

    constant Period : time := 10 us; -- speed up simulation with a 100kHz clock

    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '1';
    signal TICK1MS  : std_logic := '0';
    signal Done : boolean;

    --constant CLK_PERIOD : time := 10 ns;

    signal OP        : std_logic_vector(0 to 2);
    signal A         : std_logic_vector(0 to 31);
    signal B         : std_logic_vector(0 to 31);
    signal S         : std_logic_vector(0 to 31);
    signal N         : std_logic;
    signal Z         : std_logic;
    signal C         : std_logic;
    signal V         : std_logic;

    component alu
        port (
            OP : in std_logic_vector(0 to 2);
            A  : in std_logic_vector(0 to 31);
            B  : in std_logic_vector(0 to 31);
            S  : out std_logic_vector(0 to 31);
            N  : out std_logic;
            Z  : out std_logic;
            C  : out std_logic;
            V  : out std_logic
        );
    end component;

begin
    CLK <= '0' when Done else not CLK after Period / 2;
    RST <= '1', '0' after Period;
    Tick1ms <= '0' when Done else not Tick1ms after 1 ms - Period, Tick1ms after 1 ms;

    -- Instantiate ALU
    uut : alu
        port map(
            OP => OP,
            A  => A,
            B  => B,
            S  => S,
            N  => N,
            Z  => Z,
            C  => C,
            V  => V
        );

    stimulus : process
    begin
        -- Test case 1
        OP <= "000";  -- Addition
        A  <= "00000000000000000000000000001100";  -- 12
        B  <= "00000000000000000000000000000101";  -- 5
        wait for Period;
        assert (S = "00000000000000000000000000010001" and N = '0' and Z = '0' and C = '0' and V = '0')
            report "Test Case 1 failed" severity error;

        -- Test case 2
        OP <= "001";  -- Pass B
        A  <= "00000000000000000000000000001100";  -- 12
        B  <= "00000000000000000000000000000101";  -- 5
        wait for Period;
        assert (S = "00000000000000000000000000000101" and N = '0' and Z = '0' and C = '0' and V = '0')
            report "Test Case 2 failed" severity error;

        -- Test case 3: 0 + 0
        OP <= "000";
        A  <= "00000000000000000000000000000000";  -- 0
        B  <= "00000000000000000000000000000000";  -- 0
        wait for Period;
        assert (S = "00000000000000000000000000000000" and N = '0' and Z = '1' and C = '0' and V = '0')
            report "Test Case 3 failed" severity error;

        -- Test case 4: 1 - 1
        OP <= "000";
        A  <= "00000000000000000000000000000000";  -- 0
        B  <= "00000000000000000000000000000000";  -- 0
        wait for Period;
        assert (S = "00000000000000000000000000000000" and N = '0' and Z = '1' and C = '0' and V = '0')
            report "Test Case 4 failed" severity error;

        -- Test case 5: 10 + 12
        OP <= "000";
        A  <= "00000000000000000000000000001010";  -- 10
        B  <= "00000000000000000000000000001100";  -- 12
        wait for Period;
        assert (S = "00000000000000000000000000010110" and N = '0' and Z = '0' and C = '0' and V = '0')
            report "Test Case 5 failed" severity error;

        report "End of test. Verify that no error was reported.";
        done <= true;
        wait;
    end process;
end architecture testbench;
