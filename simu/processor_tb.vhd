library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity processor_tb is
end entity processor_tb;

architecture testbench of processor_tb is

    type table64x32 is array(63 downto 0) of std_logic_vector(31 downto 0);
    type table16x32 is array(15 downto 0) of std_logic_vector(31 downto 0);
    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT, BX, UNSUPPORTED_INSTR);
    signal decoder_curr_instr: enum_instruction;
    signal clk, IRQ0, IRQ1      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal Done : boolean := false;
    signal displayData : std_logic_vector(31 downto 0);-- := (others => '0');
    signal data_mem_MemWr, decoder_MemWr : std_logic ; -- := '0';
    signal decoder_rd, decoder_rn, decoder_rm : std_logic_vector(3 downto 0) := (others => '0');
    signal alu_op : std_logic_vector(2 downto 0) := (others => '0');
    signal data_mem_registers: table64x32;
    signal reg_bench_registers: table16x32;
    signal decoder_instr, alu_out, alu_a, alu_b: std_logic_vector(31 downto 0);
    constant Period : time := 10 us;
begin
    clk <= '0' when Done else not CLK after Period / 2;
    process
    begin
        init_signal_spy("/processor_tb/processor/decoder/memwr", "decoder_MemWr");
        init_signal_spy("/processor_tb/processor/decoder/instruction", "decoder_instr");
        init_signal_spy("/processor_tb/processor/decoder/curr_instr", "decoder_curr_instr");
        init_signal_spy("/processor_tb/processor/decoder/rd", "decoder_rd");
        init_signal_spy("/processor_tb/processor/decoder/rn", "decoder_rn");
        init_signal_spy("/processor_tb/processor/decoder/rm", "decoder_rm");
        init_signal_spy("/processor_tb/processor/pu/register_bench/registers", "reg_bench_registers");
        init_signal_spy("/processor_tb/processor/pu/data_memory/wren", "data_mem_MemWr");
        init_signal_spy("/processor_tb/processor/pu/data_memory/registers", "data_mem_registers");
        init_signal_spy("/processor_tb/processor/pu/alu/S", "alu_out");
        init_signal_spy("/processor_tb/processor/pu/alu/A", "alu_a");
        init_signal_spy("/processor_tb/processor/pu/alu/B", "alu_b");
        init_signal_spy("/processor_tb/processor/pu/alu/op", "alu_op");
        rst <= '0';
        for curr_instruction in 0 to 5 loop
            wait for Period;
        end loop;
        IRQ0 <= '1';
        wait for Period;
        IRQ0 <= '0';
        for curr_instruction in 0 to 23 loop
            wait for Period;
        end loop;
    done <= true;
    wait;
end process;
processor : entity work.processor
port map(
            clk => clk,
            rst => rst,
            IRQ0 => IRQ0,
            IRQ1 => IRQ1,
            displayData => displayData
        );

end architecture testbench;