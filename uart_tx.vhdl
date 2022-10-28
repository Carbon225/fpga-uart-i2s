library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    port (
        i_clk : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        i_write : in std_logic;
        o_ready : out std_logic;
        o_tx : out std_logic
    );
end entity uart_tx;

architecture rtl of uart_tx is

    type t_state is (s_idle, s_data, s_stop);
    signal r_state : t_state := s_idle;
    signal r_bit : integer range 0 to 7 := 0;
    signal r_tx : std_logic := '1';
    signal r_data : std_logic_vector(7 downto 0) := (others => '0');

begin

    o_tx <= r_tx;
    o_ready <= '1' when r_state = s_idle else '0';

    p_tx : process (i_clk)
    begin
        if rising_edge(i_clk) then
            case r_state is
                when s_idle =>
                    if i_write = '1' then
                        r_data <= i_data;
                        r_state <= s_data;
                        r_bit <= 0;
                        -- start bit
                        r_tx <= '0';
                    else
                        -- idle
                        r_tx <= '1';
                    end if;
                when s_data =>
                    r_tx <= r_data(r_bit);
                    if r_bit = 7 then
                        r_state <= s_stop;
                    else
                        r_bit <= r_bit + 1;
                    end if;
                when s_stop =>
                    r_tx <= '1';
                    r_state <= s_idle;
            end case;
        end if;
    end process p_tx;

end architecture rtl;
