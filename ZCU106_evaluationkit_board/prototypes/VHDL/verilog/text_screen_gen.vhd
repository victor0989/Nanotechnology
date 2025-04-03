library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Asegúrate de incluir este paquete para usar to_integer

entity text_screen_gen is
   port(
      DDR4_A5  : in std_logic;                       -- Señal física asignada al pin AH8
      DDR4_A7  : in std_logic;                       -- Señal física asignada al pin AG8
      DDR4_A13 : out std_logic_vector(2 downto 0);   -- Señal física asignada al pin AF8 (salida RGB)
      DDR4_A9  : out std_logic_vector(6 downto 0);   -- Señal física asignada al pin AG10
      DDR4_A1  : in std_logic;                       -- Señal física asignada al pin AG11
      DDR4_A8  : in std_logic_vector(9 downto 0);    -- Señal física asignada al pin AH9 (coordenadas X)
      DDR4_A11 : in std_logic_vector(9 downto 0);    -- Señal física asignada al pin AG9 (coordenadas Y)
      DDR4_A10 : out std_logic_vector(2 downto 0)    -- Señal física asignada al pin AH13 (salida RGB final)
   );
end text_screen_gen;

architecture arch of text_screen_gen is
   -- Font ROM
   type font_rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
   constant FONT_ROM : font_rom_type := (
      "00000000", "00011000", "00111100", -- Carácter 0
      "00111100", "00111100", "00011000", -- Carácter 1
      "00000000", "00000000", "00011000", -- ...
      others => "00000000"
   );

   -- Señales internas para manejar las coordenadas y datos
   signal pixel_x, pixel_y : unsigned(9 downto 0); -- Convertido a unsigned para usar to_integer
   signal font_rgb : std_logic_vector(2 downto 0);
   signal text_rgb : std_logic_vector(2 downto 0);

   -- Señales para lectura de ROM
   signal char_code : unsigned(6 downto 0);
   signal font_data : std_logic_vector(7 downto 0);
   signal bit_index : unsigned(2 downto 0);

begin
   -- Conversión de las entradas físicas a tipo `unsigned`
   pixel_x <= unsigned(DDR4_A8);
   pixel_y <= unsigned(DDR4_A11);

   -- Lógica para extraer un carácter de la ROM basado en las coordenadas Y
   char_code <= pixel_y(6 downto 0);  -- Usa Y como índice en este ejemplo
   font_data <= FONT_ROM(to_integer(char_code)); -- Conversión segura usando to_integer

   -- Selección de bit en la fuente de acuerdo a X
   bit_index <= pixel_x(2 downto 0);
   font_rgb <= "111" when font_data(to_integer(bit_index)) = '1' else "000";

   -- Lógica de salida RGB
   text_rgb <= font_rgb;  -- Color del texto asignado directamente

   -- Asignación de las salidas físicas
   DDR4_A13 <= font_rgb;
   DDR4_A10 <= text_rgb;
   DDR4_A9 <= "0000000";  -- Salida genérica

end arch;
