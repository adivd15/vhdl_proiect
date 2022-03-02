library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end fsm;

architecture Behavioral of fsm is

--define states (alea de pe tabla)
type states is (start, get_rdn, led_on, sw_on, sw_off, led_off, count);
signal score : std_logic_vector (15 downto 0);
signal current_state, next_state : states;
signal i : integer range 0 to 15;
signal reg : std_logic_vector (15 downto 0) := x"0000";
begin

--ceva susta de stare
men: process(rst, clk)
begin
    if rst = '1' then
        current_state <= start;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if;
end process;

--alta susta de stare
clc: process(current_state, sw, i)
begin
    case current_state is
        when start => next_state <= get_rdn;
        when get_rdn => next_state <= led_on;
        when led_on => next_state <= sw_on;
        when sw_on => if sw(i) = '1' then
                         next_state <= sw_off;
                      end if;
        when sw_off => if sw(i) = '0' then
                         next_state <= led_off;
                       end if;
        when led_off => next_state <= count;
        when count => next_state <= get_rdn;
        when others => next_state <= start;
        
    end case;
    
end process;

lfst : process (rst, clk)
    variable firstbit : std_logic;
begin
    if rst = '1' then
        reg <= x"0000";
    elsif rising_edge (clk) then
        firstbit := reg(1) xnor reg(0);
        reg <= firstbit &reg(15 downto 1);
    end if;
end process;

generate_i: process (rst, clk)
begin
    if rst = '1' then
        i <= 0;
    elsif rising_edge (clk) then
        if current_state = get_rdn then
            i <= to_integer(unsigned(reg(3 downto 0)));
            end if;
        end if;
end process;

generate_led: process (rst,clk)
begin
    if rst = '1' then
        led <= x"0000";
    elsif rising_edge (clk) then
        if current_state = led_on then
            led(i) <= '1';
        elsif current_state = led_off then
            led(i) <= '0';
        end if;
    end if;
end process;

generate_scor : process (rst, clk)
    variable mii, sute, zeci, unitati : integer range 0 to 9 :=0;
begin
    if rst = '1' then
        mii :=0;
        sute :=0;
        zeci :=0;
        unitati :=0;
        score <= x"0000";
    elsif rising_edge (clk) then
        if current_state = count then
            if unitati = 9 then
                unitati :=0;
            if zeci = 9 then
                zeci := 0;
            if sute = 9 then
                sute :=0;
                if mii = 9 then
                    mii :=0;
                else
                    mii := mii+1;
                end if;
             else
                sute:=sute+1;
             end if;
        else
             zeci := zeci+1;
        end if;
 else 
     unitati:= unitati+1;
 end if;
 
 score <= std_logic_vector(to_unsigned(mii,4)) &
          std_logic_vector(to_unsigned(sute,4)) &
          std_logic_vector(to_unsigned(zeci,4)) &
          std_logic_vector(to_unsigned(unitati,4));
 end if;
 end if;
end process;

end Behavioral;
