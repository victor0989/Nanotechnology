library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xilinx_rom_sync_template is
   port(
      GPIO_DIP_SW7 : in std_logic;                        -- Pin físico B13
      GPIO_DIP_SW6 : in std_logic_vector(3 downto 0);     -- Pin físico B14
      GPIO_DIP_SW0 : out std_logic_vector(6 downto 0)     -- Pin físico A17
   );
end xilinx_rom_sync_template;

architecture arch of xilinx_rom_sync_template is
   constant ADDR_WIDTH: integer := 4;
   constant DATA_WIDTH: integer := 7;
   type rom_type is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

   -- Definición de ROM
   constant HEX2LED_ROM: rom_type := (
      "0000001", -- addr 00
      "1001111", -- addr 01
      "0010010", -- addr 02
      "0000110", -- addr 03
      "1001100", -- addr 04
      "0100100", -- addr 05
      "0100000", -- addr 06
      "0001111", -- addr 07
      "0000000", -- addr 08
      "0000100", -- addr 09
      "0001000", -- addr 10
      "1100000", -- addr 11
      "0110001", -- addr 12
      "1000010", -- addr 13
      "0110000", -- addr 14
      "1111111"  -- addr 15
   );

   signal addr_reg: std_logic_vector(ADDR_WIDTH - 1 downto 0);

begin
   -- Registro de dirección para inferir RAM bloque
   process(GPIO_DIP_SW7)
   begin
      if rising_edge(GPIO_DIP_SW7) then
         addr_reg <= GPIO_DIP_SW6;
      end if;
   end process;

   -- Salida de datos desde la ROM
   GPIO_DIP_SW0 <= HEX2LED_ROM(to_integer(unsigned(addr_reg)));

end arch;
