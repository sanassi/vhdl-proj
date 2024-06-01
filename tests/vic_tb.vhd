library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vic_tb is
end entity vic_tb;

architecture testbench of vic_tb is
    constant Period : time := 1 us; -- speed up simulation with a 100kHz clock
    signal done : boolean := false;
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal IRQ_SERV, IRQ1, IRQ0, irq : std_logic := '0';
    signal VICPC : std_logic_vector(31 downto 0); -- := (others => '0');

    procedure test_signal(constant actual : in std_logic; constant exp : in std_logic;
                         constant sig_name : string) is
    begin
        assert (actual = exp) report " [FAIL] "
        & sig_name & " : expected :"
        & integer'image(to_integer(unsigned'('0' & exp))) & "  got : "
        & integer'image(to_integer(unsigned'('0' & actual))) severity error;
    end procedure;
    procedure test_vector(constant actual : in std_logic_vector(31 downto 0);
                          constant exp : in std_logic_vector(31 downto 0);
                         constant sig_name : string) is
    begin
        assert (actual = exp) report " [FAIL] "
        & sig_name & " : expected :"
        & integer'image(to_integer(signed(exp))) & "  got : "
        & integer'image(to_integer(signed(actual))) severity error;
    end procedure;

begin
    clk <= '0' when Done else not CLK after Period / 2;
    process 
    begin
        wait for Period;
        rst <= '0';
        wait for Period;
       IRQ0 <= '0'; 
       IRQ1 <= '0';
       wait for Period;
       wait for Period;
       IRQ0 <= '1';
       wait for Period;
       test_vector(VICPC, x"00000009", "VICPC");
       test_signal(IRQ, '1', "IRQ");
       IRQ0 <= '0';
       wait for Period;
       test_vector(VICPC, x"00000009", "VICPC");
       test_signal(IRQ, '1', "IRQ");
       wait for Period;
       IRQ_SERV <= '1';
       wait for Period;
       test_vector(VICPC, x"00000000", "VICPC");
       test_signal(IRQ, '0', "IRQ");
       IRQ_SERV <= '0';
       wait for Period;
       IRQ1 <= '1';
       IRQ0 <= '1';
       wait for Period;
       IRQ1 <= '0';
       IRQ0 <= '0';
       wait for Period;
       test_vector(VICPC, x"00000009", "VICPC");
       test_signal(IRQ, '1', "IRQ");
       wait for Period;
       IRQ_SERV <= '1';
       wait for Period;
       test_vector(VICPC, x"00000000", "VICPC");
       test_signal(IRQ, '0', "IRQ");
       wait for Period;
       IRQ1 <= '1';
       wait for Period;
       test_vector(VICPC, x"00000015", "VICPC");
       test_signal(IRQ, '1', "IRQ");
       wait for Period;
       IRQ0 <= '1';
       IRQ_SERV <= '1';
       wait for Period;
       test_vector(VICPC, x"00000009", "VICPC");
       test_signal(IRQ, '1', "IRQ");
       wait for Period;
        done <= true;

        wait;

    end process;
    VIC : entity work.VIC
    port map (
            clk => clk,
            rst => rst,
            IRQ_SERV => IRQ_SERV,
            IRQ0 => irq0,
            IRQ1 => irq1,
            IRQ  => irq,
            VICPC => vicpc
             );
end architecture testbench;
