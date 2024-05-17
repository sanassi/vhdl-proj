    LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity process_unit is
    port (  clk : in std_logic;
            rst : in std_logic;
            Rd  : in std_logic_vector(3 downto 0);
            Rn  : in std_logic_vector(3 downto 0);
            Rm  : in std_logic_vector(3 downto 0);
            RegWr : in std_logic;
            ALUctr : in std_logic_vector(2 downto 0);
            result   : out std_logic_vector(31 downto 0)
         );
end entity;

architecture rtl of process_unit is
    signal N, Z, C, V : std_logic := '0';
    signal W, A, B : std_logic_vector(31 downto 0) := (others => '0');
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
            A => A,
            B => B
         );
    ALU : entity work.alu
port map (
                op => ALUctr,
                A => A,
                B => B,
                S => W,
                N => N,
                Z => Z,
                C => C,
                V => V
            );
    result <= W;
end architecture;
