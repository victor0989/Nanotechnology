library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_text is
   port(
      TRACETRST_B     : in std_logic;                      -- Pin físico F5
      TRACEDATA15     : in std_logic_vector(9 downto 0);   -- Pin físico D4
      TRACEDATA14     : in std_logic_vector(9 downto 0);   -- Pin físico E4
      TRACEDATA13     : in std_logic_vector(3 downto 0);   -- Pin físico B4
      TRACEDATA12     : in std_logic_vector(3 downto 0);   -- Pin físico C4
      TRACEDATA11     : out std_logic_vector(3 downto 0);  -- Pin físico B3
      TRACEDATA10     : out std_logic_vector(2 downto 0)   -- Pin físico C3
   );
end sensor_text;

architecture arch of sensor_text is
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
   pix_x <= unsigned(TRACEDATA15); -- Coordenadas X
   pix_y <= unsigned(TRACEDATA14); -- Coordenadas Y

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
      TRACEDATA11 <= text_rgb;
   end process;

   -- Generación de direcciones ROM
   rom_addr <= char_addr & row_addr;

end arch;

