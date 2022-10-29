library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port (
        i_clk : in std_logic;

        i_valid : in std_logic;
        o_ready : out std_logic;
        i_data : in std_logic_vector(7 downto 0);

        o_valid : out std_logic;
        i_ready : in std_logic;
        o_data : out std_logic_vector(31 downto 0)
    );
end entity decoder;

architecture rtl of decoder is

    type t_state is (
        s_wait_0,
        s_wait_1,
        s_wait_2,
        s_wait_3,
        s_wait_4
    );
    signal r_state : t_state := s_wait_0;

    signal r_ready : std_logic := '1';
    signal r_valid : std_logic := '0';

    signal r_buf : std_logic_vector(27 downto 0);
    signal r_out : std_logic_vector(31 downto 0);

begin
    
    o_ready <= r_ready;
    o_valid <= r_valid;
    o_data <= r_out;

    p_decoder : process (i_clk)
    begin
        if rising_edge(i_clk) then
            -- if can accept data
            if i_valid = '1' and r_ready = '1' then
                if i_data(0) = '1' then
                    -- first byte
                    r_buf(6 downto 0) <= i_data(7 downto 1);
                    r_state <= s_wait_1;
                else
                    -- middle byte
                    case r_state is
                        when s_wait_0 =>
                        when s_wait_1 =>
                            r_buf(13 downto 7) <= i_data(7 downto 1);
                            r_state <= s_wait_2;
                        when s_wait_2 =>
                            r_buf(20 downto 14) <= i_data(7 downto 1);
                            r_state <= s_wait_3;
                        when s_wait_3 =>
                            r_buf(27 downto 21) <= i_data(7 downto 1);
                            r_state <= s_wait_4;
                        when s_wait_4 =>
                            r_out(31 downto 0) <= r_buf(27 downto 0) & i_data(4 downto 1);
                            r_state <= s_wait_0;
                            r_valid <= '1';
                    end case;
                end if;
            end if;

            -- invalidate excluding case s_wait_4
            if r_valid = '1' and i_ready = '1' and i_data(0) = '0' and r_state = s_wait_4 then
                r_valid <= '0';
            end if;
        end if;
    end process p_decoder;

end architecture rtl;
