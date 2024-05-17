library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity process_unit_tb is
end entity process_unit_tb;

architecture testbench of process_unit_tb is
    constant Period : time := 1 us; -- speed up simulation with a 100kHz clock

    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '1';
    signal Done : boolean := false;
    signal RegWr  :  std_logic := '0';

    signal ALUctr  :  std_logic_vector(2 downto 0) := (others => '0');
    signal rd, rn, rm  :  std_logic_vector(3 downto 0) :=  (others => '0');
    signal s   :  std_logic_vector(31 downto 0) :=  (others => '0');
procedure readRegister(constant reg_nb : in Std_logic_vector(3 downto 0);
                   signal write_enable : out Std_logic;
                   signal ALU_op : out Std_logic_vector(2 downto 0);
                   signal reg_rn : out Std_logic_vector(3 downto 0)) is
    begin
        write_enable <= '0';
        ALU_op <= "011";
        reg_rn <= reg_nb;
        wait for Period;
    end procedure;
begin

    CLK <= '0' when Done else not CLK after Period / 2;
--    RST <= '1', '0' after Period;
    
process
    begin
        wait for Period;
        -- R(1) = R(15) 
        rst <= '0';

        rn <= "1111"; -- 15 --std_logic_vector(to_unsigned(15, 4));
        rd <= "0001"; --std_logic_vector(to_unsigned(1, 4));
        rm <= "0000";
        regWr <= '1';
        ALUctr <= "011";
        wait for Period;
        assert (s = X"00000030") report "R(1) = R(15) failed "
        & "exp : 48  got : "  & integer'image(to_integer(SIGNED(s)))
        severity error;
        regWr <= '0';
        readRegister("0001", regWr, ALUctr, rn);
        assert (s = X"00000030") report "R(1) = R(15) failed, register content "
        & "does not match, exp : 48  got : "  & integer'image(to_integer(SIGNED(s)))
        severity error;

        rst <= '1';
        regWr <= '0';
        wait for Period;

        -- R(1) = R(1) + R(15)
        rst <= '0';
        rn <= "0001";
        rd <= "0001";
        rm <= "1111";
        regWr <= '1';
        ALUctr <= "000";
        wait for Period;
        assert (s = X"00000030") report "R(1) = R(1) + R(15) failed "
        & "exp : 48  got : "  & integer'image(to_integer(SIGNED(s)))
        severity error;
        readRegister("0001", regWr, ALUctr, rn);
        assert (s = X"00000030") report "R(1) = R(1) + R(15) failed, register content "
        & "does not match, exp : 48  got : "  & integer'image(to_integer(SIGNED(s)))
        severity error;

        wait for Period;

        -- R(2) = R(1) + R(15)
        -- R(3) = R(1) – R(15)
        -- R(5) = R(7) – R(15)

        done <= true;
        wait;

    end process;
PU : entity work.process_unit
    port map(
                clk => clk,
                rst => rst,
                rd  => rd,
                rn  => rn,
                rm  => rm,
                ALUctr  => ALUctr,
                RegWr  => RegWr,
                result => s
            );
end architecture testbench;
