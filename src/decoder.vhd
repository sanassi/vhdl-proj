LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity decoder is
port(
       instruction, CPSR  : in std_logic_vector(31 downto 0);
       rd, rn, rm : out std_logic_vector(3 downto 0);
       imm8 : out std_logic_vector(7 downto 0);
       PC_offset : out std_logic_vector(23 downto 0);
       ALUCtr : out std_logic_vector(2 downto 0);
       nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc : out
       std_logic
    );

end entity;
architecture rtl of decoder is

type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT, UNSUPPORTED_INSTR);
signal curr_instr: enum_instruction;

procedure handle_proc_instr_op2(
        constant is_imm : in std_logic;
        constant operand2 : in std_logic_vector(11 downto 0);
        signal s_imm8 : out std_logic_vector(7 downto 0);
        signal s_rm : out std_logic_vector(3 downto 0);
        signal s_ALUsrc : out std_logic
        ) is 
    variable rot : std_logic_vector(3 downto 0) := (others => '0');
    variable value : std_logic_vector(7 downto 0) := (others => '0');
    begin
        if is_imm = '1' then
            rot := operand2(11 downto 8);
            s_imm8 <= operand2(7 downto 0) ; --ror to_integer(unsigned(rot));
            s_ALUsrc <= '1';
        else -- do se neet to implement shift (not said in subect for this case)
            s_rm <= operand2(3 downto 0);
            s_ALUsrc <= '0';
        end if;
    end procedure;
procedure set_rd_rn(
        constant s_instruction : in std_logic_vector(31 downto 0);
        signal s_rd : out std_logic_vector(3 downto 0);
        signal s_rn : out std_logic_vector(3 downto 0)
                   ) is
begin
            s_rn <= s_instruction(19 downto 16);
            s_rd <= s_instruction(15 downto 12);
end procedure;

begin

-- process sensible sur la sortie de la mémoire instructions : set curr_instr
process (instruction)
        variable opcode : std_logic_vector(3 downto 0) := (others => '0');
begin
    opcode := instruction(24 downto 21);
    if instruction(27 downto 26) = "00" then -- instr de traitement
        case(opcode) is
            when "1101" =>
                curr_instr <= MOV;
            when "0000" =>
                if instruction(25) = '1' then
                    curr_instr <= ADDi;
                else
                    curr_instr <= ADDr;
                end if;
            when "1010" => curr_instr <= CMP;
            when others => curr_instr <= UNSUPPORTED_INSTR;
        end case;
    elsif instruction(27 downto 26) = "01" then -- instr de transfert
        if instruction(20) = '1' then
            curr_instr <= LDR;
        else
            curr_instr <= STR;
        end if;
    elsif instruction(27 downto 25) = "101" then  -- instr de branchement
        if instruction(31 downto 28) = "1011" then -- LT / Less Than
            curr_instr <= BLT; -- branchement si N = 1 du CPSR
        elsif instruction(31 downto 28) = "1110" then -- AL / Always
            curr_instr <= BAL;
        else
            curr_instr <= UNSUPPORTED_INSTR;
        end if;
    else
        curr_instr <= UNSUPPORTED_INSTR;
    end if;
end process;

--  process sensible sur les signaux instructions et curr_instr qui donnera la
--    valeur des commandes des registres et opérateurs du processeur.
process (curr_instr)
begin
    rd <= (others => '0');
    rn <= (others => '0');
    rm <= (others => '0');
    PC_offset <= (others => '0');
    ALUCtr <= (others => '0');
    nPCsel <= '0';
    RegWr <= '0';
    RegSel <= '0';
    ALUSrc <= '0';
    RegAff <= '0';
    MemWr <= '0';
    PSREn <= '0';
    WSrc <= '0';
    case(curr_instr) is
        when MOV =>
            set_rd_rn(instruction, rd, rn);
            handle_proc_instr_op2(instruction(25),instruction(11 downto 0),
            imm8, rm, ALUSrc);
            RegWr <= '1';
            ALUCtr <= "001";
        when ADDi =>  
            set_rd_rn(instruction, rd, rn);
            handle_proc_instr_op2('1',instruction(11 downto 0), imm8, rm, ALUSrc);
            RegWr <= '1';
            ALUSrc <= '1';
            PSREn <= '1';
            RegSel <= '1';
        when ADDr =>  
            set_rd_rn(instruction, rd, rn);
            handle_proc_instr_op2('0',instruction(11 downto 0), imm8, rm, ALUSrc);
            RegWr <= '1';
            PSREn <= '1';
        when CMP => 
            set_rd_rn(instruction, rd, rn);
            ALUSrc <= '1';
            ALUCtr <= "010";
            PSREn <= '1';
        when LDR =>
            -- no need to handle offset ?
            set_rd_rn(instruction, rd, rn);
            ALUCtr <= "011";
            Wsrc <= '1';
            RegSel <= '1';
        when STR =>
            -- no need to handle offset ?
            set_rd_rn(instruction, rd, rn);
            ALUCtr <= "011";
            MemWr <= '1';
            RegSel <= '1';
            RegAff <= '1';
            Wsrc <= '1'; -- not necessary
        when BAL => -- L = 0
            nPCsel <= '1';
        when BLT =>  -- L = 0
            if CPSR(31) = '1' then
                nPCsel <= '1';
            end if;
        when others =>  -- UNSUPPORTED_INSTR
            -- What to do ?

    end case;
end process;

end architecture;


