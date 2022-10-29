library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_tx_tb is
end i2s_tx_tb;

architecture tb of i2s_tx_tb is

    component i2s_tx is
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
    end component i2s_tx;

    signal r_clk : std_logic := '0';
    
    signal r_sck : std_logic;
    signal r_ws : std_logic;
    signal r_sd : std_logic;

    signal r_ready : std_logic;
    signal r_data : std_logic_vector(31 downto 0) := (others => '0');

begin

    r_clk <= not r_clk after 5.086263020833333 ns;

    i2s_inst : i2s_tx
        generic map (
            c_clk_div => 32
        )
        port map (
            i_clk => r_clk,

            i_valid => '1',
            o_ready => r_ready,
            i_data => r_data,

            o_sck => r_sck,
            o_ws => r_ws,
            o_sd => r_sd
        );

    process (r_clk) is
    begin
        if rising_edge(r_clk) then
            if r_ready = '1' then
                r_data <= std_logic_vector(unsigned(r_data) + 1);
            end if;
        end if;
    end process;

end architecture tb;
