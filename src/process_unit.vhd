LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity process_unit is
    port (  clk : in std_logic;
            rst : in std_logic;
            --key : in std_logic_vector(1 downto 0);
            op  : in std_logic_vector(2 downto 0);
            we  : in std_logic;
            rw  : in std_logic_vector(3 downto 0);
            ra  : in std_logic_vector(3 downto 0);
            rb  : in std_logic_vector(3 downto 0);
            s   : out std_logic_vector(31 downto 0)
         );
end entity;

architecture rtl of process_unit is
    --signal rst : std_logic;
    signal N, Z, C, V : std_logic;
    signal busW : std_logic_vector(31 downto 0);
    signal busA, busB : std_logic_vector(31 downto 0);
begin
    --rst <= not key(0);
    bench : entity work.reg_bench
    port map (
                clk => clk,
                rst => rst,
                w   => busW,
                ra  => ra,
                rb  => rb,
                rw  => rw,
                we  => we,
                a   => busA,
                b   => busB
             );

    alu : entity work.alu
    port map (
                op => op,
                a => busA,
                b => busB,
                s => busW,
                N => N,
                Z => Z,
                C => C,
                V => V
             );
    s <= busW;
end architecture;
