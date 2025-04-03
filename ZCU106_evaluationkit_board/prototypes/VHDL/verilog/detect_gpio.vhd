library ieee;
use ieee.std_logic_1164.all;

entity detect_gpio is
   port(
      GPIO_LED_4_LS : in std_logic;  -- Entrada asignada al pin físico AM8
      GPIO_LED_5_LS : in std_logic;  -- Entrada asignada al pin físico AM9
      GPIO_LED_6_LS : out std_logic  -- Salida asignada al pin físico AM10
   );
end detect_gpio;

architecture moore_arch of detect_gpio is
   -- Definición de los estados
   type state_type is (zero, edge, one);
   signal state_reg, state_next : state_type;

begin
   -- Registro de estado
   process(GPIO_LED_4_LS, GPIO_LED_5_LS)
   begin
      if GPIO_LED_4_LS = '1' then  -- Reset asincrónico
         state_reg <= zero;
      elsif rising_edge(GPIO_LED_5_LS) then  -- Flanco ascendente
         state_reg <= state_next;
      end if;
   end process;

   -- Lógica combinacional para el siguiente estado y la salida
   process(state_reg, GPIO_LED_5_LS)
   begin
      state_next <= state_reg;  -- Estado por defecto
      GPIO_LED_6_LS <= '0';     -- Salida por defecto
      
      case state_reg is
         when zero =>
            if GPIO_LED_5_LS = '1' then
               state_next <= edge;
            end if;

         when edge =>
            GPIO_LED_6_LS <= '1'; -- Genera pulso en el estado "edge"
            if GPIO_LED_5_LS = '1' then
               state_next <= one;
            else
               state_next <= zero;
            end if;

         when one =>
            if GPIO_LED_5_LS = '0' then
               state_next <= zero;
            end if;

         when others =>
            state_next <= zero; -- Estado de seguridad
      end case;
   end process;

end moore_arch;

