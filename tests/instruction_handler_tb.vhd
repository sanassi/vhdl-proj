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
        result (0):=x"E3A01020"; -- 0x0 _main --    MOV R1,#0x20 -- R1 = 0x20
        result (1):=x"E3A02000"; -- 0x1 --          MOV R2,#0x00 -- R2 = 0
        result (2):=x"E6110000"; -- 0x2 _loop --    LDR R0,0(R1) -- R0 = DATAMEM[R1] = DATAMEM[0x20]
        result (3):=x"E0822000"; -- 0x3 --          ADD R2,R2,R0 -- R2 = R2 + R0
        result (4):=x"E2811001"; -- 0x4 --          ADD R1,R1,#1 -- R1 = R1 + 1
        result (5):=x"E351002A"; -- 0x5 --          CMP R1,0x2A -- Flag = R1-0x2A,si R1 < 0x2A
        result (6):=x"BAFFFFFB"; -- 0x6 --          BLT loop -- PC =PC+1+(-5) si N = 1
        result (7):=x"E6012000"; -- 0x7 --          STR R2,0(R1) -- DATAMEM[R1] = R2, R1 = 0x2A = 42
        result (8):=x"EAFFFFF7"; -- 0x8 --          BAL main -- PC=PC+1+(-9)
        -- ISR 0 : interruption 0
        --sauvegarde du contexte
        result (9 ) := x"E60F1000"; -- STR R1,0(R15) ; --MEM[R15] <= R1
        result (10) := x"E28FF001"; -- ADD R15,R15,1 ; --R15 <= R15 + 1
        result (11) := x"E60F3000"; -- STR R3,0(R15) ; --MEM[R15] <= R3
        --traitement
        result (12) := x"E3A03010"; -- MOV R3,0x10 ; --R3 <= 0x10
        result (13) := x"E6131000"; -- LDR R1,0(R3) ; --R1 <= MEM[R3]
        result (14) := x"E2811001"; -- ADD R1,R1,1 ; --R1 <= R1 + 1
        result (15) := x"E6031000"; -- STR R1,0(R3) ; --MEM[R3] <= R1
        -- restauration du contexte
        result (16) := x"E61F3000"; -- LDR R3,0(R15) ; --R3 <= MEM[R15]
        result (17) := x"E28FF0FF"; -- ADD R15,R15,-1 ; --R15 <= R15 - 1
        result (18) := x"E61F1000"; -- LDR R1,0(R15) ; --R1 <= MEM[R15]
        result (19) := x"EB000000"; -- BX ; -- instruction de fin d'interruption
        result (20) := x"00000000";
        -- ISR1 : interruption 1
        --sauvegarde du contexte - R15 correspond au pointeur de pile
        result (21) := x"E60F4000"; -- STR R4,0(R15) ; --MEM[R15] <= R4
        result (22) := x"E28FF001"; -- ADD R15,R15,1 ; --R15 <= R15 + 1
        result (23) := x"E60F5000"; -- STR R5,0(R15) ; --MEM[R15] <= R5
        --traitement
        result (24) := x"E3A05010"; -- MOV R5,0x10 ; --R5 <= 0x10
        result (25) := x"E6154000"; -- LDR R4,0(R5) ; --R4 <= MEM[R5]
        result (26) := x"E2844002"; -- ADD R4,R4,2 ; --R4 <= R1 + 2
        result (27) := x"E6054000"; -- STR R4,0(R5) ; --MEM[R5] <= R4
        -- restauration du contexte
        result (28) := x"E61F5000";-- LDR R5,0(R15) ; --R5 <= MEM[R15]
        result (29) := x"E28FF0FF"; -- ADD R15,R15,-1 ; --R15 <= R15 - 1
        result (30) := x"E61F4000"; -- LDR R4,0(R15) ; --R4 <= MEM[R15]
        result (31) := x"EB000000";-- BX ; -- instruction de fin d'interruption
        result (32) := x"00000001";
        result (33) := x"00000002";
        result (34) := x"00000003";
        result (35) := x"00000004";
        result (36) := x"00000005";
        result (37) := x"00000006";
        result (38) := x"00000007";
        result (39) := x"00000008";
        result (40) := x"00000009";
        result (41) := x"0000000A";
        result (42 to 63) := (others=> x"00000000");
        return result;
    end init_mem;
    procedure test_value(constant actual : in std_logic; constant exp : in std_logic;
                         constant sig_name : string) is
    begin
        assert (actual = exp) report
        "[FAIL] signal " & sig_name & " : expected :"
        & integer'image(to_integer(unsigned'('0' & exp))) & "  got : "
        & integer'image(to_integer(unsigned'('0' & actual))) severity error;
    end procedure;

    procedure check_instr(
            constant actual_instr : in std_logic_vector(31 downto 0);
            constant instr_list : in  RAM64x32;
            constant s_irq_serv : in std_logic;
            constant PC : in integer
        ) is
    variable exp_instr : std_logic_vector(31 downto 0);
    begin
        exp_instr := instr_list(PC);
        assert (actual_instr = exp_instr) report " with PC = "
        & integer'image(PC) & "     exp : "
        & integer'image(to_integer(signed(exp_instr))) & "  got : "
        & integer'image(to_integer(signed(actual_instr))) severity error;
        test_value(s_irq_serv, '0', "IRQ_SERV");
    end procedure;

    procedure test_interrupt(
            constant actual_instr : in std_logic_vector(31 downto 0);
            constant exp_IRQ_SERV : in std_logic;
            constant s_IRQ_SERV : in std_logic;
            constant instr_list : in  RAM64x32;
            constant PC : in integer
        ) is
    variable exp_instr : std_logic_vector(31 downto 0);
    begin
        exp_instr := instr_list(PC);
        assert (actual_instr = exp_instr) report "[INTERRUPT TEST] with PC = "
        & integer'image(PC) & " bad instruction,  exp : "
        & integer'image(to_integer(signed(exp_instr))) & "  got : "
        & integer'image(to_integer(signed(actual_instr))) severity error;
        test_value(s_IRQ_SERV, exp_IRQ_SERV, "IRQ_SERV");
    end procedure;

    signal exps_instr: RAM64x32 := init_mem;
    constant Period : time := 1 us; -- speed up simulation with a 100kHz clock

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal Done : boolean := false;
    signal nPCsel, IRQ, IRQ_END, IRQ_SERV : std_logic := '0';
    signal instruction, VICPC: std_logic_vector (31 downto 0) := (others => '0');
    signal imm24:  std_logic_vector (23 downto 0) := (others => '0');

begin
    clk <= '0' when Done else not CLK after Period / 2;
process
    begin

  wait for Period; -- PC = 0;
  rst <= '0';
  nPCsel <= '0';
  check_instr(instruction, exps_instr, IRQ_SERV,  0);
  wait for Period; -- PC = PC + 1 = 1
  check_instr(instruction, exps_instr, IRQ_SERV,  1);
  wait for Period; -- PC = PC + 1 = 2
  check_instr(instruction, exps_instr, IRQ_SERV,  2);
  wait for Period; -- PC = PC + 1 = 3
  check_instr(instruction, exps_instr, IRQ_SERV,  3);
  wait for Period; -- PC = PC + 1 = 4
  check_instr(instruction, exps_instr, IRQ_SERV,  4);
  wait for Period; -- PC = PC + 1 = 5
  check_instr(instruction, exps_instr, IRQ_SERV,  5);
  wait for Period; -- PC = PC + 1 = 6
  check_instr(instruction, exps_instr, IRQ_SERV,  6);
  wait for Period; -- PC = PC + 1 = 7
  check_instr(instruction, exps_instr, IRQ_SERV,  7);
  imm24 <= std_logic_vector(to_signed(-4, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + (-4)= 4
  check_instr(instruction, exps_instr, IRQ_SERV,  4);
  imm24 <= std_logic_vector(to_signed(-3, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + (-3)= 2
  check_instr(instruction, exps_instr, IRQ_SERV,  2);
  nPCsel <= '0';
  wait for Period; -- PC = PC + 1 = 3
  check_instr(instruction, exps_instr, IRQ_SERV,  3);
  imm24 <= std_logic_vector(to_signed(3, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + 3 = 7
  check_instr(instruction, exps_instr, IRQ_SERV,  7);
  imm24 <= std_logic_vector(to_signed(-8, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + (-8) = 0
  check_instr(instruction, exps_instr, IRQ_SERV,  0);
  imm24 <= std_logic_vector(to_signed(7, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + 8 = 8
  check_instr(instruction, exps_instr, IRQ_SERV,  8);
  imm24 <= std_logic_vector(to_signed(-8, 24));
  nPCsel <= '1';
  wait for Period; -- PC = PC + 1 + (-8) = 1
  check_instr(instruction, exps_instr, IRQ_SERV,  1);

  nPCsel <= '0';
  imm24 <= x"000000";

  --------------------
  --    INTERRUPT   --
  --------------------
  IRQ <= '1';
  VICPC <= x"00000009";
  wait for Period;
  test_interrupt(instruction, '1', IRQ_SERV, exps_instr, 9);
  VICPC <= x"000000A0";
  IRQ <= '0';
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 10);
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 11);
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 12);
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 13);
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 14);
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 15);
  IRQ_END <= '1';
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 2);
  IRQ_END <= '0';
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 3);
  IRQ <= '1';
  VICPC <= x"00000015";
  wait for Period;
  test_interrupt(instruction, '1', IRQ_SERV, exps_instr, 21);
  IRQ <= '0';
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 22);
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 23);
  IRQ <= '1';
  VICPC <= x"00000009";
  wait for Period;
  IRQ <= '0';
  test_interrupt(instruction, '1', IRQ_SERV, exps_instr, 9);
  wait for Period;
  test_interrupt(instruction, '0', IRQ_SERV, exps_instr, 10);

  wait for Period; --


  done <= true;
  wait;
    end process;
    instruction_handler : entity work.instruction_handler
    port map (
        clk => clk,
        rst => rst,
        nPCsel => nPCsel,
        IRQ => IRQ,
        IRQ_END => IRQ_END,
        VICPC => VICPC,
        IRQ_SERV => IRQ_SERV,
        instruction => instruction,
        imm24 => imm24
             );
end architecture testbench;
