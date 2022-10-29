library ieee;
use ieee.std_logic_1164.all;

entity fifo is
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
end entity fifo;

architecture rtl of fifo is

    type t_mem is array(c_depth - 1 downto 0) of std_logic_vector(c_width - 1 downto 0);
    signal r_mem : t_mem := (others => (others => '0'));

    signal r_size : integer range 0 to c_depth := 0;

    signal r_ready : std_logic;
    signal r_valid : std_logic;

    signal r_read : std_logic;
    signal r_write : std_logic;

    signal r_empty : std_logic;
    signal r_thr : std_logic;
    signal r_full : std_logic;

    signal r_rd_head : integer range 0 to c_depth - 1 := 0;
    signal r_wr_head : integer range 0 to c_depth - 1 := 0;

begin

    r_empty <= '1' when r_size = 0 else '0';
    r_thr <= '1' when r_size >= c_thr else '0';
    r_full <= '1' when r_size = c_depth else '0';

    r_valid <= not r_empty;
    r_ready <= not r_full;

    r_read <= '1' when r_valid = '1' and i_ready = '1' else '0';
    r_write <= '1' when i_valid = '1' and r_ready = '1' else '0';

    o_data <= r_mem(r_rd_head);
    o_valid <= r_valid;
    o_ready <= r_ready;

    p_fifo : process (i_clk) is
    begin
        if rising_edge(i_clk) then
            if r_read = '1' then
                r_rd_head <= (r_rd_head + 1) mod c_depth;
            end if;

            if r_write = '1' then
                r_mem(r_wr_head) <= i_data;
                r_wr_head <= (r_wr_head + 1) mod c_depth;
            end if;

            if r_read = '1' and r_write = '0' then
                r_size <= r_size - 1;
            elsif r_read = '0' and r_write = '1' then
                r_size <= r_size + 1;
            end if;
        end if;
    end process p_fifo;

end architecture rtl;
