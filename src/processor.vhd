LIBRARY ieee;
use IEEE.numeric_std.all;
USE ieee.std_logic_1164.all;

entity processor is
port(
        clk : in std_logic;
        rst : in std_logic;
        displayData : out std_logic_vector(31 downto 0)
    );

end entity;

architecture rtl of processor is

    signal instruction, CPSR, inputPSR, result, inputRegAff  : std_logic_vector(31 downto 0) := (others => '0');
    signal rd, rn, rm, rb :  std_logic_vector(3 downto 0) := (others => '0');
    signal imm8 : std_logic_vector(7 downto 0):= (others => '0');
    signal imm24 : std_logic_vector(23 downto 0):= (others => '0');
    signal PC_offset :  std_logic_vector(23 downto 0):= (others => '0');
    signal ALUCtr :  std_logic_vector(2 downto 0):= (others => '0');
    signal nPCsel, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WSrc : std_logic
    := '0';
    signal N, Z, C, V : std_logic := '0';

begin

    inputPSR(31) <= N;
    inputPSR(30) <= Z;
    inputPSR(29) <= C;
    inputPSR(28) <= V;

    reg_PSR : entity work.psr
    port map(
        clk => clk,
        rst => rst,
        We => PSREn,
        dataIn => inputPSR,
        dataOut => CPSR
            );
    reg_Aff : entity work.psr
    port map(
        clk => clk,
        rst => rst,
        We => RegAff,
        dataIn => inputRegAff,
        dataOut => displayData
            );

    instruction_handler : entity work.instruction_handler
    port map (
        clk => clk,
        rst => rst,
        nPCsel => nPCsel,
        instruction => instruction,
        imm24 => imm24
             );

    decoder : entity work.decoder
    port map (
        instruction => instruction,
        CPSR => CPSR,
        rd => rd,
        rn => rn,
        rm => rm,
        imm8 => imm8,
        imm24 => imm24,
        ALUCtr => ALUCtr,
        nPCsel => nPCsel,
        RegWr => RegWr,
        RegSel => RegSel,
        ALUSrc => ALUSrc,
        RegAff => RegAff,
        MemWr => MemWr,
        PSREn => PSREn,
        WSrc => Wsrc
             );

MUX_reg : entity work.multiplexer_2_to_1
    generic map( N => 4)
    port map(
            A => rm,
            B => rd,
            COM => regSel,
            S => rb
            );

PU : entity work.process_unit
    port map(
                clk => clk,
                rst => rst,
                rd  => rd,
                rn  => rn,
                rm  => rb,
                imm8 => imm8,
                RegWr  => RegWr,
                ALUctr  => ALUctr,
                ALUsrc => ALUsrc,
                Wsrc => Wsrc,
                MemWr => MemWr,
                result => result,
                inputRegAff => inputRegAff,
                N => N,
                Z => Z,
                C => C,
                V => V
            );

end architecture;


