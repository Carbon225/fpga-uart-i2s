library ieee;
use ieee.std_logic_1164.all;

entity i2s_tx is
    generic (
        c_clk_div : positive
    );
    port (
        i_clk : in std_logic;

        i_valid : in std_logic;
        o_ready : out std_logic;
        i_data : in std_logic_vector(31 downto 0);

        o_sck : out std_logic;
        o_ws : out std_logic;
        o_sd : out std_logic
    );
end entity i2s_tx;

architecture rtl of i2s_tx is

    component clkdiv
        generic (
            c_div : positive
        );
        port (
            i_clk : in std_logic;
            o_div : out std_logic
        );
    end component clkdiv;

    signal r_sck_div : std_logic;
    signal r_ws_div : std_logic;

    signal r_sck : std_logic := '1';
    signal r_ws : std_logic := '1';

    signal r_buf : std_logic_vector(31 downto 0) := (others => '0');
    signal r_loaded : std_logic := '0';
    signal r_reg : std_logic_vector(31 downto 0);

    signal r_ready : std_logic := '1';

begin

    clkdiv_sck : clkdiv
        generic map (
            c_div => c_clk_div
        )
        port map (
            i_clk => i_clk,
            o_div => r_sck_div
        );

    clkdiv_ws : clkdiv
        generic map (
            c_div => c_clk_div * 32
        )
        port map (
            i_clk => i_clk,
            o_div => r_ws_div
        );

    o_ready <= r_ready;
    o_sck <= r_sck;
    o_ws <= r_ws;
    o_sd <= r_reg(r_reg'high);

    p_i2s : process (i_clk) is
    begin
        if rising_edge(i_clk) then
            -- sck
            if r_sck_div = '1' then
                r_sck <= not r_sck;
            end if;

            -- ws
            if r_ws_div = '1' then
                r_ws <= not r_ws;
            end if;

            -- load data
            if i_valid = '1' and r_ready = '1' then
                r_buf <= i_data;
                r_ready <= '0';
            end if;

            -- delay data
            if r_ws_div = '1' and r_ws = '1' then
                r_loaded <= '1';
            end if;

            -- shift out data
            if r_sck_div = '1' and r_sck = '1' then
                if r_loaded = '1' then
                    r_loaded <= '0';
                    r_reg <= r_buf;
                    r_ready <= '1';
                else
                    r_reg <= r_reg(r_reg'high - 1 downto r_reg'low) & '0';
                end if;
            end if;
        end if;
    end process p_i2s;

end architecture rtl;
