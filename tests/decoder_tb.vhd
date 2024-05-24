library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder_tb is
end entity decoder_tb;

architecture testbench of decoder_tb is
    type RAM11x32 is array (0 to 10) of std_logic_vector (31 downto 0);
    function init_mem return RAM11x32 is
        variable result : RAM11x32;
    begin
        for i in 10 downto 0 loop
            result (i):=(others=>'0');
        end loop;
        result (0):=x"E3A01020"; -- MOV R1,#0x20 -- R1 = 0x20
        result (1):=x"E0822000"; -- ADD R2,R2,R0 -- R2 = R2 + R0
        result (2):=x"E2811001"; -- ADD R1,R1,#1 -- R1 = R1 + 1
        result (3):=x"E28FF0FF"; -- ADD R15,R15,-1
        result (4):=x"E351001A"; -- CMP R1,0x1A
        result (5):=x"E6012000"; -- STR R2,0(R1) -- DATAMEM[R1] = R2
        result (6):=x"E60F4000"; -- STR R4,0(R15)
        result (7):=x"E6110000"; -- LDR R0,0(R1) -- R0 = DATAMEM[R1]
        result (8):=x"E61F1000"; -- LDR R1,0(R15)
        result (9):=x"BAFFFFFB"; -- BLT loop -- PC =PC+1+(-5) si N = 1
        result(10):=x"EAFFFFF7"; -- BAL main -- PC=PC+1+(-9)
        return result;
    end init_mem;

    signal instr_list: RAM11x32 := init_mem;
    constant Period : time := 1 us; -- speed up simulation with a 100kHz clock


    signal done : boolean := false;
    signal instruction, CPSR  : std_logic_vector(31 downto 0) := (others => '0');
    signal rd, rn, rm :  std_logic_vector(3 downto 0) := (others => '0');
    signal imm8 :  std_logic_vector(7 downto 0):= (others => '0');
    signal PC_offset :  std_logic_vector(23 downto 0):= (others => '0');
    signal ALUCtr :  std_logic_vector(2 downto 0):= (others => '0');
    signal nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc : std_logic
    := '0';
    procedure test_value(constant actual : std_logic; constant exp : std_logic;
                         constant sig_name : string) is
    begin
        assert (actual = exp) report "[FAIL] signal " & sig_name & " : expected :"
        & integer'image(to_integer(unsigned'('0' & exp))) & "  got : "
        & integer'image(to_integer(unsigned'('0' & actual))) severity error;
    end procedure;

    procedure check_signals(
        constant exp_nPCsel : in std_logic ;
        constant exp_RegWr  : in std_logic ;
        constant exp_RegSel : in std_logic ;
        constant exp_ALUSrc : in std_logic ;
        constant exp_RegAff : in std_logic ;
        constant exp_MemWr : in std_logic ;
        constant exp_PSREn : in std_logic ;
        constant exp_WSrc : in std_logic ;
        constant exp_ALUCtr : in std_logic_vector(2 downto 0);

        constant s_nPCsel : in std_logic ;
        constant s_RegWr  : in std_logic ;
        constant s_RegSel : in std_logic ;
        constant s_ALUSrc : in std_logic ;
        constant s_RegAff : in std_logic ;
        constant s_MemWr : in std_logic ;
        constant s_PSREn : in std_logic ;
        constant s_WSrc : in std_logic ;
        constant s_ALUCtr : in std_logic_vector(2 downto 0)

                            ) is
    begin
        test_value(s_nPCsel, exp_nPCsel, "nPCsel");
        test_value(s_RegWr, exp_RegWr, "RegWr");
        test_value(s_RegSel, exp_RegSel, "RegSel");
        test_value(s_ALUSrc, exp_ALUSrc, "ALUSrc");
        test_value(s_RegAff, exp_RegAff, "RegAff");
        test_value(s_MemWr, exp_MemWr, "MemWr");
        test_value(s_PSREn, exp_PSREn, "PSREn");
        test_value(s_WSrc, exp_WSrc, "WSrc");

        assert (s_ALUCtr = exp_ALUCtr) report
        "[FAIL] ALU operator, expected : "
        & integer'image(to_integer(unsigned(exp_ALUCtr))) & "  got : "
        & integer'image(to_integer(unsigned(s_ALUCtr))) severity error;

    end procedure;

    procedure test_instr(
        constant exp_nPCsel : in std_logic ;
        constant exp_RegWr  : in std_logic ;
        constant exp_RegSel : in std_logic ;
        constant exp_ALUSrc : in std_logic ;
        constant exp_RegAff : in std_logic ;
        constant exp_MemWr : in std_logic ;
        constant exp_PSREn : in std_logic ;
        constant exp_WSrc : in std_logic ;
        constant instr_idx : in integer ;

        constant s_instr_list : in  RAM11x32;
        constant s_nPCsel : in std_logic ;
        constant s_RegWr  : in std_logic ;
        constant s_RegSel : in std_logic ;
        constant s_ALUSrc : in std_logic ;
        constant s_RegAff : in std_logic ;
        constant s_MemWr : in std_logic ;
        constant s_PSREn : in std_logic ;
        constant s_WSrc : in std_logic ;
        signal s_instruction : out std_logic_vector(31 downto 0)
                        ) is
    begin


    end procedure;
begin
    process begin

    wait for Period;

    ------------------------------
    -- TEST   :  MOV imm        --
    ------------------------------
    instruction <=  instr_list(0);
    wait for Period;
    check_signals(
        '0' ,  '1' ,  '0'  ,  '1'  ,  '0' ,   '0' ,  '0' , '0' , "001" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  ADDr           --
    ------------------------------
    instruction <=  instr_list(1);
    wait for Period;
    check_signals(
        '0' ,  '1' ,  '0'  ,  '0'  ,  '0' ,   '0' ,  '1' , '0' , "000" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  ADDi +         --
    ------------------------------
    instruction <=  instr_list(2);
    wait for Period;
    check_signals(
        '0' ,  '1' ,  '1'  ,  '1'  ,  '0' ,   '0' ,  '1' , '0' , "000" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  ADDi -         --
    ------------------------------
    instruction <=  instr_list(3);
    wait for Period;
    check_signals(
        '0' ,  '1' ,  '1'  ,  '1'  ,  '0' ,   '0' ,  '1' , '0' , "000" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  CMP            --
    ------------------------------
    instruction <=  instr_list(4);
    wait for Period;
    check_signals(
        '0' ,  '0' ,  '0'  ,  '1'  ,  '0' ,   '0' ,  '1' , '0' , "010" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  STR            --
    ------------------------------
    instruction <=  instr_list(5);
    wait for Period;
    check_signals(
        '0' ,  '0' ,  '1'  ,  '0'  ,  '1' ,   '1' ,  '0' , '1' , "011" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  STR            --
    ------------------------------
    instruction <=  instr_list(6);
    wait for Period;
    check_signals(
        '0' ,  '0' ,  '1'  ,  '0'  ,  '1' ,   '1' ,  '0' , '1' , "011" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  LDR            --
    ------------------------------
    instruction <=  instr_list(7);
    wait for Period;
    check_signals(
        '0' ,  '0' ,  '1'  ,  '0'  ,  '0' ,   '0' ,  '0' , '1' , "011" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  LDR            --
    ------------------------------
    instruction <=  instr_list(8);
    wait for Period;
    check_signals(
        '0' ,  '0' ,  '1'  ,  '0'  ,  '0' ,   '0' ,  '0' , '1' , "011" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  BLT            --
    ------------------------------
    instruction <=  instr_list(9);
    wait for Period;
    --  N = 0
    check_signals(
        '0' ,  '0' ,  '0'  ,  '0'  ,  '0' ,   '0' ,  '0' , '0' , "000" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    CPSR(31) <= '1';
    wait for Period;
    --  N = 1
    check_signals(
        '1' ,  '0' ,  '0'  ,  '0'  ,  '0' ,   '0' ,  '0' , '0' , "000" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );
    wait for Period;
    ------------------------------
    -- TEST   :  BAL            --
    ------------------------------
    instruction <=  instr_list(10);
    wait for Period;
    check_signals(
        '1' ,  '0' ,  '0'  ,  '0'  ,  '0' ,   '0' ,  '0' , '0' , "000" ,
      nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc, ALUCtr
    );

    done <= true;
    wait;
    end process;

    decoder : entity work.decoder
    port map (
        instruction => instruction,
        CPSR => CPSR,
        rd => rd,
        rn => rn,
        rm => rm,
        imm8 => imm8,
        PC_offset => PC_offset,
        ALUCtr => ALUCtr,
        nPCsel => nPCsel,
        RegWr => RegWr,
        RegSel => RegSel,
        ALUSrc => ALUSrc,
        RegAff => RegAff,
        MemWr => MemWr,
        PSREn => PSREn,
        WSrc => Wsrc
             );
end architecture testbench;
