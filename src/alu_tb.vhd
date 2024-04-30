library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture testbench of alu_tb is
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal test_done : boolean := false;

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
        wait for CLK_PERIOD;
        assert (S = "00000000000000000000000000010001" and N = '0' and Z = '0' and C = '0' and V = '0')
            report "Test Case 1 failed" severity error;

        -- Test case 2
        OP <= "001";  -- Pass B
        A  <= "00000000000000000000000000001100";  -- 12
        B  <= "00000000000000000000000000000101";  -- 5
        wait for CLK_PERIOD;
        assert (S = "00000000000000000000000000000101" and N = '0' and Z = '0' and C = '0' and V = '0')
            report "Test Case 2 failed" severity error;

        -- Add more test cases here...

        test_done <= true;
    end process;

    clk_process : process
    begin
        while not test_done loop
            clk <= not clk;
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

end architecture testbench;

