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

procedure test(
                  constant test_name : in string;
                  constant exp_value : in std_logic_vector(31 downto 0);
                  constant opVal  : in  std_logic_vector(2 downto 0);
                  constant dst : in std_logic_vector(3 downto 0);
                  constant srcN : in  std_logic_vector(3 downto 0);
                  constant srcM : in std_logic_vector(3 downto 0);
                  signal s_clk      : out std_logic;
                  signal s_rst      : out std_logic;
                  signal r_RegWr : out std_logic;
                  signal ALU_op  : out  std_logic_vector(2 downto 0);
                  signal r_rd  :  out std_logic_vector(3 downto 0);
                  signal r_rn  :  out std_logic_vector(3 downto 0);
                  signal r_rm  :  out std_logic_vector(3 downto 0)
) is
begin
        s_rst <= '0';
        s_clk <= '0';
        r_rn <= srcN;
        r_rd <= dst;
        r_rm <= srcM;
        ALU_op <= opVal;
        wait for Period;
        assert (s = exp_value) report test_name & " failed "
        & "exp : " & integer'image(to_integer(signed(exp_value))) & "  got : "  & 
        integer'image(to_integer(signed(s))) severity error;
        wait for Period;
        r_regWr <= '1';
        s_clk <= '1';
        wait for Period;
        readRegister(dst, r_regWr, ALU_op, r_rn);
        assert (s = exp_value) report test_name & " failed, dst register content "
        & "does not match, exp : " & integer'image(to_integer(signed(exp_value)))
        & " got : "  & integer'image(to_integer(SIGNED(s))) severity error;
        wait for Period;
        -- r_regWr is already '0' thanks to readRegister
        s_clk <= '0';
        s_rst <= '1';
        wait for Period;

end procedure;
begin

process
    begin
        -- first reset
        wait for Period;
        -- can begin test

        -- R(1) = R(15)
        test("R(1) = R(15)", X"00000030", "011", "0001", "1111", "0000", clk, 
        rst, regWr, ALUctr, rd, rn, rm);
        -- R(1) = R(1) + R(15)
        test("R(1) = R(1) + R(15)", X"00000030", "000", "0001", "0001", "1111",
        clk, rst, regWr, ALUctr, rd, rn, rm);
        -- R(2) = R(1) + R(15)
        test("R(2) = R(1) + R(15)", X"00000030", "000", "0010", "0001", "1111",
        clk, rst, regWr, ALUctr, rd, rn, rm);
        -- R(3) = R(1) – R(15)
        test("R(3) = R(1) - R(15)", X"FFFFFFD0", "010", "0010", "0001", "1111",
        clk, rst, regWr, ALUctr, rd, rn, rm);
        -- R(5) = R(7) – R(15)
        test("R(5) = R(7) - R(15)", X"FFFFFFD0", "010", "0101", "0111", "1111",
        clk, rst, regWr, ALUctr, rd, rn, rm);

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
