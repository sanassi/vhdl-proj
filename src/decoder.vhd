LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity decoder is
port(
       instruction, PSR  : in std_logic_vector(31 downto 0);
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
        signal s_rm : out std_logic_vector(3 downto 0)
        ) is 
    variable rot : std_logic_vector(3 downto 0) := (others => '0');
    variable value : std_logic_vector(7 downto 0) := (others => '0');
    begin
        if is_imm = '1' then
            rot := operand2(11 downto 8);
            s_imm8 <= operand2(7 downto 0) ; --ror to_integer(unsigned(rot));
        else -- do se neet to implement shift (not said in subect for this case)
            s_rm <= operand2(3 downto 0);
        end if;
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
    -- TODO when finished, refactor some code
    case(curr_instr) is
        when MOV =>
            rn <= instruction(19 downto 16);
            rd <= instruction(15 downto 12);
            handle_proc_instr_op2(instruction(25),instruction(11 downto 0),
            imm8, rm);
            RegWr <= '1';
            ALUCtr <= "001";
            if instruction(25) = '1' then -- if immediate value
                ALUsrc <= '1';
            end if;
        when ADDi =>  
            rn <= instruction(19 downto 16);
            rd <= instruction(15 downto 12);
            handle_proc_instr_op2('1',instruction(11 downto 0), imm8, rm);
            RegWr <= '1';
            ALUSrc <= '1';
            PSREn <= '1';
            RegSel <= '1';
        when ADDr =>  
            rn <= instruction(19 downto 16);
            rd <= instruction(15 downto 12);
            handle_proc_instr_op2('0',instruction(11 downto 0), imm8, rm);
            RegWr <= '1';
            PSREn <= '1';
        when CMP => 
            rn <= instruction(19 downto 16);
            rd <= instruction(15 downto 12);
            ALUSrc <= '1';
            ALUCtr <= "010";
            PSREn <= '1';
        when LDR =>  -- TODO finish
            -- TODO handle offset rm or 12 bit imm (but we only take 8bit ?)
            rn <= instruction(19 downto 16);
            rd <= instruction(15 downto 12);
            ALUCtr <= "011";
            Wsrc <= '1';
            RegSel <= '1';
        when STR => -- TODO finish
            -- TODO handle offset rm or 12 bit imm (but we only take 8bit ?)
            rn <= instruction(19 downto 16);
            rd <= instruction(15 downto 12);
            ALUCtr <= "011";
            MemWr <= '1';
            RegSel <= '1';
            Wsrc <= '1'; -- not necessary
        when BAL => -- TODO finish
            if instruction(24) = '1' then -- link
                -- r14 doit contenir l'adresse de retour : r14 <= PC - 4
            end if ;
            nPCsel <= '1';
        when BLT =>  -- TODO finish
            if instruction(24) = '1' then -- link
                -- r14 doit contenir l'adresse de retour : r14 <= PC - 4
            end if ;
            nPCsel <= '1';
        when others =>  -- UNSUPPORTED_INSTR
            -- What to do ?

    end case;
end process;

end architecture;


