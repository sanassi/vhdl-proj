library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    port (
            OP : in std_logic_vector(2 downto 0);
            A  : in std_logic_vector(31 downto 0);
            B  : in std_logic_vector(31 downto 0);
            S  : out std_logic_vector(31 downto 0);
            N  : out std_logic;
            Z  : out std_logic;
            C  : out std_logic;
            V  : out std_logic
        );
end entity alu;

architecture rtl of alu is
begin
    process(OP, A, B)
        variable tmp_res : std_logic_vector(31 downto 0) := (others => '0');
        variable carry_res : std_logic_vector(S'length downto 0); -- result with carry
    begin
        Z <= '0';
        N <= '0';
        C <= '0';
        V <= '0';
        carry_res := (others => '0');

        case OP is
            when "000" => -- op +
                tmp_res := std_logic_vector(signed(A) + signed(B));
                carry_res := std_logic_vector(signed(('0' & A)) + signed(B)); -- adding a carry bit with 0 as default value
                C <= carry_res(carry_res'left);
                if signed(A) > 0 and signed(B) > 0 and signed(tmp_res) < 0 then -- adding two positives should be positive
                    V <= '1';
                elsif signed(A) < 0 and signed(B) < 0 and signed(tmp_res) > 0 then -- adding two negatives should be negative
                    V <= '1';
                end if;

            when "001" => tmp_res := B;
            when "010" => -- op -
                tmp_res := std_logic_vector(signed(A) - signed(B));
                carry_res := std_logic_vector(signed(('0' & A)) + signed(not B) + 1); -- adding a carry bit with 0 as default value
                C <= carry_res(carry_res'left);
                if signed(A) > 0 and signed(B) < 0 and signed(tmp_res) < 0 then --subtract negative is same as adding a positive
                    V <= '1';
                elsif signed(A) < 0 and signed(B) > 0 and signed(tmp_res) > 0 then -- subtract positive is same as adding a negative
                    V <= '1';
                end if;

            when "011" => tmp_res := A;
            when "100" => tmp_res := A or B;
            when "101" => tmp_res := A and B;
            when "110" => tmp_res := A xor B;
            when "111" => tmp_res := not A;
            when others => tmp_res := (others => 'X');
        end case;

        if signed(tmp_res) = 0 then
            Z <= '1';
        elsif signed(tmp_res) < 0 then
            N <= '1';
        end if;
        S <= tmp_res;
    end process;
end architecture rtl;
