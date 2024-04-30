library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    port (  OP : in std_logic_vector(0 to 2);
            A  : in std_logic_vector(0 to 31);
            B  : in std_logic_vector(0 to 31);
            S  : out std_logic_vector(0 to 31);
            N  : out std_logic;
            Z  : out std_logic;
            C  : out std_logic;
            V  : out std_logic
         );
end entity alu;

architecture rtl of alu is
    signal temp_sum  : std_logic_vector(0 to 32) := (others => '0');
begin
    process(OP)
        variable tmp_res : std_logic_vector(0 to 31);
        variable carry   : std_logic;
    begin
        Z <= '0';
        N <= '0';
        C <= '0';
        V <= '0';

        case OP is
            when "000" => 
                        tmp_res := std_logic_vector(signed(A) + signed(B));
                        --temp_sum <= std_logic_vector(signed(A) + signed(B));
            when "001" => tmp_res := B;
            when "010" => tmp_res := std_logic_vector(signed(A) - signed(B));
            when "011" => tmp_res := A;
            when "100" => tmp_res := A or B;
            when "101" => tmp_res := A and B;
            when "110" => tmp_res := A xor B;
            when "111" => tmp_res := not A;
            when others => tmp_res := (others => 'X');
        end case;

        if signed(tmp_res) = 0 then
            Z <= '1';
        end if;
        if signed(tmp_res) < 0 then
            N <= '1';
        end if;
        if signed(A) < 0 and signed(B) < 0 then
            if signed(tmp_res) < 0 then
                V <= '0';
            else
                V <= '1';
            end if;
        elsif signed(A) > 0 and signed(B) > 0 then
            if signed(tmp_res) > 0 then
                V <= '0';
            else
                V <= '1';
            end if;
        end if;
         S <= tmp_res;
    end process;
    --C <= temp_sum(32);
end architecture rtl;
