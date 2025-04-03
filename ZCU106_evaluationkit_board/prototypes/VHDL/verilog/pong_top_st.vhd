library ieee;
use ieee.std_logic_1164.all;

entity pong_top_st is
   port(
      GPIO_LED_0_LS : in std_logic;                    -- Señal física del LED 0
      GPIO_LED_1_LS : out std_logic;                   -- Señal física del LED 1
      GPIO_LED_2_LS : out std_logic_vector(2 downto 0) -- Señal física del LED 2
   );
end pong_top_st;

architecture arch of pong_top_st is
   -- Declaración de señales internas para el manejo de datos RGB
   signal rgb_reg : std_logic_vector(2 downto 0) := (others => '0');
   signal ball_rgb : std_logic_vector(2 downto 0) := "100"; -- Color rojo para la bola
begin
   -- Lógica simple para salida de LED 1 y LED 2
   process(GPIO_LED_0_LS)
   begin
      if GPIO_LED_0_LS = '1' then
         rgb_reg <= ball_rgb; -- Asignación fija del color de la bola
      end if;
   end process;

   GPIO_LED_1_LS <= GPIO_LED_0_LS; -- Pasar directamente el estado del LED 0 al LED 1
   GPIO_LED_2_LS <= rgb_reg;       -- Asignación de RGB al LED 2

end arch;

