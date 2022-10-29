library ieee;
use ieee.std_logic_1164.all;

entity fifo is
    generic (
        c_width : positive;
        c_depth : positive
    );
    port (
        i_clk : in std_logic;
        i_write : in std_logic;
        i_read : in std_logic;
        o_empty : out std_logic;
        o_full : out std_logic;
        i_data : in std_logic_vector(c_width - 1 downto 0);
        o_data : out std_logic_vector(c_width - 1 downto 0)
    );
end entity fifo;

architecture rtl of fifo is

    type t_mem is array(c_depth - 1 downto 0) of std_logic_vector(c_width - 1 downto 0);
    signal r_mem : t_mem := (others => (others => '0'));
    signal r_out : std_logic_vector(c_width - 1 downto 0) := (others => '0');
    
    signal r_rd_head : integer range 0 to c_depth - 1 := 0;
    signal r_wr_head : integer range 0 to c_depth - 1 := 0;

begin
    
    o_empty <= '1' when r_rd_head = r_wr_head else '0';
    o_full <= '1' when r_rd_head = r_wr_head + 1 else '0';

    o_data <= r_out;

    p_fifo : process (i_clk) is
    begin
        if rising_edge(i_clk) then
            if i_write = '1' then
                r_mem(r_wr_head) <= i_data;
                r_wr_head <= r_wr_head + 1;
            end if;

            if i_read = '1' then
                r_out <= r_mem(r_rd_head);
                r_rd_head <= r_rd_head + 1;
            end if;
        end if;
    end process p_fifo;

end architecture rtl;
