library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;

entity project_reti_logiche is
    Port (
       i_clk : in std_logic;
       i_start : in std_logic;
       i_rst : in std_logic;
       i_data : in std_logic_vector(7 downto 0);
       o_address : out std_logic_vector(15 downto 0);
       o_done : out std_logic;
       o_en : out std_logic;
       o_we : out std_logic;
       o_data : out std_logic_vector(7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is (IDLE, ADDRESS_MODIFIER, WAIT_CLK, READ_RAM, CALC_MIN, WAIT_CLK_MIN, VERIFY_MIN, WRITE_MASK, DONE_H, DONE_L);
signal curr, nxt : state_type := IDLE;
signal current_address : std_logic_vector (15 downto 0) := "0000000000010001";
signal next_address : std_logic_vector (15 downto 0);
signal mask_in_curr, mask_in_next : std_logic_vector (7 downto 0);
signal x_curr, y_curr, x_next, y_next : integer range 0 to 255 := 0;
signal xp_curr, yp_curr, xp_next, yp_next : integer range 0 to 255 := 0;
signal d_curr, d_next : integer range 0 to 511 := 0;
signal d_min_curr, d_min_next : integer range 0 to 511 := 0;

begin

  project_reti_logiche: process(i_clk, i_rst, i_data, i_start)
  variable j : integer range 0 to 7 :=0;
  variable i : integer range -1 to 7 :=-1;
  variable mask_out : std_logic_vector (7 downto 0) := "00000000";

  begin

    if i_rst = '1' then
      curr <= IDLE;
    elsif rising_edge(i_clk) then
        curr <= nxt;
        current_address <= next_address;
        x_curr <= x_next;
        y_curr <= y_next;
        xp_curr <= xp_next;
        yp_curr <= yp_next;
        d_curr <= d_next;
        d_min_curr <= d_min_next;
        mask_in_curr <= mask_in_next;


      case curr is

        --legge la maschera in ingresso dalla RAM, all'indirizzo 0
        when IDLE =>
            if (i_start = '1') then --attendi il segnale di start
              o_done <= '0';
            end if;
            d_curr <= 0;
            d_min_curr <= 511;
            x_next  <= 0;
            y_next <= 0;
            xp_next <= 0;
            yp_next <= 0;
            d_next <= 0;
            d_min_next <= 511;
            mask_out := "00000000";
            current_address <= "0000000000010001";
            next_address <= "0000000000010001";
            mask_in_next <= "00000000";
            --o_address <= next_address;
            curr <= ADDRESS_MODIFIER;

          --continua a tornare nello stato 1 e leggere la RAM fino a quando non arriva all'indirizzo 18
          when ADDRESS_MODIFIER =>
              o_en <= '1';
              o_we <= '0';
              if(conv_integer(current_address) = 0) then
                  next_address <= current_address + "0000000000000001";
                  curr <= WAIT_CLK;
              elsif(conv_integer(current_address) < 16) then
                  next_address <= current_address + "0000000000000001";
                  curr <= WAIT_CLK;
              elsif(conv_integer(current_address) = 16) then
                  next_address<=current_address+"0000000000000001";
                  curr <= WAIT_CLK;
              elsif(conv_integer(current_address) = 17) then
                  next_address <= current_address + "0000000000000001";
                  curr <= WAIT_CLK;
              elsif(conv_integer(current_address) = 18) then
                  next_address <= "0000000000000000";
                  curr <= WAIT_CLK;
              end if;
              o_address <= current_address;

           when WAIT_CLK =>
               o_en <= '0';
               curr <= READ_RAM;

            --stato per fare operazioni sui dati
            when READ_RAM =>
                if(conv_integer(current_address) = 18) then
                    xp_next <= conv_integer(i_data);
                    i := -1;
                    --next_address <= current_address + "0000000000000001";
                    curr <= ADDRESS_MODIFIER;
                elsif(conv_integer(current_address) = 0) then
                    yp_next <= conv_integer(i_data);
                    --next_address <= "0000000000000000";
                    curr <= ADDRESS_MODIFIER;
                elsif(conv_integer(current_address) = 1) then
                    mask_in_next <= i_data;
                    --next_address <= current_address + "0000000000000001";
                    curr <= ADDRESS_MODIFIER;
                elsif(conv_integer(current_address) < 18) then
                    if((conv_integer(current_address) mod 2) = 0) then
                      x_next <= conv_integer(i_data);
                      --next_address <= current_address + "0000000000000001";
                      curr <= ADDRESS_MODIFIER;
                    else
                      y_next <= conv_integer(i_data);
                      --next_address <= current_address + "0000000000000001"
                      i := i+1;
                      curr <= CALC_MIN;
                    end if;
                end if;

            when CALC_MIN =>
                curr <= WAIT_CLK_MIN;

            when WAIT_CLK_MIN =>
                d_curr <= abs(x_curr - xp_curr) + abs(y_curr - yp_curr);
                curr <= VERIFY_MIN;

            when VERIFY_MIN =>

            if(mask_in_curr (i) = '1') then
                if(d_curr < d_min_curr and mask_in_curr (i) = '1') then
                  d_min_next <= d_curr;
                  for j in 0 to 7 loop
                      if(j = i) then
                          mask_out (i) := '1';
                      else
                          mask_out (j) := '0';
                      end if;
                  end loop;
                  --porta a 1 il bit dell'attuale posizione della maschera, lascia a 0 gli altri
                 elsif(d_curr = d_min_curr) then
                  --porta a 1 il bit corrente dell'attuale posizione della maschera, lascia invariati gli altri
                    for j in 0 to 7 loop
                        if(j = i) then
                            mask_out (i) := '1';
                        elsif(mask_out (j) = '1') then
                            mask_out (j) := '1';
                        else
                            mask_out (j) := '0';
                        end if;
                     end loop;
                else
                 for j in 0 to 7 loop
                    if(j = i) then
                        mask_out (i) := '0';
                    elsif(mask_out (j) = '1') then
                        mask_out (j) := '1';
                    else
                        mask_out (j) := '0';
                    end if;
                 end loop;
                end if;

            else --mask_in(curr) = '0' --> devo riportare in uscita lo 0 e lasciare gli altri invariati ---forse qui si puÃ² anche migliorare
               for j in 0 to 7 loop
                    if(j = i) then
                        mask_out (i) := '0';
                    elsif(mask_out (j) = '1') then
                        mask_out (j) := '1';
                    else
                        mask_out (j) := '0';
                    end if;
                  end loop;
            end if;
            if(conv_integer(current_address) = 17) then

                curr <= WRITE_MASK;
            else

                curr <= ADDRESS_MODIFIER;
            end if;

            when WRITE_MASK =>
                o_en <= '1';
                o_we <= '1';
                o_done <= '0';
                o_address <= "0000000000010011"; --indirizzo 19 dove devo scrivere la maschera di uscita
                o_data <= mask_out;
                curr <= DONE_H;

            --scrive il risultato prodotto (MASK_OUT) nell'indirizzo 19 della RAM
            when DONE_H =>
                o_en <= '1';
                o_we <= '1';
                o_done <= '1';
                o_address <= "0000000000010011";
                o_data <= mask_out;
                curr <= DONE_L;

            --stato finale in cui riabbasso il segnale done e mi riporto allo stato iniziale, pronto per una nuova computazione
            when DONE_L =>
                o_en <= '1';
                o_we <= '1';
                o_done <= '0';
                o_data <= "00000000";
                next_address <= "0000000000010001";
                curr <= IDLE;

      end case;
  end if;
  end process;

end Behavioral;
