library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity instruction_memory is
    port(
            PC: in std_logic_vector (31 downto 0);
            Instruction: out std_logic_vector (31 downto 0)
        );
end entity;
architecture RTL of instruction_memory is
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
    signal mem: RAM64x32 := init_mem;
begin
    Instruction <= mem(to_integer(unsigned (PC)));
end architecture;
