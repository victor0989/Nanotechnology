library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_counter is
   generic(N: integer := 8); -- Parámetro de tamaño del contador
   port(
      FMC_HPC0_LA23_N : in std_logic;                       -- Señal física asignada al pin A11
      FMC_HPC0_LA23_P : in std_logic;                       -- Señal física asignada al pin B11
      FMC_HPC0_LA27_N : in std_logic;                       -- Señal física asignada al pin A7
      FMC_HPC0_LA27_P : in std_logic_vector(N-1 downto 0);  -- Señal física asignada al pin A8
      FMC_HPC0_LA23_N_STATUS : out std_logic;               -- Estado de salida, asignado a A11
      FMC_HPC0_LA27_P_DATA   : out std_logic_vector(N-1 downto 0) -- Datos de salida, asignado al pin A8
   );
end bin_counter;

architecture demo_arch of bin_counter is
   -- Declaración de constantes y señales internas
   constant MAX: integer := (2**N - 1);
   signal r_reg: unsigned(N-1 downto 0);
   signal r_next: unsigned(N-1 downto 0);
   signal internal_status: std_logic; -- Señal interna para manejar el estado
begin
   -- Registro y reinicio del contador
   process(FMC_HPC0_LA23_N, FMC_HPC0_LA23_P)
   begin
      if FMC_HPC0_LA23_N = '1' then -- Reinicio sincrónico
         r_reg <= (others => '0');
      elsif rising_edge(FMC_HPC0_LA23_P) then -- Flanco ascendente para avanzar
         r_reg <= r_next;
      end if;
   end process;

   -- Lógica combinacional para el siguiente estado del contador
   r_next <= (others => '0') when FMC_HPC0_LA27_N = '1' else
             unsigned(FMC_HPC0_LA27_P) when FMC_HPC0_LA23_P = '1' else
             r_reg + 1 when internal_status = '1' else
             r_reg;

   -- Actualización de la señal interna y salida
   internal_status <= '1' when r_reg = MAX else '0';
   FMC_HPC0_LA23_N_STATUS <= internal_status; -- Reflejar el estado interno en la salida

   -- Lógica de salida de datos
   FMC_HPC0_LA27_P_DATA <= std_logic_vector(r_reg); -- Salida de datos

end demo_arch;

