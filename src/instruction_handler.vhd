LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity instruction_handler is
    port (
            clk : in std_logic;
            rst : in std_logic;
            nPCsel : in std_logic;
            instruction: out std_logic_vector (31 downto 0);
            imm24: in std_logic_vector (23 downto 0)
         );
end entity;

architecture rtl of instruction_handler is
    signal PC, imm32, one, to_add, sign_ext_PC : std_logic_vector(31 downto 0) := (others => '0');
begin
    process (rst, clk)
    begin
        if rst = '1' then
            PC <= (others => '0') ;
            to_add <= (others => '0');
            sign_ext_PC <= (others => '0');
        elsif rising_edge(clk) then
            PC <= std_logic_vector(signed(PC) + signed(to_add));
        end if;
    end process;


    inst_memory : entity work.instruction_memory
    port map (
                PC => PC,
                instruction => instruction
             );

    mux_21 : entity work.multiplexer_2_to_1
    port map (
                A => one,
                B => sign_ext_PC,
                COM => nPCsel,
                S => to_add
             );

    pc_extender : entity work.sign_extension
    generic map (
                    N => 24
                )
    port map (
                E => imm24,
                S => imm32
             );
    one <= std_logic_vector(to_signed(1,32));
    sign_ext_PC <= std_logic_vector(to_signed(1, 32) + signed(imm32));

end architecture;
