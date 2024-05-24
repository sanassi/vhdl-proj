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
    signal PC, imm32 : std_logic_vector(31 downto 0) := (others => '0');
begin
    process (rst, clk)
    begin
        if rst = '1' then
            PC <= (others => '0') ;
        elsif rising_edge(clk) then
            if nPCsel = '0' then
                PC <= std_logic_vector(signed(PC) + to_signed(1, 32));
            else
                PC <= std_logic_vector(signed(PC) + to_signed(1, 32) +
                      signed(imm32));
            end if;
        end if;
    end process;

    inst_memory : entity work.instruction_memory
    port map (
                PC => PC,
                instruction => instruction
             );
    pc_extender : entity work.sign_extension
    generic map (
                    N => 24
                )
    port map (
                E => imm24,
                S => imm32
             );

end architecture;
