library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity process_unit_tb is
end entity process_unit_tb;

architecture testbench of process_unit_tb is
    constant Period : time := 1 us;

    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '1';
    signal Done : boolean := false;
    signal RegWr, Wsrc, ALUsrc, MemWr  :  std_logic := '0';
    signal imm8  :  std_logic_vector(7 downto 0) := (others => '0');

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

procedure registers_test(
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

procedure imm_value_test(
                  constant test_name : in string;
                  constant exp_value : in std_logic_vector(31 downto 0);
                  constant opVal  : in  std_logic_vector(2 downto 0);
                  constant dst : in std_logic_vector(3 downto 0);
                  constant srcN : in  std_logic_vector(3 downto 0);
                  constant imm8Value : in  std_logic_vector(7 downto 0);
                  signal s_clk      : out std_logic;
                  signal s_rst      : out std_logic;
                  signal s_ALUsrc      : out std_logic;
                  signal s_imm8 : out  std_logic_vector(7 downto 0);
                  signal r_RegWr : out std_logic;
                  signal ALU_op  : out  std_logic_vector(2 downto 0);
                  signal r_rd  :  out std_logic_vector(3 downto 0);
                  signal r_rn  :  out std_logic_vector(3 downto 0)
) is
begin
        s_rst <= '0';
        s_clk <= '0';
        r_rn <= srcN;
        r_rd <= dst;
        ALU_op <= opVal;
        s_imm8 <= imm8Value;
        s_ALUsrc <= '1'; -- ALU src is imm8
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
        s_ALUsrc <= '0';
        wait for Period;

end procedure;

procedure memory_write_test(
                  constant test_name : in string;
                  constant exp_value : in std_logic_vector(31 downto 0);
                  constant addr_exp_value : in std_logic_vector(31 downto 0);
                  constant opVal  : in  std_logic_vector(2 downto 0);
                  constant dst : in std_logic_vector(3 downto 0);
                  constant srcN : in  std_logic_vector(3 downto 0);
                  constant srcM : in  std_logic_vector(3 downto 0);
                  constant imm8Value : in  std_logic_vector(7 downto 0);
                  constant ALUsrc_val : in  std_logic;
                  signal s_clk      : out std_logic;
                  signal s_rst      : out std_logic;
                  signal s_ALUsrc      : out std_logic;
                  signal s_MemWr      : out std_logic;
                  signal s_Wsrc     : out std_logic;
                  signal s_imm8 : out  std_logic_vector(7 downto 0);
                  signal ALU_op  : out  std_logic_vector(2 downto 0);
                  signal r_rd  :  out std_logic_vector(3 downto 0);
                  signal r_rn  :  out std_logic_vector(3 downto 0);
                  signal r_rm  :  out std_logic_vector(3 downto 0)
) is
begin
        -- WRITE REGISTER VALUE IN DATA MEMORY
        s_rst <= '0';
        s_MemWr <= '1'; -- store in Data Memory register
        r_rn <= srcN;
        r_rd <= dst;
        r_rm <= srcM;
        ALU_op <= opVal;
        s_imm8 <= imm8Value;
        s_ALUsrc <= ALUsrc_val; -- use imm8 or register value
        s_Wsrc <= '0';
        -- the output of the ALU represent the address of data memory register
        wait for Period;
        s_clk <= '1';
        wait for Period;
        assert (s = addr_exp_value) report test_name &
        " failed, address value did not match : "
        & integer'image(to_integer(signed(addr_exp_value)))
        & " got : "  & integer'image(to_integer(signed(s))) severity error;

        wait for Period;
        s_clk <= '0';
        s_MemWr <= '0'; -- only reading
        s_Wsrc <= '1'; -- W / s is now DataOut of DataMemory entity

        wait for Period;
        assert (s = exp_value) report test_name & " failed, data mem "
        & "register value does not match : "
        & integer'image(to_integer(signed(exp_value)))
        & " got : "  & integer'image(to_integer(signed(s))) severity error;

        wait for Period;
        s_clk <= '0';
        s_rst <= '1';
        s_ALUsrc <= '0';
        s_Wsrc <= '0';
        s_ALUsrc <= '0';
        wait for Period;

end procedure;



begin

process
    begin
        -- first reset
        wait for Period;
        -- can begin testing

      -- R(1) = R(15), copie d'une valeur d'un registre à un autre
      registers_test("R(1) = R(15)", X"00000030", "011", "0001", "1111", "0000", clk,
      rst, regWr, ALUctr, rd, rn, rm);
      -- R(1) = R(1) + R(15), addition de 2 registres
      registers_test("R(1) = R(1) + R(15)", X"00000030", "000", "0001", "0001", "1111",
      clk, rst, regWr, ALUctr, rd, rn, rm);
      -- R(2) = R(1) + R(15)
      registers_test("R(2) = R(1) + R(15)", X"00000030", "000", "0010", "0001", "1111",
      clk, rst, regWr, ALUctr, rd, rn, rm);
      -- R(3) = R(1) – R(15), soustraction de 2 registres
      registers_test("R(3) = R(1) - R(15)", X"FFFFFFD0", "010", "0010", "0001", "1111",
      clk, rst, regWr, ALUctr, rd, rn, rm);
      -- R(5) = R(7) – R(15)
      registers_test("R(5) = R(7) - R(15)", X"FFFFFFD0", "010", "0101", "0111", "1111",
      clk, rst, regWr, ALUctr, rd, rn, rm);

      -- R(5) = R(5) + 8
      imm_value_test("R(5) = R(5) + 8", X"00000008", "000", "0101", "0101",
      "00001000", clk, rst, ALUsrc, imm8, regWr, ALUctr, rd, rn);
      -- addition de R(15) avec une valeur immediate
      imm_value_test("R(5) = R(5) + (-123)", X"ffffff85", "000", "0101", "0101",
      "10000101", clk, rst, ALUsrc, imm8, regWr, ALUctr, rd, rn);
      -- soustraction d'une valeur immediate à R(3)
      imm_value_test("R(3) = R(3) - 5", X"fffffffb", "010", "0011", "0101",
      "00000101", clk, rst, ALUsrc, imm8, regWr, ALUctr, rd, rn);

      -- R(7) = R(15) - 5
      imm_value_test("R(7) = R(15) - 5", X"0000002b", "010", "0101", "1111",
      "00000101", clk, rst, ALUsrc, imm8, regWr, ALUctr, rd, rn);
      -- ecriture d'un registre dans un mot de la memoire + lecture
      memory_write_test("Mem[R(2)] = R(15)", X"00000030", X"00000000",
      "011","0000", "0010", "1111", X"00", '0',
      clk, rst, ALUsrc, MemWr, Wsrc, imm8, ALUctr, rd, rn, rm );

      memory_write_test("Mem[R(0) + 5] = R(15)", X"00000030", X"00000005",
      "000","0000", "0000", "1111", X"05", '1',
      clk, rst, ALUsrc, MemWr, Wsrc, imm8, ALUctr, rd, rn, rm );

      memory_write_test("Mem[R(0) + 48] = R(15)", X"00000030", X"00000030",
      "000","0000", "0000", "1111", X"30", '1',
      clk, rst, ALUsrc, MemWr, Wsrc, imm8, ALUctr, rd, rn, rm );


      memory_write_test("Mem[R(15)] = R(15)", X"00000030", X"00000030",
      "011","0000", "1111", "1111", X"00", '0',
      clk, rst, ALUsrc, MemWr, Wsrc, imm8, ALUctr, rd, rn, rm );



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
                imm8 => imm8,
                RegWr  => RegWr,
                ALUctr  => ALUctr,
                ALUsrc => ALUsrc,
                Wsrc => Wsrc,
                MemWr => MemWr,
                result => s
            );
end architecture testbench;
