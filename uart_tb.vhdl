library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end uart_tb;

architecture tb of uart_tb is

    component uart_tx
        generic (
            c_clk_div : positive
        );
        port (
            i_clk : in std_logic;
            i_data : in std_logic_vector(7 downto 0);
            i_write : in std_logic;
            o_ready : out std_logic;
            o_tx : out std_logic
        );
    end component uart_tx;

    component uart_rx
        generic (
            c_clk_div : positive
        );
        port (
            i_clk : in std_logic;
            i_rx : in std_logic;
            o_data : out std_logic_vector(7 downto 0);
            o_valid : out std_logic
        );
    end component uart_rx;

    signal r_clk : std_logic := '0';
    signal r_tx_clk : std_logic := '0';
    signal r_txrx : std_logic;
    
    signal r_tx_write : std_logic := '0';
    signal r_tx_ready : std_logic;
    signal r_tx_data : std_logic_vector(7 downto 0) := (others => '1');
    
    signal r_rx_valid : std_logic;
    signal r_rx_data_buf : std_logic_vector(7 downto 0);
    signal r_rx_data : std_logic_vector(7 downto 0);

begin

    r_clk <= not r_clk after 2.855445906432749 ns;
    r_tx_clk <= not r_tx_clk after 40 ns;

    uart_tx_inst : uart_tx
        generic map (
            c_clk_div => 1
        )
        port map (
            i_clk => r_tx_clk,
            i_data => r_tx_data,
            i_write => r_tx_write,
            o_ready => r_tx_ready,
            o_tx => r_txrx
        );

    uart_rx_inst : uart_rx
        generic map (
            c_clk_div => 14
        )
        port map (
            i_clk => r_clk,
            i_rx => r_txrx,
            o_data => r_rx_data_buf,
            o_valid => r_rx_valid
        );

    p_tx : process (r_tx_clk)
    begin
        if rising_edge(r_tx_clk) then
            if r_tx_ready = '1' and r_tx_write = '0' then
                r_tx_data <= std_logic_vector(unsigned(r_tx_data) + 1);
                r_tx_write <= '1';
            else
                r_tx_write <= '0';
            end if;
        end if;
    end process p_tx;

    p_rx : process (r_clk)
    begin
        if rising_edge(r_clk) then
            if r_rx_valid = '1' then
                r_rx_data <= r_rx_data_buf;
            end if;
        end if;
    end process p_rx;

end architecture tb;
