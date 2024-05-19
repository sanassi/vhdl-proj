LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity instruction_handler is
    port (
            clk : in std_logic;
            rst : in std_logic;
            nPCsel : in std_logic;
            instruction: out std_logic_vector (31 downto 0);
            offset: in std_logic_vector (23 downto 0)
         );
end entity;

architecture rtl of instruction_handler is
    signal PC : std_logic_vector(31 downto 0) := (others => '0');
    signal ext_pc : std_logic_vector(31 downto 0) := (others => '0');
    signal inc_pc : std_logic_vector(31 downto 0) := (others => '0');
begin

    inst_memory : entity work.instruction_memory
    port map (
                PC => PC,
                instruction => instruction
             );

    mux_21 : entity work.multiplexer_2_to_1
    port map (
                A => inc_pc,
                B => ext_pc,
                COM => nPCsel,
                S => PC
             );

    pc_extender : entity work.sign_extension
    port map (
                E => offset,
                S => ext_pc
             );

end architecture;
