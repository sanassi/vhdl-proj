LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity instruction_handler is
    port (
            clk : in std_logic;
            rst : in std_logic;
            nPCsel, IRQ, IRQ_END : in std_logic;
            VICPC : in std_logic_vector (31 downto 0);
            imm24: in std_logic_vector (23 downto 0);
            IRQ_SERV : out std_logic; -- Acknowledgment of the interrupt
            instruction: out std_logic_vector (31 downto 0)
         );
end entity;

architecture rtl of instruction_handler is
    signal PC, imm32 : std_logic_vector(31 downto 0) := (others => '0');
begin
    process (rst, clk)
        variable LR : std_logic_vector(31 downto 0) := (others => '0');
    begin
        if rst = '1' then
            PC <= (others => '0') ;
            IRQ_SERV <= '0';
        elsif rising_edge(clk) then
            IRQ_SERV <= '0';
            if nPCsel = '0' then
                PC <= std_logic_vector(signed(PC) + to_signed(1, 32));
            else
                PC <= std_logic_vector(signed(PC) + to_signed(1, 32) +
                      signed(imm32));
            end if;
            if IRQ_END = '1' then
                PC <= std_logic_vector(signed(LR) + to_signed(1, 32));
            end if;
            if IRQ = '1'  then
                LR := PC;
                IRQ_SERV <= '1';
                PC <= VICPC;
            end if ;
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
