library ieee;
use ieee.std_logic_1164.all;

entity clkdiv is
    generic (
        c_div : positive
    );
    port (
        i_clk : in std_logic;
        o_div : out std_logic
    );
end entity clkdiv;

architecture rtl of clkdiv is

    signal r_cnt : integer range 0 to c_div - 1 := 0;

begin

    o_div <= '1' when r_cnt = 0 else '0';

    p_div : process (i_clk)
    begin
        if rising_edge(i_clk) then
            if r_cnt = c_div - 1 then
                r_cnt <= 0;
            else
                r_cnt <= r_cnt + 1;
            end if;
        end if;
    end process p_div;
    
end architecture rtl;
