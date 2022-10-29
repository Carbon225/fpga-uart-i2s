library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    generic (
        c_clk_div : positive
    );
    port (
        i_clk : in std_logic;
        o_tx : out std_logic;
        i_valid : in std_logic;
        o_ready : out std_logic;
        i_data : in std_logic_vector(7 downto 0)
    );
end entity uart_tx;

architecture rtl of uart_tx is

    component clkdiv
        generic (
            c_div : positive
        );
        port (
            i_clk : in std_logic;
            o_div : out std_logic
        );
    end component clkdiv;

    type t_state is (s_idle, s_data, s_stop);
    signal r_state : t_state := s_idle;
    
    signal r_clk_div : std_logic;

    signal r_fetch : std_logic := '0';
    signal r_ready : std_logic := '1';
    signal r_bit : integer range 0 to 7 := 0;
    signal r_tx : std_logic := '1';
    signal r_data : std_logic_vector(7 downto 0);

begin

    o_tx <= r_tx;
    o_ready <= r_ready;

    clkdiv_inst : clkdiv
        generic map (
            c_div => c_clk_div
        )
        port map (
            i_clk => i_clk,
            o_div => r_clk_div
        );

    p_tx : process (i_clk)
    begin
        if rising_edge(i_clk) then
            if r_ready = '1' and i_valid = '1' then
                r_fetch <= '1';
                r_data <= i_data;
                r_ready <= '0';
            end if;

            if r_clk_div = '1' then
                case r_state is
                    when s_idle =>
                        if r_fetch = '1' then
                            r_fetch <= '0';
                            r_state <= s_data;
                            r_bit <= 0;
                            -- start bit
                            r_tx <= '0';
                        end if;
                    when s_data =>
                        r_tx <= r_data(r_bit);
                        if r_bit = 7 then
                            r_state <= s_stop;
                            r_ready <= '1';
                        else
                            r_bit <= r_bit + 1;
                        end if;
                    when s_stop =>
                        r_tx <= '1';
                        r_state <= s_idle;
                end case;
            end if;
        end if;
    end process p_tx;

end architecture rtl;
