library ieee;
use ieee.std_logic_1164.all;

entity uart_i2s is
    generic (
        c_uart_div : positive;
        c_i2s_div : positive
    );
    port (
        i_clk : in std_logic;
        
        i_rx : in std_logic;
        o_rts : out std_logic;

        o_sck : out std_logic;
        o_ws : out std_logic;
        o_sd : out std_logic
    );
end entity uart_i2s;

architecture rtl of uart_i2s is

    component uart_rx is
        generic (
            c_clk_div : positive
        );
        port (
            i_clk : in std_logic;
            i_rx : in std_logic;

            o_valid : out std_logic;
            i_ready : in std_logic;
            o_data : out std_logic_vector(7 downto 0)
        );
    end component uart_rx;

    component decoder is
        port (
            i_clk : in std_logic;

            i_valid : in std_logic;
            o_ready : out std_logic;
            i_data : in std_logic_vector(7 downto 0);

            o_valid : out std_logic;
            i_ready : in std_logic;
            o_data : out std_logic_vector(31 downto 0)
        );
    end component decoder;

    component fifo is
        generic (
            c_width : positive;
            c_depth : positive;
            c_thr : natural
        );
        port (
            i_clk : in std_logic;

            i_valid : in std_logic;
            o_ready : out std_logic;
            i_data : in std_logic_vector(c_width - 1 downto 0);

            o_valid : out std_logic;
            i_ready : in std_logic;
            o_data : out std_logic_vector(c_width - 1 downto 0);

            o_empty : out std_logic;
            o_thr : out std_logic;
            o_full : out std_logic
        );
    end component fifo;

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

    signal r_uart_valid : std_logic;
    signal r_uart_data : std_logic_vector(7 downto 0);

    signal r_decoder_ready : std_logic;
    signal r_decoder_valid : std_logic;
    signal r_decoder_data : std_logic_vector(31 downto 0);

    signal r_fifo_ready : std_logic;
    signal r_fifo_valid : std_logic;
    signal r_fifo_data : std_logic_vector(31 downto 0);

    signal r_fifo_thr : std_logic;

    signal r_i2s_ready : std_logic;

begin

    o_rts <= r_fifo_thr;

    uart_inst : uart_rx
        generic map (
            c_clk_div => c_uart_div
        )
        port map (
            i_clk => i_clk,
            i_rx => i_rx,

            o_valid => r_uart_valid,
            i_ready => r_decoder_ready,
            o_data => r_uart_data
        );

    decoder_inst : decoder
        port map (
            i_clk => i_clk,

            i_valid => r_uart_valid,
            o_ready => r_decoder_ready,
            i_data => r_uart_data,

            o_valid => r_decoder_valid,
            i_ready => r_fifo_ready,
            o_data => r_decoder_data
        );

    fifo_inst : fifo
        generic map (
            c_width => 32,
            c_depth => 16,
            c_thr => 8
        )
        port map (
            i_clk => i_clk,

            i_valid => r_decoder_valid,
            o_ready => r_fifo_ready,
            i_data => r_decoder_data,

            o_valid => r_fifo_valid,
            i_ready => r_i2s_ready,
            o_data => r_fifo_data,

            o_empty => open,
            o_thr => r_fifo_thr,
            o_full => open
        );

    i2s_inst : i2s_tx
        generic map (
            c_clk_div => c_i2s_div
        )
        port map (
            i_clk => i_clk,

            i_valid => r_fifo_valid,
            o_ready => r_i2s_ready,
            i_data => r_fifo_data,

            o_sck => o_sck,
            o_ws => o_ws,
            o_sd => o_sd
        );

end architecture rtl;
