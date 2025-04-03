library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_text is
   port(
      DDR4_DQ44     : in std_logic;                      -- Pin físico AE24
      DDR4_DQ46     : in std_logic_vector(9 downto 0);   -- Pin físico AE23
      DDR4_DQ40     : in std_logic_vector(9 downto 0);   -- Pin físico AF22
      DDR4_DQ47     : in std_logic_vector(3 downto 0);   -- Pin físico AF21
      DDR4_DQS5_C   : in std_logic_vector(3 downto 0);   -- Pin físico AG23
      DDR4_DQS5_T   : in std_logic_vector(1 downto 0);   -- Pin físico AF23
      DDR4_DQ45     : out std_logic_vector(3 downto 0);  -- Pin físico AG20
      DDR4_DQ42     : out std_logic_vector(2 downto 0)   -- Pin físico AG19
   );
end pong_text;

architecture arch of pong_text is
   -- Señales internas
   signal pix_x, pix_y : unsigned(9 downto 0);
   signal rom_addr : std_logic_vector(10 downto 0);
   signal char_addr, char_addr_s, char_addr_r, char_addr_o : std_logic_vector(6 downto 0);
   signal row_addr, row_addr_s, row_addr_r, row_addr_o : std_logic_vector(3 downto 0);
   signal bit_addr, bit_addr_s, bit_addr_r, bit_addr_o : std_logic_vector(2 downto 0);
   signal score_on, rule_on, over_on : std_logic;
   signal text_rgb : std_logic_vector(3 downto 0);
begin
   -- Asignación de señales físicas
   pix_x <= unsigned(DDR4_DQ46);
   pix_y <= unsigned(DDR4_DQ40);

   -- Región de puntuación
   score_on <= '1' when pix_y(9 downto 5) = "00000" and pix_x(9 downto 4) < 16 else '0';
   row_addr_s <= std_logic_vector(pix_y(4 downto 1));
   bit_addr_s <= std_logic_vector(pix_x(3 downto 1));
   with pix_x(7 downto 4) select
      char_addr_s <=
         "1010011" when "0000", -- S
         "1100011" when "0001", -- C
         "1101111" when "0010", -- O
         "1110010" when "0011", -- R
         "1100101" when "0100", -- E
         "0000000" when others;

   -- Región de reglas
   rule_on <= '1' when pix_x(9 downto 7) = "010" and pix_y(9 downto 6) = "0010" else '0';
   row_addr_r <= std_logic_vector(pix_y(3 downto 0));
   bit_addr_r <= std_logic_vector(pix_x(2 downto 0));

   -- Región de "Game Over"
   over_on <= '1' when pix_y(9 downto 6) = "0011" and pix_x(9 downto 5) >= "00101" and pix_x(9 downto 5) <= "01101" else '0';
   row_addr_o <= std_logic_vector(pix_y(5 downto 2));
   bit_addr_o <= std_logic_vector(pix_x(4 downto 2));
   with pix_x(8 downto 5) select
      char_addr_o <=
         "1000111" when "0101", -- G
         "1100001" when "0110", -- A
         "1101101" when "0111", -- M
         "1100101" when "1000", -- E
         "0000000" when others;

   -- Multiplexor para direcciones ROM y señales RGB
   process(score_on, rule_on, over_on, char_addr_s, row_addr_s, bit_addr_s, char_addr_r, row_addr_r, bit_addr_r, char_addr_o, row_addr_o, bit_addr_o)
   begin
      text_rgb <= "110"; -- Fondo amarillo por defecto
      if score_on = '1' then
         char_addr <= char_addr_s;
         row_addr <= row_addr_s;
         bit_addr <= bit_addr_s;
         text_rgb <= "001"; -- Texto azul
      elsif rule_on = '1' then
         char_addr <= char_addr_r;
         row_addr <= row_addr_r;
         bit_addr <= bit_addr_r;
         text_rgb <= "001"; -- Texto azul
      elsif over_on = '1' then
         char_addr <= char_addr_o;
         row_addr <= row_addr_o;
         bit_addr <= bit_addr_o;
         text_rgb <= "011"; -- Texto verde
      end if;
      DDR4_DQ45 <= text_rgb;
   end process;

   -- Generación de direcciones ROM
   rom_addr <= char_addr & row_addr;

end arch;

