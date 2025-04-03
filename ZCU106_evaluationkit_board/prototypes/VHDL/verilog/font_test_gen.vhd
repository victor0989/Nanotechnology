library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity font_test_gen is
   port(
      PMOD0_4_LS : in std_logic;                     -- Señal física asignada al pin K24
      PMOD0_5_LS : in std_logic;                     -- Señal física asignada al pin L23
      PMOD0_6_LS : out std_logic_vector(2 downto 0)  -- Señal física asignada al pin L22
   );
end font_test_gen;

architecture arch of font_test_gen is
   -- Señales internas para generación de ROM
   signal rom_addr   : std_logic_vector(10 downto 0);
   signal char_addr  : std_logic_vector(6 downto 0);
   signal row_addr   : std_logic_vector(3 downto 0);
   signal bit_addr   : unsigned(2 downto 0);
   signal font_word  : std_logic_vector(7 downto 0);
   signal font_bit   : std_logic;
   signal text_bit_on: std_logic;
begin
   -- Interfaz de la ROM basada en coordenadas
   char_addr <= PMOD0_5_LS & PMOD0_4_LS;  -- Ejemplo simple que usa las señales físicas directamente
   row_addr <= PMOD0_4_LS & PMOD0_5_LS;   -- Manejo ficticio para fila
   rom_addr <= char_addr & row_addr;      -- Dirección completa
   bit_addr <= unsigned(char_addr(2 downto 0)); -- Solo parte baja

   -- Lógica de bit de fuente
   font_bit <= font_word(to_integer(bit_addr));

   -- Activación de texto en base a las señales físicas
   text_bit_on <=
      font_bit when PMOD0_4_LS = '1' and PMOD0_5_LS = '1' else
      '0';

   -- Salida RGB
   PMOD0_6_LS <= "010" when text_bit_on = '1' else "000"; -- Verde para texto y negro para fondo
end arch;

