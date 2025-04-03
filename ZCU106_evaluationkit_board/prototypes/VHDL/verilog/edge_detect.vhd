library ieee;
use ieee.std_logic_1164.all;

-- Agregar la biblioteca específica de Xilinx que contiene el IBUFDS
library unisim;
use unisim.vcomponents.all;

entity edge_detect is
   port(
      FMC_HPC1_LA05_P : in  std_logic;  -- Reloj diferencial positivo
      FMC_HPC1_LA05_N : in  std_logic;  -- Reloj diferencial negativo
      FMC_HPC1_LA07_N : in  std_logic;  -- Señal de entrada ("level")
      FMC_HPC1_LA07_P : out std_logic   -- Salida del detector (pulso "tick")
    );
end edge_detect;

architecture moore_arch of edge_detect is

   -- Definición de los estados de la máquina de Moore
   type state_type is (ZERO, EDGE, ONE);
   signal state_reg, state_next : state_type;
   
   -- Señal de reloj single-ended obtenida a partir del par diferencial
   signal clk : std_logic;
   
begin

   -- Instanciación del IBUFDS para convertir el reloj diferencial en single-ended
   clk_ibufds: IBUFDS 
      port map (
         I  => FMC_HPC1_LA05_P,
         IB => FMC_HPC1_LA05_N,
         O  => clk
      );
      
   -- Registro de estados, actualizado en el flanco de subida del reloj
   process(clk)
   begin
      if rising_edge(clk) then
         state_reg <= state_next;
      end if;
   end process;
   
   -- Lógica combinacional: Máquina de estados para la detección de flancos
   process(state_reg, FMC_HPC1_LA07_N)
   begin
      -- Valores por defecto
      state_next      <= state_reg;
      FMC_HPC1_LA07_P <= '0';
      
      case state_reg is
         when ZERO =>
            if FMC_HPC1_LA07_N = '1' then
               state_next <= EDGE;
            end if;
            
         when EDGE =>
            FMC_HPC1_LA07_P <= '1';
            if FMC_HPC1_LA07_N = '1' then
               state_next <= ONE;
            else
               state_next <= ZERO;
            end if;
            
         when ONE =>
            if FMC_HPC1_LA07_N = '0' then
               state_next <= ZERO;
            end if;
            
         when others =>
            state_next <= ZERO;
      end case;
   end process;
   
end moore_arch;
