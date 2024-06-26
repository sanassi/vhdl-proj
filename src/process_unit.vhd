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
            Wsrc : in std_logic;
            MemWr : in std_logic;
            result, inputRegAff   : out std_logic_vector(31 downto 0);
            N,Z,C,V : out std_logic
         );
end entity;

architecture rtl of process_unit is
    signal W, ALU_A, ALU_B, ALU_out, reg_B, imm32, dataOut: std_logic_vector(31 downto 0) := (others => '0');
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
            B => reg_B
         );
    ALU : entity work.alu
port map (
                op => ALUctr,
                A => ALU_A,
                B => ALU_B,
                S => ALU_out,
                N => N,
                Z => Z,
                C => C,
                V => V
            );
    Extender : entity work.sign_extension
    port map(
        E => imm8,
        S => imm32
            );
    MUX1 : entity work.multiplexer_2_to_1
    generic map (N => 32)
    port map(
            A => reg_B,
            B => imm32,
            COM => ALUSrc,
            S => ALU_B
            );
    data_memory : entity work.data_memory
    port map (
        clk => clk,
        rst => rst,
        dataIn => reg_B,
        dataOut => dataOut,
        addr => ALU_out(5 downto 0),
        WrEn => MemWr
             );
    MUX2 : entity work.multiplexer_2_to_1
    generic map (N => 32)
    port map(
            A => ALU_out,
            B => dataOut,
            COM => Wsrc,
            S => W
            );
    result <= W;
    inputRegAff <= reg_B;
end architecture;
