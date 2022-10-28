library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    port (
        i_clk : in std_logic;
        i_rx : in std_logic;
        o_data : out std_logic_vector(7 downto 0);
        o_valid : out std_logic
    );
end entity uart_rx;

architecture rtl of uart_rx is

    type t_state is (s_idle, s_start, s_data, s_stop);
    signal r_state : t_state := s_idle;
    signal r_bit : integer range 0 to 7 := 0;
    signal r_data : std_logic_vector(7 downto 0) := (others => '0');
    signal r_valid : std_logic := '0';
    signal r_cnt : integer range 0 to 7 := 0;

begin

    o_data <= r_data;
    o_valid <= r_valid;

    p_rx : process (i_clk)
    begin
        if rising_edge(i_clk) then
            case r_state is
                when s_idle =>
                    r_valid <= '0';
                    if i_rx = '0' then
                        r_state <= s_start;
                        r_cnt <= 0;
                    end if;
                when s_start =>
                    if r_cnt = 3 then
                        if i_rx = '0' then
                            r_state <= s_data;
                            r_bit <= 0;
                            r_cnt <= 0;
                        else
                            r_state <= s_idle;
                        end if;
                    else
                        r_cnt <= r_cnt + 1;
                    end if;
                when s_data =>
                    if r_cnt = 7 then
                        r_data(r_bit) <= i_rx;
                        r_bit <= r_bit + 1;
                        r_cnt <= 0;
                        if r_bit = 7 then
                            r_state <= s_stop;
                        end if;
                    else
                        r_cnt <= r_cnt + 1;
                    end if;
                when s_stop =>
                    if r_cnt = 7 then
                        if i_rx = '1' then
                            r_valid <= '1';
                        end if;
                        r_state <= s_idle;
                    else
                        r_cnt <= r_cnt + 1;
                    end if;
            end case;
        end if;
    end process p_rx;

end architecture rtl;
