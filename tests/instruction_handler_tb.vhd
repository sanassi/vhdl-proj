library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_handler_tb is
end entity instruction_handler_tb;

architecture testbench of instruction_handler_tb is
    type RAM64x32 is array (0 to 63) of std_logic_vector (31 downto 0);
    function init_mem return RAM64x32 is
        variable result : RAM64x32;
    begin
        for i in 63 downto 0 loop
            result (i):=(others=>'0');
        end loop; -- PC -- INSTRUCTION -- COMMENTAIRE
        result (0):=x"E3A01020"; -- 0x0 _main -- MOV R1,#0x20 -- R1 = 0x20
        result (1):=x"E3A02000"; -- 0x1 -- MOV R2,#0x00 -- R2 = 0
        result (2):=x"E6110000"; -- 0x2 _loop -- LDR R0,0(R1) -- R0 = DATAMEM[R1]
        result (3):=x"E0822000"; -- 0x3 -- ADD R2,R2,R0 -- R2 = R2 + R0
        result (4):=x"E2811001"; -- 0x4 -- ADD R1,R1,#1 -- R1 = R1 + 1
        result (5):=x"E351002A"; -- 0x5 -- CMP R1,0x2A -- Flag = R1-0x2A,si R1 <= 0x2A
        result (6):=x"BAFFFFFB"; -- 0x6 -- BLT loop -- PC =PC+1+(-5) si N = 1
        result (7):=x"E6012000"; -- 0x7 -- STR R2,0(R1) -- DATAMEM[R1] = R2
        result (8):=x"EAFFFFF7"; -- 0x8 -- BAL main -- PC=PC+1+(-9)
        return result;
    end init_mem;

    procedure check_instr(
            constant actual_instr : in std_logic_vector(31 downto 0);
            constant instr_list : in  RAM64x32;
            constant PC : in integer
        ) is
    variable exp_instr : std_logic_vector(31 downto 0);
    begin
        exp_instr := instr_list(PC);
        assert (actual_instr = exp_instr) report " with PC = "
        & integer'image(PC) & "     exp : "
        & integer'image(to_integer(signed(exp_instr))) & "  got : "
        & integer'image(to_integer(signed(actual_instr))) severity error;
    end procedure;
    signal exps_instr: RAM64x32 := init_mem;
    constant Period : time := 1 us; -- speed up simulation with a 100kHz clock

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal Done : boolean := false;
    signal nPCsel : std_logic := '0';
    signal instruction: std_logic_vector (31 downto 0) := (others => '0');
    signal imm24:  std_logic_vector (23 downto 0) := (others => '0');

begin
    clk <= '0' when Done else not CLK after Period / 2;
    --rst <= '1', '0' after Period;
process
    begin
    
  wait for Period; -- PC = 0;
  rst <= '0';
  nPCsel <= '0';
  check_instr(instruction, exps_instr, 0);
  wait for Period; -- PC = PC + 1 = 1
  check_instr(instruction, exps_instr, 1);
  wait for Period; -- PC = PC + 1 = 2
  check_instr(instruction, exps_instr, 2);
  wait for Period; -- PC = PC + 1 = 3
  check_instr(instruction, exps_instr, 3);
  wait for Period; -- PC = PC + 1 = 4
  check_instr(instruction, exps_instr, 4);
  wait for Period; -- PC = PC + 1 = 5
  check_instr(instruction, exps_instr, 5);
  wait for Period; -- PC = PC + 1 = 6
  check_instr(instruction, exps_instr, 6);
  wait for Period; -- PC = PC + 1 = 7
  check_instr(instruction, exps_instr, 7);
  imm24 <= std_logic_vector(to_signed(-4, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + (-4)= 4
  check_instr(instruction, exps_instr, 4);
  imm24 <= std_logic_vector(to_signed(-3, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + (-3)= 2
  check_instr(instruction, exps_instr, 2);
  nPCsel <= '0';
  wait for Period; -- PC = PC + 1 = 3
  check_instr(instruction, exps_instr, 3);
  imm24 <= std_logic_vector(to_signed(3, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + 3 = 7
  check_instr(instruction, exps_instr, 7);
  imm24 <= std_logic_vector(to_signed(-8, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + (-8) = 0
  check_instr(instruction, exps_instr, 0);
  imm24 <= std_logic_vector(to_signed(7, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + 8 = 8
  check_instr(instruction, exps_instr, 8);


  done <= true;
  wait;
    end process;
    instruction_handler : entity work.instruction_handler
    port map (
        clk => clk,
        rst => rst,
        nPCsel => nPCsel,
        instruction => instruction,
        imm24 => imm24
             );
end architecture testbench;
