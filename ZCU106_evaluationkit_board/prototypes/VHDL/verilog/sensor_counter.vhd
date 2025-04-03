library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_counter is
   port(
      SFP0_TX_DISABLE : in std_logic;                     -- Pin físico AE22
      SFP1_TX_DISABLE : in std_logic_vector(1 downto 0);  -- Pin físico AF20
      DDR4_DQ44       : in std_logic_vector(7 downto 0);  -- Pin físico AE24
      DDR4_DQ46       : out std_logic_vector(3 downto 0); -- Pin físico AE23
      DDR4_DQ40       : out std_logic_vector(7 downto 0)  -- Pin físico AF22
   );
end sensor_counter;

architecture arch of sensor_counter is
   -- Señales internas
   signal count, data_out : std_logic_vector(7 downto 0);
   signal led_display : std_logic_vector(3 downto 0);
   signal enable : std_logic;
begin
   -- Contador para sensor infrarrojo
   process(SFP0_TX_DISABLE)
   begin
      if rising_edge(SFP0_TX_DISABLE) then
         count <= std_logic_vector(unsigned(count) + 1);
      end if;
   end process;

   -- Multiplexor para datos de salida
   process(SFP1_TX_DISABLE, count)
   begin
      case SFP1_TX_DISABLE is
         when "00" =>
            data_out <= count;
         when "01" =>
            data_out <= DDR4_DQ44;
         when others =>
            data_out <= (others => '0');
      end case;
   end process;

   -- Gestión de datos de salida a LEDs
   led_display <= data_out(3 downto 0);
   DDR4_DQ46 <= led_display;
   DDR4_DQ40 <= data_out;

end arch;

