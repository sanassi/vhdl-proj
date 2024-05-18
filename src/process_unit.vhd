    LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity process_unit is
    port (  clk : in std_logic;
            rst : in std_logic;
            Rd  : in std_logic_vector(3 downto 0);
            Rn  : in std_logic_vector(3 downto 0);
            Rm  : in std_logic_vector(3 downto 0);
            imm8  : in std_logic_vector(7 downto 0);
            RegWr : in std_logic;
            ALUctr : in std_logic_vector(2 downto 0);
            ALUsrc : in std_logic;
            result   : out std_logic_vector(31 downto 0)
         );
end entity;

architecture rtl of process_unit is
    signal N, Z, C, V : std_logic := '0';
    signal W, ALU_A, ALU_B, rg_B, imm32 : std_logic_vector(31 downto 0) := (others => '0');
begin
    register_bench : entity work.reg_bench
port map (
            clk => clk,
            rst => rst,
            w => W,
            Ra => Rn,
            Rb => Rm,
            Rw => Rd,
            we => RegWr,
            A => ALU_A,
            B => rg_B
         );
    ALU : entity work.alu
port map (
                op => ALUctr,
                A => ALU_A,
                B => ALU_B,
                S => W,
                N => N,
                Z => Z,
                C => C,
                V => V
            );
    Extender : entity work.sign_extension
    -- generic map( N => 8) already 8 by default
    port map(
        E => imm8,
        S => imm32
            );
    MUX : entity work.multiplexer_2_to_1
    generic map (N => 32)
    port map(
            A => rg_B,
            B => imm32,
            COM => ALUSrc,
            S => ALU_B
            );
    result <= W;
end architecture;
